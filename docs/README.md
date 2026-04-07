# ANSIBLE ROLE ORGANIZATION APPROACH

## Overview

We organize Ansible automation into **capability families** where each family
manages a distinct software product or system concern. Each capability family
consists of multiple roles that work together through a disciplined parameter
contract.

## Capability Family Structure

A capability family follows the naming pattern `VENDOR_SOFTWARE_ROLE`:

    ibm_mq_define
    ibm_mq_host
    ibm_mq_environment

    ibm_ace_define
    ibm_ace_host
    ibm_ace_environment

Each family contains:

**Define role** (`CAPABILITY_define`)

- `defaults/main.yml` — All parameters with extensive comments documenting the
  interface
- `vars/main.yml` — Computed variables derived from parameters

**Action roles** (`CAPABILITY_*`)

- `meta/main.yml` — Documents role purpose and declares dependency on define
  role
- `tasks/main.yml` — Implements idempotent actions on the capability

## Parameter Contract Discipline

**All parameters live in the define role.** Action roles consume variables but
never define new parameters.

**Variable naming uses capability prefix:**

    ibm_mq_mqm_uid
    ibm_mq_base_dir
    ibm_ace_aceadmin_uid
    ibm_ace_base_dir

The prefix makes variable provenance immediately obvious. To understand any
variable, read `CAPABILITY_define/defaults/main.yml`.

**Computed variables separate from parameters.** Variables derived from
parameters go in `CAPABILITY_define/vars/main.yml`, keeping the parameter
interface clean.

## Role Dependencies

Action roles declare their dependency on the define role in `meta/main.yml`:

    dependencies:
      - role: ibm_mq_define

Ansible ensures the define role runs first, establishing the parameter
contract before any action occurs. This makes role relationships explicit and
prevents ordering errors.

## Playbook Construction

To create a playbook:

1. Read `meta/main.yml` files in the capability family to understand what each
   role does
2. Choose which action roles are needed
3. Concatenate relevant sections from `CAPABILITY_define/defaults/main.yml`
   into the playbook `vars:` block (discarding header comments)
4. List chosen roles

Example playbook:

    ---
    - hosts: localhost
      vars:
        # From ibm_mq_define/defaults/main.yml
        ibm_mq_base_dir: /opt/ibm
        ibm_mq_mqm_uid: 501
        ibm_mq_environment: ts1
        ibm_mq_queue_managers:
          - name: ATS1J0201
            port: 1501
      roles:
        - ibm_mq_host
        - ibm_mq_environment

The playbook is thin composition. Logic stays in roles. Variables come from
define role documentation.

## Benefits

**Clear separation of concerns**

Each capability family is self-contained. Adding IBM APIC doesn't affect IBM
MQ roles. Products can be added or removed independently.

**Explicit parameter contracts**

The define role documents every parameter. There's one place to look for
variable definitions. No parameter pollution across roles.

**Reusable roles**

Action roles are generic implementations. The same `ibm_mq_environment` role
works for dev, test, and production by varying parameters.

**Easy testing**

Roles can be tested in isolation. Mock parameters in test playbooks. Verify
idempotence without full system deployment.

**Natural transition from localhost to networked**

Initial development runs on localhost with variables in playbook. Production
moves variables to inventory (`group_vars`, `host_vars`) without changing
roles. The same roles work in both contexts.

**Discoverable interface**

Reading `meta/main.yml` files shows role purpose and dependencies. Reading
`defaults/main.yml` shows complete parameter interface with documentation.
Building playbooks becomes mechanical.

**Idempotent actions**

Each action role can run repeatedly without harm. This supports iterative
development and operational resilience.

**Computed variables stay clean**

Derived calculations in `vars/main.yml` don't clutter the parameter interface.
Users set intent through parameters. Roles compute implementation details.

## Application to IBM Software

**Host-level setup (run once per host):**

    ibm_mq_host       # Creates mqm account, /opt/ibm base
    ibm_ace_host      # Creates aceadmin account, /opt/ibm base

These roles establish prerequisites shared across all environments on the
host.

**Environment-level setup (run per environment):**

    ibm_mq_environment    # Installs MQ to /opt/ibm/ts1/mqm, creates queue
                          # managers
    ibm_ace_environment   # Installs ACE to /opt/ibm/ts1/ace, creates
                          # integration nodes

These roles are executed multiple times with different environment parameters
to establish multiple environments on a single host.

The current WorkSafe installation has multiple environments (ts1, ts2, prod)
on single hosts. The role structure naturally supports this:

1. Run host-level roles once
2. Run environment-level roles multiple times with different
   `ibm_mq_environment` / `ibm_ace_environment` values

**Parameter flexibility**

Parameters like `ibm_mq_mqm_uid` use `default(omit)` pattern in tasks:

    uid: "{{ ibm_mq_mqm_uid | default(omit) }}"

If the parameter is defined, it's used. If undefined, Ansible omits it and the
system assigns values automatically. This gives clients flexibility without
requiring parameters for every detail.

## Repository Organization

    ansible-ibm-software/
      roles/
        ibm_mq_define/
          defaults/main.yml
          vars/main.yml
        ibm_mq_host/
          meta/main.yml
          tasks/main.yml
        ibm_mq_environment/
          meta/main.yml
          tasks/main.yml
        ibm_ace_define/
          defaults/main.yml
          vars/main.yml
        ibm_ace_host/
          meta/main.yml
          tasks/main.yml
        ibm_ace_environment/
          meta/main.yml
          tasks/main.yml
      playbooks/
        setup-host.yml
        setup-mq-environment.yml
        setup-ace-environment.yml

Playbooks are examples showing role composition. Users can create custom
playbooks for their specific needs.

## Summary

This approach creates maintainable, reusable automation through disciplined
parameter contracts and role composition. It scales from single-host
development to multi-host production without restructuring. It supports
incremental development and operational flexibility while maintaining clear
interfaces and explicit dependencies.
