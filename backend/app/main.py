from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# ✅ CORS phải đặt SAU khi tạo app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://127.0.0.1:5500"],  # frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# import router sau khi có app
from app.api.auth import router as auth_router
app.include_router(auth_router)

from app.api.nhanvien import router as nhanvien_router
app.include_router(nhanvien_router)

from app.api.thoigian_kiemtra import router as thoigian_kiemtra_router
app.include_router(thoigian_kiemtra_router)

# 👉 test server sống hay chết
# @app.get("/ping")
# def ping():
#     return {"ok": True}

#uvicorn app.main:app --reload