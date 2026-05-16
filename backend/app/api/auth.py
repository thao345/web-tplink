from fastapi import APIRouter, HTTPException
from app.crud.auth_crud import login_user
import jwt
import datetime

router = APIRouter()

SECRET_KEY = "my_secret_key_123" 

@router.post("/api/auth/login")
def login(data: dict):      # nhận data từ frontend
    username = data["ten_dang_nhap"]
    password = data["mat_khau"]

    user = login_user(username, password) # chạy lệnh exec sql

    if not user:
        raise HTTPException(status_code=401, detail="Sai tài khoản hoặc mật khẩu")

    payload = {
        "user_id": user.id,
        "username": user.ten_dang_nhap,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=8)
    }

    token = jwt.encode(payload, SECRET_KEY, algorithm="HS256")

    return {
        "access_token": token,
        "user": {
            "id": user.id,
            "username": user.ten_dang_nhap,
            "password" : user.mat_khau,
            "full_name": user.ho_ten,
            "ma_nv" : user.ma_nv
        }
    }
