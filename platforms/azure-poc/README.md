# Ansible playbooks for POC work in Azure

-   **Precis:** Ansible playbooks for POC work in Azure
-   **Wiki:** TBA
-   **Authors:** Andrew Burrow
-   **Contact:** andrew.burrow@syntegrity.com.au

This folder collects a proof of concept in Azure for an ACE and MQ
environment.  The playbooks setup a host for ACE and MQ maintenance and then
install an environment.  This is to support development of the Ansible roles.
It is not intended to be used as an ACE or MQ environment.

The remainder of this README is organised as follows.

-  *Folder layout* describes how Ansible roles are organised into subfolders

## Folder layout

The folder layout comprises a subfolder for each Ansible role.  These role
subfolders are named according to the patterns shown below.

-   `README.md`

    This file

~/WorkSpace/wsv-new-ansible/platforms/azure-poc/setup-host.yml
~/WorkSpace/wsv-new-ansible/platforms/azure-poc/setup-mq-host.yml
~/WorkSpace/wsv-new-ansible/platforms/azure-poc/setup-ace-host.yml
~/WorkSpace/wsv-new-ansible/platforms/azure-poc/install-environment.yml
~/WorkSpace/wsv-new-ansible/platforms/azure-poc/install-mq-environment.yml
~/WorkSpace/wsv-new-ansible/platforms/azure-poc/install-ace-environment.yml
