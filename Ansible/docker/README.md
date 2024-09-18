# 📋 Docker Installation and Uninstallation Playbook

This playbook installs Docker on multiple Linux operating systems and provides a method to uninstall Docker, including the cleanup of associated files and directories.

## 🛠️ Usage

### Install Docker
Run the following command to install Docker on your servers:
```bash
ansible-galaxy collection install community.general
ansible-playbook -i inventory.ini ./install_docker.yml
```
# Clean up and Uninstall Docker
To clean up and uninstall Docker from your servers, use the following command:
```bash
ansible-playbook -i inventory.ini ./uninstall_docker.yml
```
This will:
* Stop all Docker services.
* Remove all Docker containers, images, volumes, and associated files.
* Remove the Docker GPG keys and repository sources.
* Uninstall Docker packages.
* Remove Docker user and group.


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