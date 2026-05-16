import pyodbc

def get_connection():
    # connect info
    server = r'.\SQLEXPRESS'
    database = 'FactoryManagement' 
    username = 'hoangthao'
    password = '123456'

    # connect
    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
        f"TrustServerCertificate=yes;"
)
    return conn