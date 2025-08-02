n8n GCP Terraform Starter Kit
===================================================

This repository contains Terraform code to deploy a production-ready, self-hosted n8n instance on Google Cloud Platform (GCP).

This project automates the provisioning of a GCP virtual machine and uses a startup script to configure a complete n8n stack using Docker Compose.

Core Features
-------------

-   **Automated Infrastructure:** Deploys all necessary GCP resources using Terraform.

-   **Production-Ready Stack:**

    -   n8n (pinned to a stable version)

    -   PostgreSQL Database

    -   Traefik Reverse Proxy for automatic HTTPS/SSL

-   **Infrastructure as Code:** A repeatable and versionable deployment pipeline.

Prerequisites
-------------

Before you begin, you must have the following:

1.  A Google Cloud Platform (GCP) account with a project created.

2.  A registered domain name.

3. **GCP Cloud DNS configured**: This script requires that you have a Managed Public Zone set up in GCP Cloud DNS for your domain. **The automation will fail if this is not configured.**

4.  The following APIs enabled in your GCP project: `Compute Engine API`, `Cloud DNS API`.

5.  A GCP Service Account with `Compute Admin` and `DNS Administrator` roles.

6.  [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli "null") and the [gcloud CLI](https://cloud.google.com/sdk/docs/install "null") installed locally.

How to Use
----------

1.  Clone this repository to your local machine.

2.  Navigate into the `terraform/` directory.

    ```
    cd terraform

    ```

3.  Create a `terraform.tfvars` file. You can copy the `terraform.tfvars.example` file as a template.

4.  Fill in the required variables in your `terraform.tfvars` file (project ID, credentials file path, domain info, etc.).

5.  Initialize Terraform:

    ```
    terraform init

    ```

6.  Apply the Terraform plan to deploy the infrastructure:

    ```
    terraform apply

    ```

Review the plan and type `yes` when prompted. The deployment will take approximately 5-10 minutes.

Disclaimer
----------

This open-source project is provided as-is. You are responsible for managing your own cloud costs, security, and maintenance.

⭐ Want a More Complete Solution?
--------------------------------

This repository provides the core code to get you started. If you're looking for a more polished and guided experience, check out the [**Ultimate n8n Self-Host Starter Kit on Gumroad**](https://aut0mate.gumroad.com/l/bulzzl "null").

The paid starter kit includes:

-   **Comprehensive Documentation:** Detailed, step-by-step guides for every part of the process.

-   **In-Depth Troubleshooting Guide:** Solutions for all the common errors and "gotchas" we solved during development, saving you hours of debugging.

-   **Step-by-Step Upgrade Path:** Clear instructions on how to safely update your n8n instance to new versions without losing data.

-   **Automated Backups:** A fully automated backup system for your database and files, complete with a restore guide.

-   **Email Support:** Direct access to get help if you run into any issues.
