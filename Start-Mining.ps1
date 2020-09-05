$MinerPaths = get-content .\MiningApps.json | convertfrom-json
$MiningProofApps = get-content .\MiningProofApps.json | convertfrom-json 
$RunningProcs = Get-Process
$busytest = @()
$busy = $false

foreach ($exe in $MiningProofApps.exe){
    $temp = "" | Select-Object ProcessName, Running
    $temp.ProcessName = $exe
    $temp.Running = $RunningProcs.ProcessName -contains $exe
    $busytest += $temp
}

$busy = $busytest.Running | Where-Object {$_-eq $true} | Select-Object -First 1

if(!$busy){
    foreach ($path in $MinerPaths.Path){
        $MiningProcessName = ((Split-Path -Leaf $path) -split ".exe")[0]
        if($RunningProcs.ProcessName -contains $MiningProcessName ){
            Write-Information  "$MiningProcessName Already Running"
        }
        else{
            start-process -filepath $path -WorkingDirectory (Split-Path -Parent $path) -Verb runAs
        }
    }
}
else{
    $GameName = ($busytest | Where-Object {$_.Running -eq $true}).ProcessName
    Write-Information  "Busy running $GameName Leave me alone"
}