# Platforms furnished with playbooks for ACE and MQ maintenance

-   **Precis:** Platforms furnished with playbooks for ACE and MQ maintenance
-   **Wiki:** TBA
-   **Authors:** Andrew Burrow
-   **Contact:** andrew.burrow@syntegrity.com.au

This folder collects the platform specific collections of Ansible playbooks
for ACE and MQ maintenance.

The remainder of this README is organised as follows.

-  *Folder layout* describes how platforms are organised into subfolders

## Folder layout

The folder layout comprises a subfolder for each platform.  These platform
subfolders are named according to the patterns shown below.

-   `README.md`

    This file

-   `{WHERE}/`

    Subfolder containing Ansible playbooks that deploy implement ACE and MQ
    maintenance on the particular platform, e.g., `localhost` for playbooks
    that can be run directly on the host to be configured or maintained.
