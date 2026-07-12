<#
.SYNOPSIS
    Sets up Windows Task Scheduler to run the monitoring dashboard automatically
.DESCRIPTION
    Creates a scheduled task to run the monitoring script at system startup and continuously
.PARAMETER ConfigPath
    Path to the configuration file
.PARAMETER TaskName
    Name of the scheduled task
.PARAMETER ScriptPath
    Path to the monitoring script
#>

function Setup-ScheduledMonitoring {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = ".\config\config.json",
        
        [Parameter(Mandatory=$false)]
        [string]$ScriptPath = ".\src\Monitor-Network.ps1"
    )

    try {
        # Load configuration
        if (-not (Test-Path $ConfigPath)) {
            Write-Error "Configuration file not found: $ConfigPath"
            return $false
        }

        $config = Get-Content $ConfigPath | ConvertFrom-Json
        $taskName = $config.scheduler.taskName
        $runInterval = $config.scheduler.runInterval
        $runElevated = $config.scheduler.runElevated

        # Get full paths
        $scriptFullPath = (Resolve-Path $ScriptPath).Path
        $workingDirectory = (Get-Item $ScriptPath).DirectoryName | Split-Path -Parent

        # Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Write-Host "Task '$taskName' already exists. Removing old task..."
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false | Out-Null
        }

        # Create trigger (at system startup)
        $trigger = New-ScheduledTaskTrigger -AtStartup

        # Create action (run PowerShell script)
        $action = New-ScheduledTaskAction `
            -Execute "powershell.exe" `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptFullPath`" -Continuous" `
            -WorkingDirectory $workingDirectory

        # Create principal (run with highest privileges if enabled)
        $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
        if ($runElevated) {
            $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
        }

        # Create settings
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -MultipleInstances IgnoreNew `
            -ExecutionTimeLimit (New-TimeSpan -Hours 0)

        # Register the task
        $task = Register-ScheduledTask `
            -TaskName $taskName `
            -Trigger $trigger `
            -Action $action `
            -Principal $principal `
            -Settings $settings `
            -Description "Network Monitoring Dashboard - Automated System Alerts"

        Write-Host "✓ Scheduled task '$taskName' created successfully!" -ForegroundColor Green
        Write-Host "  - Runs at system startup" -ForegroundColor Green
        Write-Host "  - Runs with SYSTEM privileges" -ForegroundColor Green
        Write-Host "  - Script: $scriptFullPath" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Error "Failed to setup scheduled task: $_"
        return $false
    }
}

function Remove-ScheduledMonitoring {
    param(
        [Parameter(Mandatory=$false)]
        [string]$TaskName = "NetworkMonitoringDashboard"
    )

    try {
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($existingTask) {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false | Out-Null
            Write-Host "✓ Scheduled task '$TaskName' removed successfully!" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "Task '$TaskName' not found." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Error "Failed to remove scheduled task: $_"
        return $false
    }
}

function Get-ScheduledMonitoringStatus {
    param(
        [Parameter(Mandatory=$false)]
        [string]$TaskName = "NetworkMonitoringDashboard"
    )

    try {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($task) {
            $taskInfo = Get-ScheduledTaskInfo -InputObject $task
            Write-Host "Task: $TaskName" -ForegroundColor Cyan
            Write-Host "  Status: $($task.State)" -ForegroundColor Cyan
            Write-Host "  Last Run: $($taskInfo.LastRunTime)" -ForegroundColor Cyan
            Write-Host "  Last Result: $($taskInfo.LastTaskResult)" -ForegroundColor Cyan
            Write-Host "  Next Run: $($taskInfo.NextRunTime)" -ForegroundColor Cyan
            return $task
        }
        else {
            Write-Host "Task '$TaskName' not found." -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Error "Failed to get scheduled task status: $_"
        return $null
    }
}
