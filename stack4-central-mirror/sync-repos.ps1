# stack4-central-mirror/sync-repos.ps1
# Azure Automation Runbook for triggering repository sync

param(
    [Parameter(Mandatory=$false)]
    [string]$VMName = "${vm_name}",

    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "${resource_group_name}",

    [Parameter(Mandatory=$false)]
    [string]$StorageAccountName = "${storage_account_name}",

    [Parameter(Mandatory=$false)]
    [string]$ContainerName = "${container_name}"
)

# Connect using Managed Identity
Write-Output "Connecting to Azure using Managed Identity..."
try {
    Connect-AzAccount -Identity
    Write-Output "Successfully connected to Azure"
} catch {
    Write-Error "Failed to connect to Azure: $($_.Exception.Message)"
    exit 1
}

# Function to run command on VM
function Invoke-VMCommand {
    param(
        [string]$Command,
        [string]$Description
    )

    Write-Output "Executing: $Description"
    try {
        $result = Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -VMName $VMName -CommandId 'RunShellScript' -ScriptString $Command

        if ($result.Value[0].Message) {
            Write-Output "Command output: $($result.Value[0].Message)"
        }

        if ($result.Value[1].Message) {
            Write-Output "Command errors: $($result.Value[1].Message)"
        }

        return $true
    } catch {
        Write-Error "Failed to execute command '$Description': $($_.Exception.Message)"
        return $false
    }
}

# Check VM status
Write-Output "Checking VM status..."
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status
$vmStatus = ($vm.Statuses | Where-Object {$_.Code -like "PowerState/*"}).DisplayStatus

if ($vmStatus -ne "VM running") {
    Write-Output "VM is not running (Status: $vmStatus). Starting VM..."
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName

    # Wait for VM to be ready
    do {
        Start-Sleep -Seconds 30
        $vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Status
        $vmStatus = ($vm.Statuses | Where-Object {$_.Code -like "PowerState/*"}).DisplayStatus
        Write-Output "Waiting for VM to start... Current status: $vmStatus"
    } while ($vmStatus -ne "VM running")

    # Additional wait for services to start
    Write-Output "VM started. Waiting for services to initialize..."
    Start-Sleep -Seconds 60
}

Write-Output "VM is running. Proceeding with repository sync..."

# Execute repository sync commands
$commands = @(
    @{
        Command = "systemctl status nginx"
        Description = "Check nginx status"
    },
    @{
        Command = "df -h /var/www/repos"
        Description = "Check repository disk space"
    },
    @{
        Command = "/usr/local/bin/mirror-ubuntu.sh"
        Description = "Sync Ubuntu repositories"
    },
    @{
        Command = "/usr/local/bin/mirror-centos.sh"
        Description = "Sync CentOS repositories"
    },
    @{
        Command = "/usr/local/bin/sync-to-blob.sh"
        Description = "Upload repositories to blob storage"
    }
)

$successCount = 0
$totalCommands = $commands.Count

foreach ($cmd in $commands) {
    if (Invoke-VMCommand -Command $cmd.Command -Description $cmd.Description) {
        $successCount++
    }

    # Small delay between commands
    Start-Sleep -Seconds 10
}

# Generate sync report
Write-Output "`n=== Repository Sync Summary ==="
Write-Output "VM Name: $VMName"
Write-Output "Resource Group: $ResourceGroupName"
Write-Output "Storage Account: $StorageAccountName"
Write-Output "Container: $ContainerName"
Write-Output "Commands Executed: $successCount/$totalCommands"
Write-Output "Sync completed at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')"

if ($successCount -eq $totalCommands) {
    Write-Output "✅ All sync operations completed successfully"
} else {
    Write-Warning "⚠️ Some sync operations failed. Check logs for details."
}

# Optional: Get repository statistics
$statsCommand = @"
echo "=== Repository Statistics ==="
echo "Ubuntu repository size:"
du -sh /var/www/repos/mirror/archive.ubuntu.com 2>/dev/null || echo "Ubuntu repos not found"
echo "CentOS repository size:"
du -sh /var/www/repos/centos 2>/dev/null || echo "CentOS repos not found"
echo "Total repository size:"
du -sh /var/www/repos 2>/dev/null || echo "Repository directory not found"
echo "Available disk space:"
df -h /var/www/repos
"@

Write-Output "`n=== Repository Statistics ==="
Invoke-VMCommand -Command $statsCommand -Description "Get repository statistics"

Write-Output "`nRepository sync runbook completed."