# Dự án Phát hiện Ví Sybil trên Mạng lưới Aptos

Dự án này sử dụng Machine Learning để phân tích các hoạt động on-chain và dự đoán xem một ví Aptos có phải là ví Sybil (đáng ngờ) hay không. Mô hình được huấn luyện dựa trên các đặc trưng về lịch sử giao dịch, số dư, và các tương tác của ví.

## Mục lục
- [Tính năng](#tính-năng)
- [Cấu trúc Dự án](#cấu-trúc-dự-án)
- [Yêu cầu](#yêu-cầu)
- [Hướng dẫn Cài đặt](#hướng-dẫn-cài-đặt)
- [Cách Sử dụng](#cách-sử-dụng)
  - [1. Thu thập Dữ liệu](#1-thu-thập-dữ-liệu)
  - [2. Huấn luyện Mô hình](#2-huấn-luyện-mô-hình)
  - [3. Chạy API Dự đoán](#3-chạy-api-dự-đoán)
  - [4. Sử dụng Docker](#4-sử-dụng-docker)
- [Các Đặc trưng (Features)](#các-đặc-trưng-features)

---

## Tính năng
- **Thu thập dữ liệu on-chain:** Tự động lấy lịch sử giao dịch và tài nguyên của một ví từ Aptos fullnode.
- **Feature Engineering:** Tạo ra hơn 15 đặc trưng có ý nghĩa để mô tả hành vi của một ví.
- **Huấn luyện mô hình:** Sử dụng pipeline của Scikit-learn, xử lý dữ liệu mất cân bằng với SMOTE và tinh chỉnh siêu tham số.
- **Đánh giá mô hình:** Cung cấp các notebook để đánh giá hiệu năng mô hình một cách toàn diện.
- **API Triển khai:** Cung cấp một API dựa trên Flask để dự đoán cho một ví bất kỳ theo thời gian thực.
- **Dockerized:** Sẵn sàng để đóng gói và triển khai trên các nền tảng đám mây như Render, Heroku.

---

## Cấu trúc Dự án
```
aptos-sybil-detector-api/
├── data/             # Chứa dữ liệu thô và đã qua xử lý
├── logs/             # Chứa file log kết quả dự đoán
├── models/           # Chứa mô hình đã được huấn luyện
├── notebooks/        # Chứa các file Jupyter Notebook để phân tích và huấn luyện
├── scripts/          # Chứa các script để chạy các tác vụ độc lập (ví dụ: thu thập dữ liệu)
├── src/              # Chứa mã nguồn chính của ứng dụng
│   ├── app.py        # File API Flask
│   └── utils.py      # Các hàm dùng chung
├── .dockerignore     # Các file/thư mục Docker sẽ bỏ qua
├── .gitignore        # Các file/thư mục Git sẽ bỏ qua
├── Dockerfile        # Cấu hình để xây dựng Docker image
├── requirements.txt  # Danh sách các thư viện Python cần thiết
└── README.md         # File hướng dẫn này
```

---

## Yêu cầu
- Python 3.9+
- Docker (tùy chọn, nếu muốn chạy bằng container)

---

## Hướng dẫn Cài đặt

1.  **Clone repository này về máy của bạn:**
    ```bash
    git clone <https://github.com/quwyimn/aptos-sybil-detector-api.git>
    cd aptos-sybil-detector-api
    ```

2.  **Tạo và kích hoạt môi trường ảo:** (Khuyến khích)
    ```bash
    python -m venv .venv
    source .venv/bin/activate  # Trên Linux/macOS
    # .\.venv\Scripts\activate   # Trên Windows
    ```

3.  **Cài đặt các thư viện cần thiết:**
    ```bash
    pip install -r requirements.txt
    ```

---

## Cách Sử dụng

### 1. Thu thập Dữ liệu
Bạn có thể tự bổ sung dữ liệu huấn luyện bằng cách chạy script `scripts/profile_one_and_append.py`.
- Mở file đó và thay đổi `WALLET_ADDRESS` và `LABEL`.
- Chạy script: `python scripts/profile_one_and_append.py`

### 2. Huấn luyện Mô hình
- Để huấn luyện lại mô hình từ đầu, hãy mở và chạy các cell trong notebook `notebooks/train_aptos.ipynb`.
- Mô hình mới sẽ được lưu vào thư mục `models/`.

### 3. Chạy API Dự đoán

- **Khởi động server:**
  ```bash
  python src/app.py
  ```
  API sẽ chạy tại `http://0.0.0.0:5000`.

- **Gửi yêu cầu dự đoán:**
  Sử dụng một công cụ như `cURL` hoặc Postman để gửi yêu cầu `POST` đến `http://localhost:5000/predict`.

  **Ví dụ với cURL:**
  ```bash
  curl -X POST -H "Content-Type: application/json" \
       -d '{"wallet_address": "0x123..."}' \
       http://localhost:5000/predict
  ```

  **Kết quả trả về sẽ có dạng:**
  ```json
  {
    "wallet_address": "0x123...",
    "prediction": "Normal",
    "is_sybil": 0,
    "confidence": 0.98,
    "sybil_probability": 0.02
  }
  ```

### 4. Sử dụng Docker
Dự án đã được cấu hình để chạy với Docker.

1.  **Xây dựng image:**
    ```bash
    docker build -t aptos-sybil-detector .
    ```

2.  **Chạy container:**
    ```bash
    docker run -p 10000:10000 aptos-sybil-detector
    ```
    API sẽ có thể truy cập được tại `http://localhost:10000`.

---

## Các Đặc trưng (Features)
Mô hình sử dụng các đặc trưng sau để đưa ra dự đoán:
- `wallet_age_days`: Tuổi của ví (tính bằng ngày).
- `apt_balance`: Số dư APT.
- `total_transaction_count`: Tổng số giao dịch.
- `success_rate`: Tỷ lệ giao dịch thành công.
- `avg_time_between_tx_seconds`: Thời gian trung bình giữa các giao dịch.
- ... và nhiều đặc trưng khác.