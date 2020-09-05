function New-ScheduledMiningScript{
    param(    
        [Parameter(Mandatory=$true)] 
        $scriptpath,
        [Parameter(Mandatory=$true)] 
        $WorkingPath,        
        [Parameter(Mandatory=$true)] 
        $user,     
        [Parameter(Mandatory=$true)] 
        $time,    
        [Parameter(Mandatory=$true)] 
        $taskname,    
        [Parameter(Mandatory=$true)] 
        $userprincipal
    )
    $argument = ("-file `""+$scriptpath+"`"")
    $A = New-ScheduledTaskAction -Execute "C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe" -Argument $argument -WorkingDirectory $WorkingPath 
    $T = New-ScheduledTaskTrigger -at $time -Daily ; #-RepetitionInterval $interval -RepetitionDuration $duration
    $S = New-ScheduledTaskSettingsSet;
    $D = New-ScheduledTask -Action $A -Trigger $T -Settings $S;
    Register-ScheduledTask $taskname -InputObject $D -User $user;
    $t = get-scheduledtask -TaskName $taskname;
    $t.Triggers.repetition.Duration = 'PT24H';
    $t.Triggers.repetition.Interval = 'PT05M';
    $t | Set-ScheduledTask -User $user;
}

$ScriptPath = (Get-ChildItem "./start-mining.ps1").FullName
$user = $env:USERNAME
$userprincipal = "$env:USERDOMAIN\$env:USERNAME"
$time =  "00:00"
$TaskName = "Mining Resilience" 
$WorkingPath = Split-Path -Parent $ScriptPath
New-ScheduledMiningScript -taskname $TaskName -scriptpath $ScriptPath -user $user -userprincipal $userprincipal -time $time -WorkingPath $WorkingPath 