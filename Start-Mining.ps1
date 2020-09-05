$MinerPaths = get-content .\MiningApps.json | convertfrom-json
$MiningProofApps = get-content .\MiningProofApps.json | convertfrom-json 
$LogPath = ".\Start-Mining.log"
$RunningProcs = Get-Process
$busytest = @()
$busy = $false

function Write-Log{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $LogEventText
    )
    Write-Warning $LogEventText   
    $temp = New-Object PSObject -Property @{
        LogEventText    = $LogEventText
        DateTime        = Get-Date
    }
    $temp | Select-Object DateTime, LogEventText | export-csv $LogPath -NoTypeInformation -Append       
}

foreach ($exe in $MiningProofApps.exe){
    $temp = New-Object PSObject -Property @{
        ProcessName = $exe
        Running     = ($RunningProcs.ProcessName -contains $exe)
    }
    $busytest += $temp
}

$busy = $busytest.Running | Where-Object {$_-eq $true} | Select-Object -First 1

if(!$busy){
    Write-Log -LogEventText "Found no MiningProofApps Running so resuming mining"
    foreach ($path in $MinerPaths.Path){
        $MiningProcessName = ((Split-Path -Leaf $path) -split ".exe")[0]
        if($RunningProcs.ProcessName -contains $MiningProcessName ){
            Write-Log -LogEventText "$MiningProcessName Already Running"
        }
        else{
            start-process -filepath $path -WorkingDirectory (Split-Path -Parent $path) -Verb runAs
            Write-Log -LogEventText "Started $MiningProcessName"
        }
    }
}
else{
    $GameName = ($busytest | Where-Object {$_.Running -eq $true}).ProcessName
    Write-Log -LogEventText "MiningProofApp $GameName running so halting Miners"
    foreach ($path in $MinerPaths.Path){
        $MiningProcessName = ((Split-Path -Leaf $path) -split ".exe")[0]
        if($RunningProcs.ProcessName -contains $MiningProcessName ){
            $LogEventText = "$MiningProcessName Running so stopping it"
            $script = "Get-process MiningProcessName | Stop-Process" -replace "MiningProcessName", $MiningProcessName
            Start-Process powershell -ArgumentList $script -Verb RunAs
            Write-Log -LogEventText $LogEventText
        }
        else{
            Write-Log -LogEventText "$MiningProcessName not running"
        }
    }
}