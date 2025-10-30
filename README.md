# 🚀 AWS Infrastructure as Code (IaC) - Terraform

![Terraform](https://img.shields.io/badge/Terraform-v1.8+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-Cloud-orange?logo=amazon-aws&logoColor=white)
![IaC](https://img.shields.io/badge/Infrastructure-as--Code-success)
![License](https://img.shields.io/badge/License-MIT-blue)
![Build](https://img.shields.io/github/actions/workflow/status/RibunLoc/Terraform_Module/terraform.yml?label=CI/CD&logo=github)
## Giới Thiệu Chung

Kho lưu trữ này chứa toàn bộ định nghĩa hạ tầng AWS (Infrastructure as Code - IaC) của dự án, được quản lý bằng **Terraform**. Các tài nguyên được tổ chức theo kiến trúc module để đảm bảo tính tái sử dụng cao, đồng bộ giữa các môi trường (`dev`, `staging`, `prod`) và dễ dàng kiểm soát phiên bản.

## 🎖️ Badges Trạng thái

Các badge sau đây thể hiện trạng thái mới nhất của quá trình kiểm tra code và triển khai.

| Loại | Badge | Mục đích |
| :--- | :--- | :--- |
| **Kiểm tra Cú pháp** | [](https://github.com/RibunLoc/Terraform_Module/actions/workflows/tf-validate.yml) | Đảm bảo code Terraform hợp lệ trước khi lập kế hoạch. |
| **Trạng thái Triển khai** | [](https://github.com/RibunLoc/Terraform_Module/actions/workflows/tf-apply-dev.yml) | Trạng thái triển khai tự động tới môi trường **Development**. |
| **Bảo mật (Checkov/TFLint)** | []() | Đảm bảo cấu hình tuân thủ các tiêu chuẩn bảo mật của AWS. |
| **Phiên bản Terraform** | [](https://www.terraform.io/) | Chỉ rõ phiên bản Terraform đang sử dụng. |

-----

## 🏗️ Cấu Trúc Thư Mục

Dự án được chia thành các thư mục chính:

```
.
├── environments/
│   ├── dev/               # Root Module cho môi trường Development
│   │   ├── main.tf
│   │   └── variables.tf
│   └── prod/              # Root Module cho môi trường Production
│       ├── main.tf
│       └── variables.tf
├── modules/
│   ├── vpc/               # Module tái sử dụng: Tạo VPC, Subnets, NAT Gateway, Endpoints.
│   ├── ec2-instance/      # Module tái sử dụng: Tạo EC2, SG, IAM Role cơ bản.
│   ├── s3-bucket/         # Module tái sử dụng: Tạo S3, CORS, Lifecycle.
│   ├── alb/               # Module tái sử dụng: Tạo ALB, Target Group, Listeners.
│   ├── cloud-watch/       # Module tái sử dụng: Tạo Log Group, Metric Alarms.
|   ├── RDS                # Module tái sử dụng: RDS
|   └── iam-profile-creator # Module: IAM 
└── scripts/               # Chứa các file User Data (.sh.tpl) và các script phụ trợ.
```

-----

## 📚 Quy Trình Hoạt động

Mỗi môi trường được quản lý độc lập bằng cách sử dụng các file state riêng biệt:

1.  **`modules/`**: Chứa các khối xây dựng (building blocks) logic. Các file trong đây **KHÔNG** chứa cấu hình cụ thể của môi trường nào.
2.  **`environments/`**: Nơi các Module được gọi, ghép nối và cấu hình bằng các giá trị đầu vào (variables) cụ thể cho môi trường đó.
3.  **CI/CD**: Quá trình triển khai được tự động hóa (GitHub Actions/GitLab CI) để chạy `terraform plan` và `terraform apply` cho từng môi trường khi code được merge vào nhánh chính.

-----

## ⚙️ Thiết lập Local

Để làm việc với repository này trên máy cục bộ, bạn cần:

1.  **Cài đặt Terraform:** Phiên bản 1.8 trở lên.

2.  **Cấu hình AWS CLI:** Đảm bảo bạn đã cấu hình hồ sơ (profile) hoặc biến môi trường với Access Key và Secret Key hợp lệ.

3.  **Khởi tạo:** Chuyển đến thư mục môi trường (`cd environments/dev`) và chạy:

    ```bash
    terraform init -backend-config="config/dev-backend.conf"
    ```

4.  **Lập kế hoạch:**

    ```bash
    terraform plan
    ```