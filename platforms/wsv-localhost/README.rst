# Interim Ansible playbooks for ACE and MQ in the EIP

-   **Precis:** Ansible playbooks for POC work in Azure
-   **Wiki:** TBA
-   **Authors:** Andrew Burrow
-   **Contact:** andrew.burrow@syntegrity.com.au

This folder collects playbooks used to establish the EIP environments, while
awaiting delivery of Ansible Automation Platform (AAP).  The playbooks cover
each of the hosts, and for each host, each of its environments.  Hence, there
are many playbooks.  This is a special way of running an Ansible playbook.
Typically the playbook is run from a networked host that connects via SSH to
the host to be configured.  We are calling this the *localhost* playbooks,
because they are run locally instead.

The remainder of this README is organised as follows.

-  *Folder layout* describes how Ansible roles are organised into subfolders

## Folder layout

The folder layout comprises a subfolder for each Ansible role.  These role
subfolders are named according to the patterns shown below.

-   `README.md`

    This file

-   `setup-mq-host-{HOST}.yml`

    Perform initial configuration on the {HOST} to allow installation of the
    MQ environments.  This typically means establishing user accounts

-   `setup-ace-host-{HOST}.yml`

    Perform initial configuration on the {HOST} to allow installation of the
    ACE environments.  This typically means establishing user accounts

-   `setup-mq-environment-{HOST}-{ENV}.yml`

    Install MQ on the {HOST} for the {ENV}, including establishing the
    queue managers

-   `setup-ace-environment-{HOST}-{ENV}.yml`

    Install ACE on the {HOST} for the {ENV}, including establishing the
    integration servers

## Running the playbooks

TODO The install prerequisites, e.g., install Ansible

TODO Copying the repository to the ACE/MQ host for running as a localhost
playbook

TODO Example of running a playbook
