# Sử dụng Python base image chính thức. Chọn phiên bản Python phù hợp với dự án của bạn.
# 'slim-buster' là phiên bản nhỏ gọn, tốt cho production.
FROM python:3.9-slim-buster

# Thiết lập biến môi trường để Python không ghi các tệp .pyc và không đệm đầu ra stdout/stderr.
# Điều này hữu ích cho logging và hiệu suất trong môi trường container.
ENV PYTHONUNBUFFERED 1

# Thiết lập thư mục làm việc bên trong container. Mọi lệnh tiếp theo sẽ được thực thi trong thư mục này.
WORKDIR /app

# Sao chép tệp requirements.txt vào thư mục làm việc.
# Điều này giúp tận dụng Docker cache: nếu requirements.txt không thay đổi, Docker sẽ không chạy lại pip install.
COPY ./requirements.txt /app/requirements.txt

# Cài đặt các phụ thuộc Python.
# Sử dụng --no-cache-dir để không lưu trữ cache của pip, giúp giảm kích thước image.
# Sử dụng --upgrade pip để đảm bảo pip là phiên bản mới nhất.
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

# Sao chép toàn bộ mã nguồn ứng dụng vào thư mục làm việc trong container.
# Đảm bảo bạn có file .dockerignore để loại trừ các file không cần thiết (như .git, .env, __pycache__).
COPY ./app /app/app

# Khai báo cổng mà container sẽ lắng nghe.
# FastAPi sẽ lắng nghe trên cổng này. Railway sẽ map cổng này với một cổng công khai.
EXPOSE 8000

# Lệnh mặc định để chạy ứng dụng khi container khởi động.
# Đây là lệnh chính thức để chạy FastAPI.
# Trong trường hợp này, chúng ta sử dụng Gunicorn để quản lý các Uvicorn worker,
# điều này được khuyến nghị cho production để xử lý tốt hơn tải và độ tin cậy.
# - 'app.main:app': Thay 'app' bằng tên thư mục ứng dụng của bạn (nếu có),
#                    'main' là tên file Python chứa instance FastAPI,
#                    'app' là tên instance FastAPI của bạn (thường là 'app = FastAPI()').
# - '--workers 4': Số lượng worker process. Điều chỉnh dựa trên số lượng CPU core của server.
#                  Một quy tắc chung là (2 * CPU cores) + 1.
# - '--worker-class uvicorn.workers.UvicornWorker': Sử dụng Uvicorn worker cho Gunicorn.
# - '--bind 0.0.0.0:8000': Lắng nghe trên tất cả các interface mạng (0.0.0.0) và cổng 8000.
#                         Bạn có thể thay thế 8000 bằng biến môi trường $PORT nếu muốn Railway tự quản lý.
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]

# Hoặc nếu bạn chỉ muốn chạy trực tiếp Uvicorn (thường dùng cho dev hoặc ứng dụng nhỏ):
# CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]