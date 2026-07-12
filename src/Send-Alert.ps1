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
        
        [string]$LogPath = "./logs",
        
        [object]$EmailConfig = $null
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

    # Send email if enabled and configured
    if ($EmailConfig -and $EmailConfig.enableEmailAlerts) {
        try {
            # Convert plain text password to secure string
            $securePassword = ConvertTo-SecureString $EmailConfig.emailPassword -AsPlainText -Force

            Send-EmailAlert -AlertType $AlertType `
                -AlertMessage $AlertMessage `
                -EmailFrom $EmailConfig.emailFrom `
                -EmailTo $EmailConfig.emailTo `
                -SmtpServer $EmailConfig.smtpServer `
                -SmtpPort $EmailConfig.smtpPort `
                -EmailPassword $securePassword `
                -Severity $Severity
        }
        catch {
            Write-Warning "Failed to send email alert: $_"
        }
    }

    return $true
}

function Check-Thresholds {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Metrics,
        
        [object]$Thresholds,
        
        [object]$EmailConfig = $null
    )

    $alerts = @()

    # Check CPU
    if ($Metrics.CPUUsagePercent -gt $Thresholds.cpuThreshold) {
        $alerts += Send-Alert -AlertType "CPU" `
            -AlertMessage "CPU usage is at $($Metrics.CPUUsagePercent)% (Threshold: $($Thresholds.cpuThreshold)%)" `
            -Severity "Critical" `
            -EmailConfig $EmailConfig
    }

    # Check Memory
    if ($Metrics.MemoryUsagePercent -gt $Thresholds.memoryThreshold) {
        $alerts += Send-Alert -AlertType "Memory" `
            -AlertMessage "Memory usage is at $($Metrics.MemoryUsagePercent)% (Threshold: $($Thresholds.memoryThreshold)%)" `
            -Severity "Critical" `
            -EmailConfig $EmailConfig
    }

    # Check Disk
    if ($Metrics.DiskUsagePercent -gt $Thresholds.diskThreshold) {
        $alerts += Send-Alert -AlertType "Disk" `
            -AlertMessage "Disk usage is at $($Metrics.DiskUsagePercent)% (Threshold: $($Thresholds.diskThreshold)%)" `
            -Severity "Warning" `
            -EmailConfig $EmailConfig
    }

    return $alerts
}
