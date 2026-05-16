# app/crud/nhanvien_kiemtra_crud.py

from app.core.db import get_connection


# ─────────────────────────────────────────────
# GET LIST
# ─────────────────────────────────────────────
def get_list_kiemtra(
    keyword=None,
    tu_ngay=None,
    den_ngay=None,
    page=1,
    page_size=25
):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_KiemTra_GetList
            @keyword=?,
            @tu_ngay=?,
            @den_ngay=?,
            @page=?,
            @page_size=?
    """,
    (
        keyword,
        tu_ngay,
        den_ngay,
        page,
        page_size
    ))

    columns = [col[0] for col in cursor.description]

    rows = [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

    total_count = rows[0]["total_count"] if rows else 0

    conn.close()

    return {
        "data": rows,
        "total_count": total_count,
        "page": page,
        "page_size": page_size
    }


# ─────────────────────────────────────────────
# GET DETAIL VIEW
# ─────────────────────────────────────────────
def get_kiemtra_view(id):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_KiemTra_GetById_View
            @id=?
    """, (id,))

    columns = [col[0] for col in cursor.description]

    rows = [
        dict(zip(columns, row))
        for row in cursor.fetchall()
    ]

    conn.close()

    if not rows:
        return None

    # MASTER
    master = {
        "id": rows[0]["id"],
        "thoi_gian_he_thong": rows[0]["thoi_gian_he_thong"],
        "thoi_gian_bat_dau": rows[0]["thoi_gian_bat_dau"],
        "thoi_gian_ket_thuc": rows[0]["thoi_gian_ket_thuc"],
        "khu_vuc": rows[0]["khu_vuc"],
        "ma_nv_kiem_tra": rows[0]["ma_nv_kiem_tra"],
        "ten_nguoi_kiem_tra": rows[0]["ten_nguoi_kiem_tra"],
        "ghi_chu_kiemtra": rows[0]["ghi_chu_kiemtra"],
    }

    # CHILDREN
    cai_thien_list = []
    vi_pham_list = []

    cai_thien_ids = set()
    vi_pham_ids = set()

    for r in rows:

        # CẢI THIỆN
        if r["cai_thien_id"] and r["cai_thien_id"] not in cai_thien_ids:

            cai_thien_ids.add(r["cai_thien_id"])

            cai_thien_list.append({
                "id": r["cai_thien_id"],
                "ngay_kiem_tra": r["ngay_kiem_tra"],
                "ten_bo_phan_phu_trach": r["ten_bo_phan_phu_trach"],
                "hien_tuong": r["hien_tuong"],
                "ghi_chu_caithien": r["ghi_chu_caithien"],
            })

        # VI PHẠM
        if r["vi_pham_id"] and r["vi_pham_id"] not in vi_pham_ids:

            vi_pham_ids.add(r["vi_pham_id"])

            vi_pham_list.append({
                "id": r["vi_pham_id"],
                "ten_bo_phan": r["ten_bo_phan"],
                "ma_nv": r["ma_nv_vi_pham"],
                "ho_ten": r["ho_ten_vi_pham"],
                "thoi_gian_vi_pham": r["thoi_gian_vi_pham"],
                "dia_diem": r["dia_diem"],
                "ten_cap_tren": r["ten_cap_tren"],
                "email_cc": r["email_cc"],
                "hien_tuong_vi_pham": r["hien_tuong_vi_pham"],
            })

    return {
        "master": master,
        "cai_thien": cai_thien_list,
        "vi_pham": vi_pham_list
    }


# ─────────────────────────────────────────────
# INSERT
# ─────────────────────────────────────────────
def create_kiemtra(data):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_KiemTra_Insert
            @thoi_gian_bat_dau=?,
            @thoi_gian_ket_thuc=?,
            @khu_vuc=?,
            @ma_nv_kiem_tra=?,
            @ghi_chu=?,
            @nguoi_tao=?
    """,
    (
        data.get("thoi_gian_bat_dau"),
        data.get("thoi_gian_ket_thuc"),
        data.get("khu_vuc"),
        data.get("ma_nv_kiem_tra"),
        data.get("ghi_chu"),
        data.get("nguoi_tao")
    ))

    row = cursor.fetchone()

    conn.commit()
    conn.close()

    return {
        "message": "Created successfully",
        "id": row[0] if row else None
    }


# ─────────────────────────────────────────────
# UPDATE
# ─────────────────────────────────────────────
def update_kiemtra(id, data):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_KiemTra_Update
            @id=?,
            @thoi_gian_bat_dau=?,
            @thoi_gian_ket_thuc=?,
            @khu_vuc=?,
            @ghi_chu=?,
            @nguoi_cap_nhat=?
    """,
    (
        id,
        data.get("thoi_gian_bat_dau"),
        data.get("thoi_gian_ket_thuc"),
        data.get("khu_vuc"),
        data.get("ghi_chu"),
        data.get("nguoi_cap_nhat")
    ))

    row = cursor.fetchone()

    conn.commit()
    conn.close()

    return {
        "message": "Updated successfully",
        "rows_affected": row[0] if row else 0
    }


# ─────────────────────────────────────────────
# DELETE
# ─────────────────────────────────────────────
def delete_kiemtra(id, nguoi_xoa):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_KiemTra_Delete
            @id=?,
            @nguoi_xoa=?
    """,
    (
        id,
        nguoi_xoa
    ))

    row = cursor.fetchone()

    conn.commit()
    conn.close()

    return {
        "message": "Deleted successfully",
        "rows_affected": row[0] if row else 0
    }