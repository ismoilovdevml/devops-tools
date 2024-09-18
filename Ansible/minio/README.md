# 📋 MinIO Object Storage Installation Playbook

This playbook installs MinIO as a binary on servers using the **Single-Node Single-Drive** installation method.

## 🛠️ Usage

In the `vars.yml` file, the following variables should be defined:

```yml
---
minio_directory: /mnt/data
minio_admin_user: admin
minio_admin_user_password: wo#*4fd-LDSsgsa
```
# Install MinIO
Run the following command to install MinIO on your servers:
```bash
ansible-playbook -i inventory.ini ./install_minio.yml
```
# Clean up and Uninstall MinIO
To clean up and uninstall MinIO, use the following command:
```bash
ansible-playbook -i inventory.ini ./uninstall_minio.yml
```

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