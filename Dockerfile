# --- Stage 1: Builder Stage ---
# Sử dụng image python:3.11-buster để đảm bảo có đầy đủ build tools
FROM python:3.11-buster AS builder

ENV PYTHONUNBUFFERED 1
WORKDIR /app

# CÀI ĐẶT CÁC THƯ VIỆN HỆ THỐNG CẦN THIẾT CHO QUÁ TRÌNH BUILD VÀ RUNTIME
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config python3-dev libpq-dev \
    libjpeg-dev zlib1g-dev libpng-dev libtiff-dev \
    libgl1 libglib2.0-0 \
    ffmpeg libsndfile1 \
    libsm6 libxext6 libxrender-dev \
    tesseract-ocr tesseract-ocr-eng libleptonica-dev libtesseract-dev \
    libssl-dev libffi-dev \
    # Các gói cần cho PaddleOCR/PaddlePaddle
    # libhdf5-dev \ # Nếu cần HDF5
    # libopenmpi-dev \ # Nếu cần MPI
    # Cân nhắc thêm các gói dev khác nếu lỗi biên dịch lại xuất hiện
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Sao chép requirements.txt và cài đặt PyTorch
COPY ./requirements.txt /app/requirements.txt

# Cài đặt PyTorch CPU-only VỚI index-url ĐẶC BIỆT
# Kiểm tra phiên bản mới nhất và tương thích trên https://pytorch.org/get-started/locally/
# Tại thời điểm hiện tại, 2.3.1 là phiên bản mới nhất cho CPU trên Python 3.11.
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir torch==2.3.1+cpu torchvision==0.18.1+cpu torchaudio==2.3.1+cpu \
        --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r /app/requirements.txt

# --- Stage 2: Runtime Stage ---
# Sử dụng base image Python slim hơn hoặc alpine để giảm kích thước cuối cùng.
# Alpine thường rất nhỏ nhưng có thể gây ra vấn đề tương thích với một số gói Python lớn (do musl libc vs glibc).
# Slim-buster là lựa chọn an toàn hơn và thường đủ nhỏ.
FROM python:3.11-slim-buster AS runtime

ENV PYTHONUNBUFFERED 1
WORKDIR /app

# Cài đặt lại CÁC THƯ VIỆN HỆ THỐNG CHỈ CẦN THIẾT KHI CHẠY (runtime dependencies)
# RẤT QUAN TRỌNG: Chỉ bao gồm những gì ứng dụng của bạn cần để chạy, không phải để build.
# Ví dụ: ffmpeg, tesseract-ocr (engine), libgl1, libsm6, libxext6, libxrender-dev
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libsndfile1 \
    tesseract-ocr \
    tesseract-ocr-eng \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libpq5 \ 
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Sao chép các gói Python đã cài đặt từ builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
# Sao chép mã nguồn ứng dụng
COPY ./app /app/app

EXPOSE 8000
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
