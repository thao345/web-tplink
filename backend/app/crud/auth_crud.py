from app.core.db import get_connection

def login_user(username, password):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "EXEC dbo.SP_Auth_Login @ten_dang_nhap=?, @mat_khau=?",
        (username, password)
    )

    row = cursor.fetchone()
    conn.close()

    return row