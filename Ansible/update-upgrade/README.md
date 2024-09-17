# 📋 Update & Install Tools Playbook

This Ansible playbook updates the Linux server system and installs essential tools.

## 🛠️ Usage
To run the playbook, use the following command:

```bash
ansible-playbook -i inventory.ini ./update_upgrade_tools.yml
```

# 💻 Supported Linux Operating Systems
* 🐧 **Debian:** 11,12
* 🐧 **Ubuntu:** 20.04,22.04
* 🐧 **RHEL:** 7,8
* 🐧 **Fedora:** 39,40

# ✅ Tested Operating Systems

* ✅**Debian:** 11,12
* ✅**Ubuntu:** 20.04,22.04
* ✅**RHEL:** 7,8

# ⚙️ Supported Ansible Versions
* ✅ ansible [core 2.16.3]
* ❗️ ansible [core 2.17.3] (compatibility issues)

> Note: The playbook assumes you are running Ansible as the `root` user.