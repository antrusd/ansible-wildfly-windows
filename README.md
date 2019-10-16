# Deploy WildFly to Windows - Ansible Playbooks

## How to run

### On Windows Server, run following command to enable WinRM (Windows Remote Management)
```
powershell
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
.\ConfigureRemotingForAnsible.ps1 -Verbose -EnableCredSSP -DisableBasicAuth
```

### On Ansible Runner (mostly Linux based), copy and edit inventories/hosts.examples to suit your environment
```bash
cp inventories/hosts.examples inventories/hosts
vi inventories/hosts
```

### The run following command to install ansible and it's depedencies
```bash
pip installl -r requirements.txt
```

### Finally, run following command to execute ansible playbooks, replace target_hosts variable real target hosts or grouphosts
```bash
ansible-playbook -u <Administrator> -k -e target_hosts=<target_hosts_or_grouphosts> deploy_wildfly.yml
```
