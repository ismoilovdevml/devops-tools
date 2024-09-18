# 📋 Jenkins Installation and Uninstallation Playbook

This Ansible playbook allows for the installation and uninstallation of Jenkins across multiple Linux distributions. It includes cleanup procedures that remove all Jenkins-related files, services, and configurations.

## 🛠️ Usage

### Install Jenkins
To install Jenkins on your servers, execute the following command:
```bash
ansible-playbook -i inventory.ini ./install_jenkins.yml
```
# Uninstall Jenkins and Clean Up
To uninstall Jenkins and clean up associated files and services from your servers, use the following command:
```bash
ansible-playbook -i inventory.ini ./uninstall_jenkins.yml
```
This will:
* Stop all Jenkins services.
* Remove Jenkins packages.
* Remove Jenkins repositories and GPG keys.
* Clean up Jenkins directories (logs, cache, data).


# 💻 Supported Linux Operating Systems
This playbook supports the following Linux distributions:
* 🐧 **Debian:** 11,12
* 🐧 **Ubuntu:** 20.04,22.04
* 🐧 **RHEL:** 7,8
* 🐧 **Fedora:** 39,40

# ✅ Tested Operating Systems
The playbook has been tested on the following OS versions:
* ✅**Debian:** 11,12
* ✅**Ubuntu:** 20.04,22.04
* ✅**RHEL:** 7,8

# ⚙️ Supported Ansible Versions
* ✅ ansible [core 2.16.3]
* ❗️ ansible [core 2.17.3] (compatibility issues)

> Note: The playbook assumes you are running Ansible as the root user. For non-root users, ensure you have `become` privileges configured.