# Invoke-SSH-Parallel
run multiple SSH to all ESXi in the Cluster and run a command

# ESXi SSH Command Executor 🚀

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Module](https://img.shields.io/badge/Module-posh--ssh-green)

This PowerShell script leverages the `posh-ssh` module to execute custom SSH commands on multiple VMware ESXi hosts within a cluster.

## Prerequisites

- **PowerShell Version:** 5.1 or later
- **Module Installation:**

    ```powershell
    Install-Module -Name posh-ssh
    ```

## Usage

1. Open the PowerShell script in your favorite editor.
2. Set the required parameters such as `$user`, `$paswd`, and customize the `$CommandTXT` variable.
3. Run the script.

### Parameters

- **`$clusterName`**: (Optional) If not provided, the script will prompt you to select a cluster.
- **`$user`**: The ESXi username for SSH connection (default is 'root').
- **`$paswd`**: The ESXi password for SSH connection (default is 'VMware1!'). If not provided, the script securely prompts you to enter the password.
- **`$CommandTXT`**: Customize this variable with the desired SSH command(s) to execute on the ESXi hosts.

### Example

```powershell
# Execute a custom SSH command on the ESXi hosts in the selected cluster
.\YourScriptName.ps1
