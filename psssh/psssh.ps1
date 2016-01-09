Param (
    $key="null", #ssh key 
    $p=22, #port 
    $l, #login name
    $i, #key file  
    [parameter(position=0)] $hostname,
    [parameter(position=1)] $command
)

if (!$hostname)
{
    exit ;
}

#check if Ssh-Sessions is installed 
if (Get-Module -ListAvailable SSH-Sessions)
    {
        Import-Module SSH-Sessions
    } else {
        Write-Host "please install SSH-Sessions in $Env:PSModulePath"
    }
    

# check if the user used username@hostname notation in the $hostname variable or used -l username if not ask for username 
if ($hostname -like "*@*")
    {
        $options = $hostname.Split("@")
        $username = $options[0]
        $hostname = $options[1]
    } elseif ($l) {
        $username = $l
    } else {
        $username = Read-Host "what's your username"
    }
    
$output = Resolve-DnsName $hostname -ErrorVariable notvalid -ErrorAction SilentlyContinue

if ($notvalid)
    {Write-Host $hostname is a not valid hostname. ; exit }

New-SshSession -ComputerName $hostname -Username $username

if (!$command)
    {Enter-SshSession -ComputerName $hostname} 
    else
    {Invoke-SshCommand -ComputerName $hostname -Command $command}



$output = Remove-SshSession -ComputerName $hostname