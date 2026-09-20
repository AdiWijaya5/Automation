# Terraform AWS Infrastructure: Multi-OS Server (Ubuntu & Debian)

Repositori ini berisi kode konfigurasi **Terraform** untuk membangun infrastruktur otomatis di **Amazon Web Services (AWS)** pada Region Singapura (`ap-southeast-1`). Infrastruktur ini dirancang dengan standar keamanan dan *best practice* (seperti IMDSv2).

## 📁 Struktur Direktori Project

```text
Automation
   └── Terraform
   │   └── aws
   │      ├── main.tf
   │      ├── provider.tf
   │      ├── data.tf
   │      └── variables.tf
   └── Ansible
   │   ├── Inventory
   │   ├── ansible.cfg
   │   ├── config
   │   │   └── prometheus.yml
   │   ├── create-user.yaml
   │   ├── dockermonitoring
   │   │   ├── compose-monitoring.yml
   │   │   └── node-exporter.yml
   │   ├── group_vars
   │   │   ├── all
   │   │   └── webservers.yaml
   │   ├── instal-nginx.yaml
   │   ├── instalasi-docker.yaml
   │   ├── install-certbot.yaml
   │   ├── nginx-monitoring.yaml
   │   ├── start-exporter.yaml
   │   └── start-monitoring.yaml
   └── .gitignore

