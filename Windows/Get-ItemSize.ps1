param(
    [string]$Path = "."
)

$FullPath = Resolve-Path -Path $Path -ErrorAction Stop

if (-not (Test-Path -Path $FullPath -PathType Container)) {
    Write-Error "The specified path is not a valid directory: $FullPath"
    exit 1
}

function Format-FileSize {
    param([long]$size)
    if ($size -lt 1KB) { return "$size B" }
    if ($size -lt 1MB) { return ("{0:F2} KB" -f ($size / 1KB)) }
    if ($size -lt 1GB) { return ("{0:F2} MB" -f ($size / 1MB)) }
    return ("{0:F2} GB" -f ($size / 1GB))
}

function Format-TimeSpan {
    param([timespan]$ts)
    if ($ts.TotalSeconds -lt 1) {
        return "{0:F2} ms" -f ($ts.TotalMilliseconds)
    } elseif ($ts.TotalMinutes -lt 1) {
        return "{0:F2} s" -f $ts.TotalSeconds
    } else {
        return "{0:F2} min" -f $ts.TotalMinutes
    }
}

$items = Get-ChildItem -Path $FullPath -ErrorAction SilentlyContinue
$totalCount = $items.Count

if ($totalCount -eq 0) {
    Write-Host "Directory is empty." -ForegroundColor Green
    return
}

Write-Host "Analyzing directory: $FullPath" -ForegroundColor Cyan
Write-Host ("Found {0} items. Scanning..." -f $totalCount) -ForegroundColor Yellow
Write-Host ("{0,-55} {1,12} {2,10}" -f "Name", "Size", "Time") -ForegroundColor Yellow
Write-Host ("-" * 80)

$index = 0
foreach ($item in $items) {
    $index++

    # --- 不显示进度条，只安静处理 ---
    if ($item.PSIsContainer) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $files = Get-ChildItem $item.FullName -Recurse -File -ErrorAction SilentlyContinue
            $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
            if ($null -eq $totalSize) { $totalSize = 0 }
        } catch {
            $totalSize = 0
        }
        $sw.Stop()
        $timeStr = Format-TimeSpan $sw.Elapsed
        $sizeStr = Format-FileSize $totalSize
        $name = "[DIR] $($item.Name)"
    } else {
        $sizeStr = Format-FileSize $item.Length
        $timeStr = "-"
        $name = "[FILE] $($item.Name)"
    }

    if ($name.Length -gt 53) {
        $name = $name.Substring(0, 50) + "..."
    }

    Write-Host ("{0,-55} {1,12} {2,10}" -f $name, $sizeStr, $timeStr)
}

Write-Host ("-" * 80)
Write-Host "Analysis completed for $totalCount items." -ForegroundColor Green