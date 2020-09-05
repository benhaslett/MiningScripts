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
        start-process -filepath $path -WorkingDirectory (Split-Path -Parent $path)
    }
}
else{
    Write-host "Busy Leave me alone"
}