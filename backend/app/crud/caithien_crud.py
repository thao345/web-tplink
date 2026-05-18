from app.core.db import get_connection



# =========================================================
# LẤY DANH SÁCH
# =========================================================
def get_list_caithien(
    tu_ngay=None,
    den_ngay=None,
    keyword=None,
    page=1,
    page_size=25
):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        EXEC dbo.SP_CaiThien_GetList
            @tu_ngay=?,
            @den_ngay=?,
            @keyword=?,
            @page=?,
            @page_size=?
        """,
        (
            tu_ngay,
            den_ngay,
            keyword,
            page,
            page_size
        )
    )

    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()

    result = []

    for row in rows:
        result.append(dict(zip(columns, row)))

    cursor.close()
    conn.close()

    return result


# =========================================================
# LẤY CHI TIẾT THEO ID
# =========================================================
def get_caithien_by_id(id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        EXEC dbo.SP_CaiThien_GetById
            @id=?
        """,
        (id,)
    )

    row = cursor.fetchone()

    if not row:
        cursor.close()
        conn.close()
        return None

    columns = [col[0] for col in cursor.description]

    result = dict(zip(columns, row))

    cursor.close()
    conn.close()

    return result


# =========================================================
# THÊM MỚI
# =========================================================
def insert_caithien(data):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        EXEC dbo.SP_CaiThien_Insert
            @id_kiem_tra=?,
            @ngay_kiem_tra=?,
            @hien_tuong=?,
            @ten_bo_phan_phu_trach=?,
            @ma_nv_kiem_tra=?,
            @ghi_chu=?,
            @nguoi_tao=?
        """,
        (
            data.get("id_kiem_tra"),
            data.get("ngay_kiem_tra"),
            data.get("hien_tuong"),
            data.get("ten_bo_phan_phu_trach"),
            data.get("ma_nv_kiem_tra"),
            data.get("ghi_chu"),
            data.get("nguoi_tao")
        )
    )

    row = cursor.fetchone()

    conn.commit()

    result = {
        "id": row[0],
        "msg": row[1]
    }

    cursor.close()
    conn.close()

    return result


# =========================================================
# CẬP NHẬT
# =========================================================
def update_caithien(id, data):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        EXEC dbo.SP_CaiThien_Update
            @id=?,
            @ngay_kiem_tra=?,
            @hien_tuong=?,
            @ten_bo_phan_phu_trach=?,
            @ghi_chu=?,
            @nguoi_cap_nhat=?
        """,
        (
            id,
            data.get("ngay_kiem_tra"),
            data.get("hien_tuong"),
            data.get("ten_bo_phan_phu_trach"),
            data.get("ghi_chu"),
            data.get("nguoi_cap_nhat")
        )
    )

    row = cursor.fetchone()

    conn.commit()

    result = {
        "rows_affected": row[0],
        "msg": row[1]
    }

    cursor.close()
    conn.close()

    return result


# =========================================================
# XÓA
# =========================================================
def delete_caithien(id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        """
        EXEC dbo.SP_CaiThien_Delete
            @id=?
        """,
        (id,)
    )

    row = cursor.fetchone()

    conn.commit()

    result = {
        "rows_affected": row[0],
        "msg": row[1]
    }

    cursor.close()
    conn.close()

    return result