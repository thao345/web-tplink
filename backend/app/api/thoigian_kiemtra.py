# app/routes/kiemtra_routes.py

from fastapi import APIRouter, Query, HTTPException
from app.crud.thoigian_kiemtra_crud import (
    get_list_kiemtra,
    get_kiemtra_view,
    create_kiemtra,
    update_kiemtra,
    delete_kiemtra
)

router = APIRouter()


# ═══════════════════════════════════════════════
# GET LIST
# ═══════════════════════════════════════════════
@router.get("/api/kiemtrathoigian")
def api_get_kiemtra_list(
    keyword: str | None = Query(None),
    tu_ngay: str | None = Query(None),
    den_ngay: str | None = Query(None),
    page: int = Query(1),
    page_size: int = Query(25)
):

    try:

        result = get_list_kiemtra(
            keyword=keyword,
            tu_ngay=tu_ngay,
            den_ngay=den_ngay,
            page=page,
            page_size=page_size
        )

        return result

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# ═══════════════════════════════════════════════
# GET BY ID
# ═══════════════════════════════════════════════
@router.get("/api/kiemtrathoigian/{id}")
def api_get_kiemtra_by_id(id: int):

    try:

        result = get_kiemtra_view(id)

        if not result:
            raise HTTPException(
                status_code=404,
                detail="Không tìm thấy dữ liệu"
            )

        return result

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# ═══════════════════════════════════════════════
# INSERT
# ═══════════════════════════════════════════════
@router.post("/api/kiemtrathoigian")
def api_insert_kiemtra(data: dict):

    try:

        result = create_kiemtra(data)

        return {
            "success": True,
            "message": "Thêm thành công",
            "data": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# ═══════════════════════════════════════════════
# UPDATE
# ═══════════════════════════════════════════════
@router.put("/api/kiemtrathoigian/{id}")
def api_update_kiemtra(
    id: int,
    data: dict
):

    try:

        result = update_kiemtra(id, data)

        return {
            "success": True,
            "message": "Cập nhật thành công",
            "data": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# ═══════════════════════════════════════════════
# DELETE
# ═══════════════════════════════════════════════
@router.delete("/api/kiemtrathoigian/{id}")
def api_delete_kiemtra(
    id: int,
    nguoi_xoa: str
):

    try:

        result = delete_kiemtra(
            id=id,
            nguoi_xoa=nguoi_xoa
        )

        return {
            "success": True,
            "message": "Xóa thành công",
            "data": result
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )