# from app.crud.auth_crud import login_user
# from app.utils.jwt import create_token

# def login_service(username, password):

#     user = login_user(username, password)

#     if not user:
#         return None

#     token = create_token({
#         "id": user.id,
#         "username": user.ten_dang_nhap,
#         "role": user.vai_tro
#     })

#     return {
#         "access_token": token,
#         "user": {
#             "id": user.id,
#             "username": user.ten_dang_nhap,
#             "role": user.vai_tro
#         }
#     }