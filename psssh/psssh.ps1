if (Get-Module -ListAvailable SSH-Sessions)
    {
        Import-Module SSH-Sessions
    } else {
        Write-Host "please install SSH-Sessions in $Env:PSModulePath"
    }
#param {
#    $key #ssh key 
#    $l #login name 
#}

[string] $hostname = $args[0]

if ($hostname -like "*@*")
    {
        $options = $hostname.Split("@")
        $username = $options[0]
        $hostname = $options[1]
    }
    
New-SshSession -ComputerName $hostname -Username $username 

Enter-SshSession -ComputerName $hostname

Remove-SshSession -ComputerName $hostname