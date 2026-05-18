# app/api/caithien.py

from fastapi import APIRouter, Query, HTTPException

from app.crud.caithien_crud import (
    get_list_caithien,
    get_caithien_by_id,
    insert_caithien,
    update_caithien,
    delete_caithien
)

router = APIRouter()


# =========================================================
# GET LIST
# =========================================================
@router.get("/api/caithien")
def api_get_caithien(
    tu_ngay: str | None = Query(None),
    den_ngay: str | None = Query(None),
    keyword: str | None = Query(None),

    page: int = Query(1),
    page_size: int = Query(25)
):

    try:

        data = get_list_caithien(
            tu_ngay=tu_ngay,
            den_ngay=den_ngay,
            keyword=keyword,
            page=page,
            page_size=page_size
        )

        total = 0

        if len(data) > 0:
            total = data[0].get("total_count", 0)

        return {
            "success": True,
            "total": total,
            "items": data
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# GET BY ID
# =========================================================
@router.get("/api/caithien/{id}")
def api_get_caithien_by_id(id: int):

    try:

        data = get_caithien_by_id(id)

        if not data:

            raise HTTPException(
                status_code=404,
                detail="Không tìm thấy dữ liệu"
            )

        return {
            "success": True,
            "data": data
        }

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# INSERT
# =========================================================
@router.post("/api/caithien")
def api_insert_caithien(data: dict):

    try:

        result = insert_caithien(data)

        if result["id"] == -1:

            raise HTTPException(
                status_code=400,
                detail=result["msg"]
            )

        return {
            "success": True,
            "message": "Thêm thành công",
            "data": result
        }

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# UPDATE
# =========================================================
@router.put("/api/caithien/{id}")
def api_update_caithien(id: int, data: dict):

    try:

        result = update_caithien(id, data)

        if result["rows_affected"] <= 0:

            raise HTTPException(
                status_code=400,
                detail=result["msg"]
            )

        return {
            "success": True,
            "message": "Cập nhật thành công",
            "data": result
        }

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# DELETE
# =========================================================
@router.delete("/api/caithien/{id}")
def api_delete_caithien(id: int):

    try:

        result = delete_caithien(id)

        if result["rows_affected"] <= 0:

            raise HTTPException(
                status_code=400,
                detail=result["msg"]
            )

        return {
            "success": True,
            "message": "Xóa thành công",
            "data": result
        }

    except HTTPException:
        raise

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )