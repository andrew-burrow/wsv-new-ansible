# Ansible playbooks for ACE and MQ maintenance

-   **Precis:** Ansible playbooks for ACE and MQ maintenance
-   **Wiki:** TBA
-   **Authors:** Andrew Burrow
-   **Contact:** andrew.burrow@syntegrity.com.au

## Introduction

This repository contains Ansible roles and playbooks to install and maintain
IBM ACE and MQ.  The objective is to be able to maintain the suit of hosts and
environments that WorkSafe provide to host ACE and MQ.  The tool used to
provision and verify each host and environment is [Ansible][ansible-ref].

The remainder of this README is organised as follows.

-  *Quick start guide* describes the steps to get started running playbooks
   tailored for one of the platforms
-  *Repository layout* describes how the components of the repository are
   organised into folders

[ansible-ref]: http://www.ansible.com/

## Quick start guide

To quickly get started with the Ansible roles and playbooks in this repository
take the following setup steps.

1. Select a platform from the collection in [platforms
   README][platforms-README].

2. Follow the instructions in *Running the playbooks* from your selected
   platform.  This covers the platform specifics of running the playbooks.
   Typically, this amounts to installing Ansible, and making a local copy of
   this repository

Good luck!

## Repository layout

The top level layout of the repository distinguishes platform specific
playbooks, and shared configuration modules in the form of Ansible roles.  To
work on a particular platform, you must execute the playbooks from within its
folder as described in README file for the particular platform.  The top level
layout is as follows.

-  `README.md`

    This file

-  `docs/`

    Documentation required to understand the design of the Ansible source code
    and how the platforms are structured for repeatable builds.

    See [docs README][docs-README] for an index of the documentation

-   `platforms/`

    Folder containing a subfolder for each platform, e.g, `localhost` to
    execute playbooks on the local host when the Ansible Automation Platform
    (AAP) service is not available.

    See [platforms README][platforms-README] for further details

-   `roles/`

    Folder containing a subfolder for each Ansible role.  Each subfolder
    defines or acts on a software capability in and idempotent manner.  For
    example, the `ibm_mq_define` role defines the parameters for all IBM MQ
    roles, and the `ibm_mq_environment` role installs IBM MQ on the host for a
    particular environment

    See [roles README][roles-README] for further details

[docs-README]: ./docs/README.rst
[platforms-README]: ./platforms/README.md
[roles-README]: ./roles/README.rst
