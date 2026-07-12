<#
.SYNOPSIS
    Network Monitoring Dashboard - Main Script
.DESCRIPTION
    Continuously monitors system and network metrics, logs alerts when thresholds are exceeded
.PARAMETER ConfigPath
    Path to the configuration JSON file
.PARAMETER Continuous
    Run continuously with monitoring loop
#>

param(
    [string]$ConfigPath = "./config/config.json",
    [switch]$Continuous
)

# Import helper functions
. ".\src\Get-SystemMetrics.ps1"
. ".\src\Send-Alert.ps1"

function Start-MonitoringDashboard {
    param(
        [string]$ConfigPath,
        [switch]$Continuous
    )

    # Load configuration
    if (-not (Test-Path $ConfigPath)) {
        Write-Error "Configuration file not found: $ConfigPath"
        return
    }

    $config = Get-Content $ConfigPath | ConvertFrom-Json

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   Network Monitoring Dashboard" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""

    $iteration = 0

    do {
        $iteration++
        Write-Host "[Iteration $iteration] $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan

        # Get metrics
        $metrics = Get-SystemMetrics

        if ($metrics) {
            # Display metrics
            Write-Host "CPU Usage:    $($metrics.CPUUsagePercent)%" -ForegroundColor White
            Write-Host "Memory Usage: $($metrics.MemoryUsagePercent)% ($($metrics.MemoryUsedGB)GB / $($metrics.MemoryTotalGB)GB)" -ForegroundColor White
            Write-Host "Disk Usage:   $($metrics.DiskUsagePercent)%" -ForegroundColor White
            Write-Host ""

            # Check thresholds and send alerts
            $thresholds = @{
                cpuThreshold       = $config.monitoring.cpuThreshold
                memoryThreshold    = $config.monitoring.memoryThreshold
                diskThreshold      = $config.monitoring.diskThreshold
            }

            Check-Thresholds -Metrics $metrics -Thresholds $thresholds | Out-Null
        }

        if ($Continuous) {
            $checkInterval = $config.monitoring.checkInterval
            Write-Host "Next check in $checkInterval seconds..." -ForegroundColor DarkGray
            Start-Sleep -Seconds $checkInterval
            Write-Host ""
        }
        else {
            break
        }
    } while ($Continuous)

    Write-Host "Monitoring stopped." -ForegroundColor Yellow
}

# Run the monitoring dashboard
Start-MonitoringDashboard -ConfigPath $ConfigPath -Continuous:$Continuous