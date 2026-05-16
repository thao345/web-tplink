from fastapi import HTTPException, Header
from app.utils.jwt import decode_token


# 👉 LẤY USER TỪ TOKEN
def get_current_user(authorization: str = Header(None)):

    if not authorization:
        raise HTTPException(status_code=401, detail="No token")

    try:
        token = authorization.split(" ")[1]  # "Bearer xxx"
    except:
        raise HTTPException(status_code=401, detail="Invalid token format")

    payload = decode_token(token)

    if not payload:
        raise HTTPException(status_code=401, detail="Token expired or invalid")

    return payload