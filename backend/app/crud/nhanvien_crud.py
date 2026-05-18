from app.core.db import get_connection

 
# ==============================
# GET LIST
# ==============================
def get_nhanvien(keyword=None, page=1, page_size=25):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_NhanVien_GetList
            @keyword=?,
            @page=?,
            @page_size=?
    """, (keyword, page, page_size))

    columns = [col[0] for col in cursor.description]

    rows = cursor.fetchall()

    data = [dict(zip(columns, row)) for row in rows]

    conn.close()

    return data


# ==============================
# GET BY ID
# ==============================
def get_nhanvien_by_id(ma_nv):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_NhanVien_GetById
            @ma_nv=?
    """, (ma_nv,))

    columns = [col[0] for col in cursor.description]

    row = cursor.fetchone()

    conn.close()

    if not row:
        return None

    return dict(zip(columns, row))


# ==============================
# UPSERT (INSERT / UPDATE)
# ==============================
def save_nhanvien(data):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
    EXEC dbo.SP_NhanVien_Upsert
        @ma_nv=?,
        @ho_ten=?,
        @bo_phan=?,
        @chuc_vu=?,
        @email=?,
        @dien_thoai=?,
        @la_quan_ly=?,
        @la_kiem_tra=?,
        @thu_tu_truc=?,
        @nguoi_tao=?
    """, (
        data.get("ma_nv"),
        data.get("ho_ten"),
        data.get("bo_phan"),
        data.get("chuc_vu"),
        data.get("email"),
        data.get("dien_thoai"),
        data.get("la_quan_ly", 0),
        data.get("la_kiem_tra", 0),
        data.get("thu_tu_truc", 0),
        data.get("nguoi_tao")
    ))

    row = cursor.fetchone()

    conn.commit()
    conn.close()

    if not row:
        return {
            "message": "saved"
        }

    return {
        "ma_nv": row[0],
        "action": row[1]
    }

# ==============================
# DELETE
# ==============================
def delete_nhanvien(ma_nv, nguoi_xoa):

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        EXEC dbo.SP_NhanVien_Delete
            @ma_nv=?,
            @nguoi_xoa=?
    """, (ma_nv, nguoi_xoa))

    row = cursor.fetchone()

    conn.commit()
    conn.close()

    return {
        "rows_affected": row[0]
    }