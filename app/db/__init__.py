from app.db.database import *
from app.db.models import *
from app.db.schemas import *

# Khởi tạo database
def init_db():
    Base.metadata.create_all(bind=engine)
