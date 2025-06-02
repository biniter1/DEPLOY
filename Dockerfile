FROM python:3.10-slim-buster

ENV PYTHONUNBUFFERED 1
WORKDIR /app

# --------------------------------------------------------------------------------------------------
# CÀI ĐẶT CÁC THƯ VIỆN HỆ THỐNG (SYSTEM DEPENDENCIES) VÀ CÁC GÓI DEV CẦN THIẾT
# --------------------------------------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Build tools: Cần cho các gói Python cần biên dịch từ C/C++
    build-essential \
    pkg-config \
    python3-dev \
    # Database: Cần cho psycopg[binary] hoặc psycopg2-binary
    libpq-dev \
    # Image processing (Pillow, PyMuPDF, PyTesseract, PaddleOCR):
    libjpeg-dev \
    zlib1g-dev \
    libpng-dev \
    libtiff-dev \
    # OpenGL/Display: Giải quyết lỗi libgl1 và cần cho một số thư viện đồ họa/AI
    libgl1 \
    libglib2.0-0 \
    # Video/Audio processing (MoviePy, pydub, ffmpeg):
    ffmpeg \
    libsndfile1 \
    # Display Libraries (often needed for headless rendering with some libraries like OpenCV):
    libsm6 \
    libxext6 \
    libxrender-dev \
    # OCR (Tesseract): Cài đặt engine Tesseract và các dev files cần thiết
    tesseract-ocr \
    tesseract-ocr-eng \
    # Thêm các gói dev cho Leptonica và Tesseract để biên dịch Python bindings
    libleptonica-dev \
    libtesseract-dev \
    # Các thư viện khác có thể cần cho các gói phức tạp (ví dụ: cryptography, other C extensions)
    libssl-dev \
    libffi-dev \
    # Dọn dẹp sau khi cài đặt để giảm kích thước image
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# --------------------------------------------------------------------------------------------------
# CÀI ĐẶT CÁC GÓI PYTHON
# --------------------------------------------------------------------------------------------------

COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /app/requirements.txt

# --------------------------------------------------------------------------------------------------
# SAO CHÉP MÃ NGUỒN VÀ KHỞI ĐỘNG ỨNG DỤNG
# --------------------------------------------------------------------------------------------------

COPY ./app /app/app
EXPOSE 8000
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
