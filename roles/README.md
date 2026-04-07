# Ansible roles for ACE and MQ maintenance

-   **Precis:** Ansible roles for ACE and MQ maintenance
-   **Wiki:** TBA
-   **Authors:** Andrew Burrow
-   **Contact:** andrew.burrow@syntegrity.com.au

This folder collects the Ansible roles that factorize ACE and MQ maintenance.
The platforms folder contains playbooks composed of these roles, organised
according to the platform from which the playbook is run.

The remainder of this README is organised as follows.

-  *Folder layout* describes how Ansible roles are organised into subfolders
-  *Using a role* outlines how to read the source code for a role, and how to
   incorporate a role into the Ansible playbooks for a platform

## Folder layout

The folder layout comprises a subfolder for each Ansible role.  These role
subfolders are named according to the patterns shown below.

-   `README.md`

    This file

-   `{VENDOR}_{SOFTWARE}_define/`

    Subfolder containing Ansible role that defines the parameters common to all
    actions on the `{VENDOR}_{SOFTWARE}` capability, e.g, `ibm_mq_define`
    defines the parameters to configure IBM MQ

-   `{VENDOR}_{SOFTWARE}_{ACTION}/`

    Subfolder containing Ansible role that performs an idempotent action on the
    `{VENDOR}_{SOFTWARE}` capability, e.g, `ibm_mq_environment` installs MQ for
    a specified environment

## Using a role

To create a playbook:

1.  Read `meta/main.yml` files in the capability family to understand what each
    role does
2.  Choose which action roles are needed
3.  Concatenate relevant sections from
    `{VENDOR}_{SOFTWARE}_define/defaults/main.yml` into the playbook `vars:`
    block (discarding header comments)
4.  List chosen roles using the dependencies information in the
    `meta/main.yml` files for ordering information
