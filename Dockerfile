# Sử dụng một base image Python phù hợp
# Nên dùng phiên bản slim để giảm kích thước image, ví dụ: python:3.12-slim-buster
FROM python:3.12-slim-buster

# --- Cài đặt các thư viện hệ thống cần thiết cho OpenCV ---
# Cập nhật danh sách gói và cài đặt libgl1-mesa-glx
RUN apt-get update && \
    apt-get install -y libgl1-mesa-glx && \
    rm -rf /var/lib/apt/lists/*

# --- Thiết lập môi trường Python ---
# Thiết lập biến môi trường cho virtual environment (tùy chọn nhưng được khuyến nghị)
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# --- Cài đặt dependencies Python ---
# Đặt thư mục làm việc trong container
WORKDIR /app

# Sao chép tệp requirements.txt và cài đặt các thư viện Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Sao chép mã nguồn ứng dụng ---
# Sao chép toàn bộ mã nguồn ứng dụng vào thư mục làm việc
COPY . .

# --- Lệnh khởi chạy ứng dụng ---
# Đây là lệnh mà Railway sẽ chạy để khởi động ứng dụng của bạn
# Đảm bảo lệnh này phù hợp với cách bạn khởi chạy Uvicorn/FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
