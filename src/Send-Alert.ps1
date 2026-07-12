<#
.SYNOPSIS
    Sends alerts when system metrics exceed thresholds
.DESCRIPTION
    Logs alerts to file and optionally sends email notifications
.PARAMETER AlertType
    Type of alert (CPU, Memory, Disk, Network)
.PARAMETER AlertMessage
    Message to include in alert
.PARAMETER Severity
    Severity level (Warning, Critical)
#>

function Send-Alert {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AlertType,
        
        [Parameter(Mandatory=$true)]
        [string]$AlertMessage,
        
        [ValidateSet("Warning", "Critical")]
        [string]$Severity = "Warning",
        
        [string]$LogPath = "./logs"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $alertText = "[$timestamp] [$Severity] [$AlertType] $AlertMessage"

    # Ensure logs directory exists
    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }

    # Log to file
    $logFile = Join-Path $LogPath "alerts.log"
    Add-Content -Path $logFile -Value $alertText

    # Console output
    $color = if ($Severity -eq "Critical") { "Red" } else { "Yellow" }
    Write-Host $alertText -ForegroundColor $color

    return $true
}

function Check-Thresholds {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Metrics,
        
        [hashtable]$Thresholds
    )

    $alerts = @()

    # Check CPU
    if ($Metrics.CPUUsagePercent -gt $Thresholds.cpuThreshold) {
        $alerts += Send-Alert -AlertType "CPU" `
            -AlertMessage "CPU usage is at $($Metrics.CPUUsagePercent)% (Threshold: $($Thresholds.cpuThreshold)%)" `
            -Severity "Critical"
    }

    # Check Memory
    if ($Metrics.MemoryUsagePercent -gt $Thresholds.memoryThreshold) {
        $alerts += Send-Alert -AlertType "Memory" `
            -AlertMessage "Memory usage is at $($Metrics.MemoryUsagePercent)% (Threshold: $($Thresholds.memoryThreshold)%)" `
            -Severity "Critical"
    }

    # Check Disk
    if ($Metrics.DiskUsagePercent -gt $Thresholds.diskThreshold) {
        $alerts += Send-Alert -AlertType "Disk" `
            -AlertMessage "Disk usage is at $($Metrics.DiskUsagePercent)% (Threshold: $($Thresholds.diskThreshold)%)" `
            -Severity "Warning"
    }

    return $alerts
}
