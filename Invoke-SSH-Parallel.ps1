#requires -Modules posh-ssh
if (!$clusterName) {
    $clusterName = get-cluster | Out-GridView -PassThru 
}
# $user = $null
# $pswdSec = $null
# $paswd = $null

$user = 'root'
$paswd = 'VMware1!'

if (!$paswd) {
    $paswd = Read-Host -Prompt "ESXI Password" -MaskInput
}
$pswdSec = ConvertTo-SecureString -String $paswd -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($User, $pswdSec)

$code = {
    param(
        [string]$EsxName,
        $cred,
        [string]$CommandTXT
    )
    $ssh = New-SSHSession -ComputerName $EsxName -Credential $cred -AcceptKey -Force
    if ($ssh) {
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command $CommandTXT -TimeOut 30 | select -ExpandProperty Output  
        Remove-SSHSession -SessionId $ssh.SessionId | Out-Null
    } else {
        write-host "unable to connect to $EsxName"
    }
}

function Invoke-SSHCommand {
    param (
        $clusterName,
        $cred,
        $CommandTXT
    )
    $jobs = @()
    Get-Cluster -Name $clusterName | Get-VMHost -PipelineVariable esx |
    ForEach-Object -Process {
        # Write-Host -ForegroundColor Blue -NoNewline "$($esx.Name)"
        if ((Get-VMHostService -VMHost $esx).where({ $_.Key -eq 'TSM-SSH' }).Running) {
            # Write-Host -ForegroundColor Green " SSH running"
            $jobs += Start-Job -ScriptBlock $code -Name "SSH Job" -ArgumentList $($esx.Name),$cred, $CommandTXT
        }
    }
    Wait-Job -Job $jobs
    Receive-Job -Job $jobs
}

# $CommandTXT = 'tail /var/log/syslog.log -n 20'
# $CommandTXT = 'cat /var/log/auth.log | grep "Authentication failure for root from"'
# $CommandTXT = 'tail /var/log/vmkwarning.log -n 20'
# $CommandTXT = 'pam_tally2 --user root --reset'
# $CommandTXT = 'esxcli network nic stats get -n vmnic0 ; esxcli network nic stats get -n vmnic1'

$CommandTXT = 'vmkping -I vmk1 192.168.1.1 -d -s 8972 -c 2 &  vmkping -I vmk1 192.168.1.2 -d -s 8972 -c 2 & vmkping -I vmk1 192.168.1.3 -d -s 8972 -c 2 & vmkping -I vmk1 192.168.1.4 -d -s 8972 -c 2'
Invoke-SSHCommand -CommandTXT $CommandTXT -cred $cred -clusterName $clusterName 
