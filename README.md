# Terraform AWS Infrastructure: Multi-OS Server (Ubuntu & Debian)

Repositori ini berisi kode konfigurasi **Terraform** untuk membangun infrastruktur otomatis di **Amazon Web Services (AWS)** pada Region Singapura (`ap-southeast-1`). Infrastruktur ini dirancang dengan standar keamanan dan *best practice* (seperti IMDSv2).

---

# 🏗️ Arsitektur Infrastruktur

Konfigurasi ini akan membuat resource berikut secara otomatis:
1. **VPC Kustom**: Menggunakan blok CIDR `10.0.0.0/16` lengkap dengan *Internet Gateway* dan *Route Table*.
2. **Public Subnet**: Subnet publik (`10.0.1.0/24`) dengan fitur *Auto-assign Public IP*.
3. **Security Group (Firewall)**: Mengizinkan akses masuk (*Inbound*) untuk SSH (Port 22), HTTP (80), HTTPS (443), serta aturan terbuka untuk pengujian.
4. **Compute Instances (EC2)**:
   * **Server 1**: Ubuntu 24.04 LTS (`t3.micro`)
   * **Server 2**: Debian 11 (`t3.micro`)
5. **Block Storage (EBS Volume)**: 2 buah disk tambahan masing-masing berukuran **15 GB** yang otomatis di-attach ke masing-masing server (`/dev/xvdf`).
6. **Elastic IP (Static IP)**: IP publik statis yang diikat ke masing-masing server agar IP tidak berubah saat server direstart.
7. **Security Feature**: Memperketat keamanan metadata server dengan mewajibkan **IMDSv2 (`http_tokens = "required"`)**.

---


## 📁 Struktur Direktori Project

```text
Automation
   └── Terraform
   │   └── aws
   │      ├── main.tf
   │      ├── provider.tf
   │      ├── terraform.tfstate
   │      ├── terraform.tfstate.backup
   │      └── variables.tf
   └── .gitignore

