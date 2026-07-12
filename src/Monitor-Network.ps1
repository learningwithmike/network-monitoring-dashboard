<#
.SYNOPSIS
    Network Monitoring Dashboard - Main monitoring script
.DESCRIPTION
    Continuously monitors system metrics and sends alerts when thresholds are exceeded
.PARAMETER Continuous
    Run monitoring continuously (every checkInterval seconds)
#>

param(
    [switch]$Continuous
)

# Import helper functions
. .\src\Get-SystemMetrics.ps1
. .\src\Send-Alert.ps1
. .\src\Send-EmailAlert.ps1

# Load configuration
$configPath = ".\config\config.json"
if (-not (Test-Path $configPath)) {
    Write-Error "Configuration file not found: $configPath"
    exit 1
}

$config = Get-Content $configPath | ConvertFrom-Json
$monitoring = $config.monitoring
$alerts = $config.alerts

# Display header
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Network Monitoring Dashboard" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($Continuous) {
    Write-Host "Running in CONTINUOUS mode (Ctrl+C to stop)" -ForegroundColor Green
    Write-Host "Check interval: $($monitoring.checkInterval) seconds" -ForegroundColor Green
    Write-Host ""
}

# Iteration counter
$iteration = 1

# Main monitoring loop
do {
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[Iteration $iteration] $timestamp"

        # Get system metrics
        $metrics = Get-SystemMetrics

        if ($metrics) {
            # Display metrics
            Write-Host "CPU Usage:    $($metrics.CPUUsagePercent)%"
            Write-Host "Memory Usage: $($metrics.MemoryUsagePercent)% ($($metrics.MemoryUsedGB)GB / $($metrics.MemoryTotalGB)GB)"
            Write-Host "Disk Usage:   $($metrics.DiskUsagePercent)%"

            # Check thresholds and send alerts
            $alertThresholds = @{
                cpuThreshold = $monitoring.cpuThreshold
                memoryThreshold = $monitoring.memoryThreshold
                diskThreshold = $monitoring.diskThreshold
            }

            Check-Thresholds -Metrics $metrics -Thresholds $alertThresholds -EmailConfig $alerts
        }
        else {
            Write-Host "Failed to retrieve metrics" -ForegroundColor Red
        }

        $iteration++

        # If continuous mode, wait and loop
        if ($Continuous) {
            Write-Host ""
            Write-Host "Next check in $($monitoring.checkInterval) seconds..." -ForegroundColor Gray
            Write-Host ""
            Start-Sleep -Seconds $monitoring.checkInterval
        }
        else {
            break
        }
    }
    catch {
        Write-Error "Error during monitoring iteration: $_"
        if (-not $Continuous) {
            break
        }
    }
} while ($Continuous)

Write-Host ""
Write-Host "Monitoring stopped." -ForegroundColor Yellow
