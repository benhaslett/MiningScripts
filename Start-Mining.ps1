cd C:\Users\benha\OneDrive\Git\MiningScripts-Divorce
$MinerPaths = get-content .\MiningApps.json | convertfrom-json
$MiningProofApps = get-content .\MiningProofApps.json | convertfrom-json 
$LogPath = ".\Start-Mining.log"
$RunningProcs = Get-Process
$busytest = @()
$busy = $false
$efficiency = ((Get-Content C:\Users\benha\OneDrive\Mining\Ethereum\trex0.20.3\logs.log -Tail 50 | Select-String "GPU #0: Gigabyte NVIDIA RTX 3070" | select -last 1) -split "E:" -split "kH/W")[1]
$efficiencytarget = 370


$config = Import-LocalizedData -filename config.psd1
$bridge = ("http://" + $config.ip)
$user = $config.user

$officetemp = ((Invoke-WebRequest "$bridge/api/$user/sensors/34" -UseBasicParsing).content | convertfrom-json).state.temperature

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

if(!$busy -and $officetemp -le "2900"){
    if($efficiency -lt $efficiencytarget){
        Write-Log -LogEventText "efficiency($efficiency) below efficiencytarget($efficiencytarget) so restarting Afterburner with profile 1"
        $script = "Get-process MSIAfterburner | Stop-Process"
        Start-Process powershell -ArgumentList $script -Verb RunAs -Wait
        & 'C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe' -profile1
    }
    Write-Log -LogEventText "Found no MiningProofApps and temp is $officetemp Running so resuming mining"
	$MinerPaths | Select-Object -Property path, startcmd | ForEach-Object {
        $temp = $_
        $MiningProcessName = ((Split-Path -Leaf $_.path) -split ".exe")[0]
        if($RunningProcs.ProcessName -contains $MiningProcessName ){
            Write-Log -LogEventText "$MiningProcessName Already Running"
        }
        else {
            if ($null -ne $temp.startcmd) {
				start-process -filepath $temp.startcmd -WorkingDirectory (Split-Path -Parent $temp.startcmd)
				} else {
				start-process -filepath $temp.path -WorkingDirectory (Split-Path -Parent $temp.path) -Verb runAs
				}
            Write-Log -LogEventText "Started $MiningProcessName temp is $officetemp"
        }
    }
}
else{
    $GameName = ($busytest | Where-Object {$_.Running -eq $true}).ProcessName
    Write-Log -LogEventText "MiningProofApp $GameName running and temp is $officetemp so halting Miners "
    $mining = (Get-Content $LogPath -Tail 8 | Select-String "MiningProofApp" | select -last 2  | Select-String "found no").count
    $gaming = (Get-Content $LogPath -Tail 8 | Select-String "MiningProofApp" | select -last 2  | Select-String "halting").count
    if($mining -eq 1 -and $gaming -eq 1){
        Write-Log -LogEventText "We think a game just started so restarting Afterburner with profile 5"
        $script = "Get-process MSIAfterburner | Stop-Process"
        Start-Process powershell -ArgumentList $script -Verb RunAs -Wait
        & 'C:\Program Files (x86)\MSI Afterburner\MSIAfterburner.exe' -profile5
    }
    foreach ($path in $MinerPaths.Path){
        $MiningProcessName = ((Split-Path -Leaf $path) -split ".exe")[0]
        if($RunningProcs.ProcessName -contains $MiningProcessName ){
            $LogEventText = "$MiningProcessName Running so stopping it"
            $script = "Get-process MiningProcessName | Stop-Process" -replace "MiningProcessName", $MiningProcessName
            Start-Process powershell -ArgumentList $script -Verb RunAs
            Write-Log -LogEventText $LogEventText
        }
        else{
            Write-Log -LogEventText "$MiningProcessName not running temp is $officetemp"
        }
    }
}