# Sử dụng một base image Python phù hợp
FROM python:3.12-slim-bullseye # Hoặc python:3.12-slim hoặc python:3.12-slim-bookworm

# --- Cài đặt các thư viện hệ thống cần thiết cho OpenCV và các dependencies khác ---
RUN apt-get update && \
    apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 && \ # THÊM DÒNG NÀY
    rm -rf /var/lib/apt/lists/*

# --- Thiết lập môi trường Python ---
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# --- Cài đặt dependencies Python ---
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Sao chép mã nguồn ứng dụng ---
COPY . .

# --- Lệnh khởi chạy ứng dụng ---
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
