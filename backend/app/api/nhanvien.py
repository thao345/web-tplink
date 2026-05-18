from fastapi import APIRouter, HTTPException
from app.crud.nhanvien_crud import (
    get_nhanvien,
    get_nhanvien_by_id,
    save_nhanvien,
    delete_nhanvien
)

router = APIRouter()


# =========================================
# GET LIST
# =========================================
@router.get("/api/nhanvien")
def api_get_nhanvien(
    keyword: str = None,
    page: int = 1,
    page_size: int = 25
):

    data = get_nhanvien(
        keyword=keyword,
        page=page,
        page_size=page_size
    )

    return {
        "success": True,
        "data": data
    }


# =========================================
# GET BY ID
# =========================================
@router.get("/api/nhanvien/{ma_nv}")
def api_get_nhanvien_by_id(ma_nv: str):

    data = get_nhanvien_by_id(ma_nv)

    if not data:
        raise HTTPException(
            status_code=404,
            detail="Không tìm thấy nhân viên"
        )

    return {
        "success": True, 
        "data": data
    }


# =========================================
# CREATE / UPDATE
# =========================================
@router.post("/api/nhanvien")
def api_save_nhanvien(data: dict):

    result = save_nhanvien(data)

    return {
        "success": True,
        "message": "Lưu thành công",
        "data": result
    }


# =========================================
# DELETE
# =========================================
@router.delete("/api/nhanvien/{ma_nv}")
def api_delete_nhanvien(
    ma_nv: str,
    nguoi_xoa: str
):

    result = delete_nhanvien(
        ma_nv=ma_nv,
        nguoi_xoa=nguoi_xoa
    )

    return {
        "success": True,
        "message": "Xóa thành công",
        "data": result
    }