# AKS Terraform Deployment: Screenshots & Notes

## Overview
This document contains screenshots and notes from the AKS cluster deployment using Terraform. It demonstrates the successful execution of the Terraform plan and apply commands, as well as the resolution of common issues (such as CIDR overlap).

## Screenshots

### 1. Terraform Plan Output
![Terraform Plan Output](./screenshots/terraform-plan.png)

### 2. Terraform Apply Output
![Terraform Apply Output](./screenshots/terraform-apply.png)

## Notes
- The network_profile was updated to avoid CIDR overlap errors.
- All resources were created successfully after the fix.
- Environment variables for Azure authentication were exported before running Terraform.

---

> For more details, see the Terraform configuration files and logs in this repository.
