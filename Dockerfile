FROM python:3.9-slim-buster

ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Thêm bước cài đặt các gói hệ thống cần thiết
# libgl1 là thư viện OpenGL, thường cần cho các thư viện xử lý đồ họa hoặc hiển thị
# build-essential, python3-dev, libssl-dev, libffi-dev thường hữu ích cho nhiều gói Python
RUN apt-get update && apt-get install -y \
    libgl1 \
    build-essential \
    python3-dev \
    libssl-dev \
    libffi-dev \
    && rm -rf /var/lib/apt/lists/*
# Lưu ý: rm -rf /var/lib/apt/lists/* giúp giảm kích thước image sau khi cài đặt.

COPY ./requirements.txt /app/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY ./app /app/app
EXPOSE 8000
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
