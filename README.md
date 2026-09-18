# Terraform AWS Infrastructure: Multi-OS Server (Ubuntu & Debian)

Repositori ini berisi kode konfigurasi **Terraform** untuk membangun infrastruktur otomatis di **Amazon Web Services (AWS)** pada Region Singapura (`ap-southeast-1`). Infrastruktur ini dirancang dengan standar keamanan dan *best practice* (seperti IMDSv2).

## 📁 Struktur Direktori Project

```text
Automation
   └── Terraform
   │   └── aws
   │      ├── main.tf
   │      ├── provider.tf
   │      ├── terraform.tfstate
   │      └── variables.tf
   └── Ansible
   |   └── dockermonitoring
   |   └── etc
   └── .gitignore

