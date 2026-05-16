import jwt
import datetime

SECRET_KEY = "my_secret_key_123"
ALGORITHM = "HS256"


# 👉 TẠO TOKEN
def create_token(data: dict):
    payload = data.copy()

    payload.update({
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=8)
    })

    token = jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
    return token


# 👉 GIẢI TOKEN
def decode_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None