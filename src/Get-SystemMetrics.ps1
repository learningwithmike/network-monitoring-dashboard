<#
.SYNOPSIS
    Retrieves current system performance metrics
.DESCRIPTION
    Gathers CPU, Memory, Disk, and Network metrics from the local system
.OUTPUTS
    PSCustomObject with system metrics
#>

function Get-SystemMetrics {
    param(
        [string]$ComputerName = "localhost"
    )

    try {
        # Get CPU Usage (last 1 second sample)
        $cpuUsage = (Get-WmiObject Win32_PerfFormattedData_PerfOS_Processor -Filter "name='_Total'" -ErrorAction Stop).PercentProcessorTime

        # Get Memory Usage
        $memory = Get-WmiObject Win32_OperatingSystem -ErrorAction Stop
        $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
        $freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
        $usedMemory = [math]::Round(($memory.TotalVisibleMemorySize - $memory.FreePhysicalMemory) / 1MB, 2)
        $memoryUsagePercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)

        # Get Disk Usage (C: drive)
        $disk = Get-PSDrive -Name C -ErrorAction Stop
        $diskUsagePercent = [math]::Round(($disk.Used / $disk.Size) * 100, 2)

        # Get Network Interface Stats
        $networkStats = Get-NetAdapterStatistics -ErrorAction Stop | Select-Object -First 1
        $bytesSent = $networkStats.SentBytes
        $bytesReceived = $networkStats.ReceivedBytes

        # Create output object
        $metrics = [PSCustomObject]@{
            Timestamp          = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            ComputerName       = $env:COMPUTERNAME
            CPUUsagePercent    = $cpuUsage
            MemoryUsagePercent = $memoryUsagePercent
            MemoryUsedGB       = $usedMemory
            MemoryTotalGB      = $totalMemory
            DiskUsagePercent   = $diskUsagePercent
            NetworkBytesSent   = $bytesSent
            NetworkBytesRec    = $bytesReceived
            Status             = "Healthy"
        }

        return $metrics
    }
    catch {
        Write-Error "Failed to retrieve system metrics: $_"
        return $null
    }
}
