# ==============================================================================
# DOCKERFILE TỐI ƯU HÓA CHO ỨNG DỤNG FLASK/GUNICORN
# ==============================================================================

# --- Bước 1: Chọn ảnh nền (Base Image) ---
# Sử dụng một phiên bản Python cụ thể và nhẹ (slim) để giảm kích thước image.
# Việc chỉ định rõ phiên bản 3.11 giúp đảm bảo tính nhất quán.
FROM python:3.11-slim

# --- Bước 2: Thiết lập các biến môi trường ---
# Các biến này giúp Python và Gunicorn hoạt động tốt hơn trong môi trường container.
ENV PYTHONDONTWRITEBYTECODE 1  # Ngăn Python tạo file .pyc
ENV PYTHONUNBUFFERED 1         # Đảm bảo output (print, log) được hiển thị ngay lập tức

# --- Bước 3: Cài đặt các gói hệ thống cần thiết ---
# Cài đặt 'build-essential' để có thể biên dịch các thư viện Python có mã nguồn C/C++ (như numpy, pandas).
# Xóa cache của apt sau khi cài để giữ image nhẹ.
RUN apt-get update && apt-get install -y build-essential && rm -rf /var/lib/apt/lists/*

# --- Bước 4: Thiết lập thư mục làm việc ---
# Tất cả các lệnh sau sẽ được thực thi trong thư mục /app bên trong container.
WORKDIR /app

# --- Bước 5: Cài đặt các thư viện Python (Tối ưu hóa cache) ---
# Sao chép chỉ file requirements.txt trước.
# Docker sẽ chỉ chạy lại bước này nếu file requirements.txt thay đổi.
COPY requirements.txt .

# Cài đặt các thư viện. --no-cache-dir giúp giảm kích thước image.
RUN pip install --no-cache-dir -r requirements.txt

# --- Bước 6: Sao chép mã nguồn ứng dụng ---
# Sao chép thư mục 'src' vào thư mục làm việc hiện tại (/app).
# Lưu ý: File .dockerignore sẽ đảm bảo các file không cần thiết không bị sao chép vào.
COPY src/ ./src/

# --- Bước 7: Thiết lập PYTHONPATH ---
# RẤT QUAN TRỌNG: Vì code của bạn nằm trong thư mục 'src',
# chúng ta cần báo cho Python biết để tìm các module trong thư mục gốc (/app).
# Điều này cho phép Gunicorn tìm thấy 'src.app'.
ENV PYTHONPATH /app

# --- Bước 8: Mở cổng (Expose Port) ---
# Thông báo cho Docker rằng container sẽ lắng nghe trên cổng 10000.
# Con số này phải khớp với cổng trong lệnh CMD.
EXPOSE 10000

# --- Bước 9: Lệnh để chạy ứng dụng ---
# Sử dụng Gunicorn để chạy ứng dụng Flask.
# - `src.app:app`: Tìm đối tượng 'app' trong file 'src/app.py'.
# - `--bind 0.0.0.0:10000`: Lắng nghe trên tất cả các giao diện mạng ở cổng 10000.
# - `--workers 4`: Số lượng tiến trình Gunicorn sẽ tạo. 2-4 workers là một khởi đầu tốt.
CMD ["gunicorn", "--bind", "0.0.0.0:10000", "--workers", "4", "src.app:app"]