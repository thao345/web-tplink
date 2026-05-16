-- ============================================================
-- FACTORY MANAGEMENT SYSTEM - STORED PROCEDURES
-- Microsoft SQL Server
-- ============================================================
USE FactoryManagement;
GO

DROP PROCEDURE IF EXISTS dbo.SP_NhanVien_GetList;
GO
-- ============================================================
 
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_Auth_Login
    @ten_dang_nhap  NVARCHAR(50),
    @mat_khau       NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        tk.id,
        tk.ten_dang_nhap,
		tk.mat_khau,
        tk.ma_nv,
        tk.vai_tro,
        tk.ngon_ngu,
        tk.trang_thai,
        nv.ho_ten,
        nv.email,
        nv.bo_phan
    FROM dbo.TAI_KHOAN tk
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = tk.ma_nv
    WHERE tk.ten_dang_nhap = @ten_dang_nhap
      AND tk.mat_khau = @mat_khau   -- ⚠️ so sánh trực tiếp password
      AND tk.trang_thai = 1;
END;
GO

EXEC dbo.SP_Auth_Login @ten_dang_nhap = 'admin', @mat_khau ='123';
SELECT
    ten_dang_nhap,
    mat_khau

FROM dbo.TAI_KHOAN
WHERE ten_dang_nhap IN ('admin', 'admin01');

-- ============================================================
-- SP_NHAN_VIEN: CRUD Employee
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_NhanVien_GetList
    @keyword        NVARCHAR(100) = NULL,
    @page           INT           = 1,
    @page_size      INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@page - 1) * @page_size;

    SELECT
        ma_nv, ho_ten, bo_phan, chuc_vu, email,
        dien_thoai, la_quan_ly, la_kiem_tra, trang_thai,
        ngay_tao, nguoi_tao,
        COUNT(*) OVER() AS total_count
    FROM dbo.NHAN_VIEN
    WHERE trang_thai = 1
      AND (
            @keyword IS NULL 
            OR ho_ten LIKE N'%' + @keyword + '%'
            OR ma_nv LIKE N'%' + @keyword + '%'
          )
    ORDER BY ngay_tao DESC   -- ⭐ quan trọng nhất
    OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;
END;
GO
--EXEC dbo.SP_NhanVien_GetList;
--EXEC dbo.SP_NhanVien_GetList
--    @keyword = N'陈',
--    @page = 1,
--    @page_size = 10;



CREATE OR ALTER PROCEDURE dbo.SP_NhanVien_GetById
    @ma_nv NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.NHAN_VIEN WHERE ma_nv = @ma_nv;
END;
GO
--EXEC dbo.SP_NhanVien_GetById @ma_nv = 'ADM001';
    

CREATE OR ALTER PROCEDURE dbo.SP_NhanVien_Upsert
    @ma_nv          NVARCHAR(20),
    @ho_ten         NVARCHAR(100),
    @bo_phan        NVARCHAR(20)  = NULL,
    @chuc_vu        NVARCHAR(100) = NULL,
    @email          NVARCHAR(200) = NULL,
    @dien_thoai     NVARCHAR(20)  = NULL,
    @la_quan_ly     BIT           = 0,
    @la_kiem_tra    BIT           = 0,
	  @thu_tu_truc    INT           = 0,
    @nguoi_tao      NVARCHAR(50)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.NHAN_VIEN WHERE ma_nv = @ma_nv)
    BEGIN
        UPDATE dbo.NHAN_VIEN SET
            ho_ten       = @ho_ten,
            bo_phan      = @bo_phan,
            chuc_vu      = @chuc_vu,
            email        = @email,
            dien_thoai   = @dien_thoai,
            la_quan_ly   = @la_quan_ly,
            la_kiem_tra  = @la_kiem_tra,
            ngay_cap_nhat = GETDATE(),
            nguoi_tao    = @nguoi_tao
        WHERE ma_nv = @ma_nv;
        SELECT @ma_nv AS ma_nv, 'updated' AS action;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.NHAN_VIEN
            (ma_nv, ho_ten, bo_phan, chuc_vu, email, dien_thoai, la_quan_ly, la_kiem_tra,  thu_tu_truc, nguoi_tao)
        VALUES
            (@ma_nv, @ho_ten, @bo_phan, @chuc_vu, @email, @dien_thoai, @la_quan_ly, @la_kiem_tra,   @thu_tu_truc, @nguoi_tao);
        SELECT @ma_nv AS ma_nv, 'created' AS action;
    END
END;
GO



EXEC dbo.SP_NhanVien_Upsert
    @ma_nv = '1',
    @ho_ten = N'Nguyễn Văn A new',
    @bo_phan = N'SMT',
    @chuc_vu = N'Operator',
    @email = 'a@company.com',
    @dien_thoai = '0900000000',
    @la_quan_ly = 0,
    @la_kiem_tra = 0,
    @nguoi_tao = N'admin';

CREATE OR ALTER PROCEDURE dbo.SP_NhanVien_Delete
    @ma_nv NVARCHAR(20),
    @nguoi_xoa NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.NHAN_VIEN
    WHERE ma_nv = @ma_nv;

    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
-- ko xóa thật, chỉ set trang_thai =0 để ko hiện lên list
EXEC dbo.SP_NhanVien_Delete 
    @ma_nv = 't',
    @nguoi_xoa = 'admin';
	 

-- Lấy danh sách auditors -- có thể từ đây lấy thông tin gửi mail outlook
CREATE OR ALTER PROCEDURE dbo.SP_NhanVien_GetAuditors
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ma_nv, ho_ten, bo_phan FROM dbo.NHAN_VIEN
    WHERE la_kiem_tra = 1 AND trang_thai = 1
    ORDER BY ho_ten;
END;
GO
EXEC dbo.SP_NhanVien_GetAuditors
    

-- ============================================================
-- SP_TRUC_BAN: Duty Schedule
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_TrucBan_GetList
    @tu_ngay    DATE = NULL,
    @den_ngay   DATE = NULL,
    @ma_nv      NVARCHAR(20) = NULL,
    @page       INT = 1,
    @page_size  INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @offset INT = (@page - 1) * @page_size;
    SELECT
        tb.id, tb.ngay_truc, tb.ma_nv, nv.ho_ten, tb.ca_truc,
        tb.da_gui_mail, tb.thoi_gian_gui, tb.ghi_chu, tb.ngay_tao,
        COUNT(*) OVER() AS total_count
    FROM dbo.PHAN_CONG_TRUC_BAN tb
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = tb.ma_nv
    WHERE (@tu_ngay  IS NULL OR tb.ngay_truc >= @tu_ngay)
      AND (@den_ngay IS NULL OR tb.ngay_truc <= @den_ngay)
      AND (@ma_nv    IS NULL OR tb.ma_nv = @ma_nv)
    ORDER BY tb.ngay_truc DESC, tb.ca_truc
    OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;
END;
GO
EXEC dbo.SP_TrucBan_GetList;
EXEC dbo.SP_TrucBan_GetList -- lọc theo ngày
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-12';
EXEC dbo.SP_TrucBan_GetList -- list theo mã nv
    @ma_nv = '50236917';


CREATE OR ALTER   PROCEDURE [dbo].[SP_TrucBan_Insert]
    @ngay_truc  DATE,
    @ma_nv      NVARCHAR(20),
    @ca_truc    NVARCHAR(20) = 'day',
    @ghi_chu    NVARCHAR(255) = NULL,
    @nguoi_tao  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.PHAN_CONG_TRUC_BAN
            (ngay_truc, ma_nv, ca_truc, ghi_chu, nguoi_tao)
        VALUES
            (@ngay_truc, @ma_nv, @ca_truc, @ghi_chu, @nguoi_tao);

        SELECT SCOPE_IDENTITY() AS id, N'OK' AS msg;
    END TRY
    BEGIN CATCH
        SELECT -1 AS id, ERROR_MESSAGE() AS msg;
    END CATCH
END;
GO
EXEC dbo.SP_TrucBan_Insert
    @ngay_truc = '2026-05-14',
    @ma_nv = '50236917',
    @ca_truc = 'day',
    @ghi_chu = N'test',
    @nguoi_tao = 'admin';

-- update Phân công trực ban
CREATE OR ALTER   PROCEDURE [dbo].[SP_TrucBan_Update]
    @id             INT,
    @ngay_truc      DATE = NULL,
    @ma_nv          NVARCHAR(20) = NULL,
    @ca_truc        NVARCHAR(20) = NULL,
    @da_gui_mail    BIT = NULL,
    @thoi_gian_gui  DATETIME2 = NULL,
    @ghi_chu        NVARCHAR(255) = NULL,
    @nguoi_cap_nhat NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- kiểm tra tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM dbo.PHAN_CONG_TRUC_BAN WHERE id = @id
    )
    BEGIN
        SELECT -1 AS id, N'Không tồn tại bản ghi' AS msg;
        RETURN;
    END

    -- update
    UPDATE dbo.PHAN_CONG_TRUC_BAN
    SET
        ngay_truc     = COALESCE(@ngay_truc, ngay_truc),
        ma_nv         = COALESCE(@ma_nv, ma_nv),
        ca_truc       = COALESCE(@ca_truc, ca_truc),
        da_gui_mail   = COALESCE(@da_gui_mail, da_gui_mail),
        thoi_gian_gui = COALESCE(@thoi_gian_gui, thoi_gian_gui),
        ghi_chu       = COALESCE(@ghi_chu, ghi_chu),
        nguoi_tao     = @nguoi_cap_nhat
    WHERE id = @id;

    SELECT @id AS id, N'OK' AS msg;
END;
GO
EXEC dbo.SP_TrucBan_Update
    @id = 6,
    @ca_truc = 'night',
    @ghi_chu = N'đổi ca',
    @nguoi_cap_nhat = 'admin';

CREATE OR ALTER PROCEDURE dbo.SP_TrucBan_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.PHAN_CONG_TRUC_BAN WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_TrucBan_Delete @id =7;

-- ============================================================
-- SP_KIEM_TRA: Inspection Time Records
-- ============================================================
 --tìm theo mã và tên nhân viên
CREATE OR ALTER   PROCEDURE [dbo].[SP_KiemTra_GetList]
    @keyword    NVARCHAR(100) = NULL,
    @tu_ngay    DATETIME2     = NULL,
    @den_ngay   DATETIME2     = NULL,
    @page       INT           = 1,
    @page_size  INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@page - 1) * @page_size;

    SELECT
        kt.id,
        kt.thoi_gian_he_thong,
        kt.thoi_gian_bat_dau,
        kt.thoi_gian_ket_thuc,
        kt.khu_vuc,
        kt.ma_nv_kiem_tra,
        nv.ho_ten AS ten_nguoi_kiem_tra,
        kt.ghi_chu,
        kt.ngay_tao,
        kt.nguoi_tao,
        COUNT(*) OVER() AS total_count
    FROM dbo.KIEM_TRA_THOI_GIAN kt
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = kt.ma_nv_kiem_tra
    WHERE ( @keyword IS NULL OR kt.ma_nv_kiem_tra LIKE '%' + @keyword + '%' OR nv.ho_ten LIKE '%' + @keyword + '%')
      AND (@tu_ngay IS NULL OR kt.thoi_gian_bat_dau >= @tu_ngay)
      AND (@den_ngay IS NULL OR kt.thoi_gian_bat_dau < DATEADD(DAY, 1, @den_ngay))

    ORDER BY kt.thoi_gian_he_thong DESC   -- hoặc kt.id DESC

    OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;
END;
GO
EXEC dbo.SP_KiemTra_GetList;
EXEC dbo.SP_KiemTra_GetList
    @keyword = '东';
EXEC dbo.SP_KiemTra_GetList
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-12';
EXEC dbo.SP_KiemTra_GetList
    @page = 1,
    @page_size = 10;


-- View của thông tin KIEM TRA, CAI THIEN, VI PHẠM
CREATE OR ALTER PROCEDURE dbo.SP_KiemTra_GetById_View
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        kt.id,
        kt.thoi_gian_he_thong,
        kt.thoi_gian_bat_dau,
        kt.thoi_gian_ket_thuc,
        kt.khu_vuc,
        kt.ma_nv_kiem_tra,
        nv.ho_ten AS ten_nguoi_kiem_tra,
        kt.ghi_chu as ghi_chu_kiemtra,

		ct.id AS cai_thien_id,
		ct.ngay_kiem_tra,
		ct.ten_bo_phan_phu_trach,
        ct.hien_tuong,
		ct.ghi_chu as ghi_chu_caithien,

        vp.id AS vi_pham_id,
		vp.ten_bo_phan,
        vp.ma_nv AS ma_nv_vi_pham,
		vp.ho_ten as ho_ten_vi_pham,
		vp.thoi_gian_vi_pham,
		vp.dia_diem,
		vp.ten_cap_tren,
		vp.email_cc,
        vp.hien_tuong_vi_pham

    FROM dbo.KIEM_TRA_THOI_GIAN kt
    LEFT JOIN dbo.NHAN_VIEN nv 
        ON nv.ma_nv = kt.ma_nv_kiem_tra

    LEFT JOIN dbo.VI_PHAM_KY_LUAT vp 
        ON vp.id_kiem_tra = kt.id

    LEFT JOIN dbo.HANG_MUC_CAI_THIEN ct 
        ON ct.id_kiem_tra = kt.id

    WHERE kt.id = @id;
END;
GO
exec dbo.SP_KiemTra_GetById_View @id =11

-- Insert tổng hợp: 1 lần kiểm tra có thể có cải thiện + vi phạm
CREATE OR ALTER PROCEDURE dbo.SP_KiemTra_Insert
    @thoi_gian_bat_dau  DATETIME2,
    @thoi_gian_ket_thuc DATETIME2,
    @khu_vuc            NVARCHAR(500),
    @ma_nv_kiem_tra     NVARCHAR(20),
    @ghi_chu            NVARCHAR(500) = NULL,
    @nguoi_tao          NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    -- Validate: Kết thúc phải sau bắt đầu
    IF @thoi_gian_ket_thuc <= @thoi_gian_bat_dau
    BEGIN
        RAISERROR(N'Thời gian kết thúc phải sau thời gian bắt đầu', 16, 1);
        RETURN;
    END
    INSERT INTO dbo.KIEM_TRA_THOI_GIAN
        (thoi_gian_bat_dau, thoi_gian_ket_thuc, khu_vuc, ma_nv_kiem_tra, ghi_chu, nguoi_tao)
    VALUES
        (@thoi_gian_bat_dau, @thoi_gian_ket_thuc, @khu_vuc, @ma_nv_kiem_tra, @ghi_chu, @nguoi_tao);
    SELECT SCOPE_IDENTITY() AS id;
END;
GO
EXEC dbo.SP_KiemTra_Insert
    @thoi_gian_bat_dau  = '2026-05-15 08:00:00',
    @thoi_gian_ket_thuc = '2026-05-15 10:00:00',
    @khu_vuc            = N'负1-1楼,2-3楼 test ',
    @ma_nv_kiem_tra     = '30000176',
    @ghi_chu            = N'巡检正常 test ',
    @nguoi_tao          = 'admin';

CREATE OR ALTER PROCEDURE dbo.SP_KiemTra_Update
    @id                 INT,
    @thoi_gian_bat_dau  DATETIME2,
    @thoi_gian_ket_thuc DATETIME2,
    @khu_vuc            NVARCHAR(500),
    @ghi_chu            NVARCHAR(500) = NULL,
    @nguoi_cap_nhat     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.KIEM_TRA_THOI_GIAN SET
        thoi_gian_bat_dau  = @thoi_gian_bat_dau,
        thoi_gian_ket_thuc = @thoi_gian_ket_thuc,
        khu_vuc            = @khu_vuc,
        ghi_chu            = @ghi_chu,
        ngay_cap_nhat      = GETDATE(),
        nguoi_cap_nhat     = @nguoi_cap_nhat
    WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_KiemTra_Update
    @id                 = 10,
    @thoi_gian_bat_dau  = '2026-05-13 08:30:00',
    @thoi_gian_ket_thuc = '2026-05-13 10:30:00',
    @khu_vuc            = N'4-5楼,6-8楼 new',
    @ghi_chu            = N'更新巡检记录',
    @nguoi_cap_nhat     = 'admin';
	
CREATE OR ALTER PROCEDURE dbo.SP_KiemTra_Delete
    @id         INT,
    @nguoi_xoa  NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    -- Xóa cascade con trước
    DELETE FROM dbo.HANG_MUC_CAI_THIEN WHERE id_kiem_tra = @id;
    DELETE FROM dbo.VI_PHAM_KY_LUAT     WHERE id_kiem_tra = @id;
    DELETE FROM dbo.KIEM_TRA_THOI_GIAN  WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

EXEC dbo.SP_KiemTra_Delete
    @id = 8,
    @nguoi_xoa = 'admin';

SELECT *
FROM dbo.KIEM_TRA_THOI_GIAN
ORDER BY id DESC;

-- Export to Excel: trả về full data không phân trang
CREATE OR ALTER PROCEDURE dbo.SP_KiemTra_Export
    @ma_nv      NVARCHAR(20) = NULL,
    @tu_ngay    DATETIME2    = NULL,
    @den_ngay   DATETIME2    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        kt.id,
		nv.ho_ten AS ten_nguoi_kiem_tra,
		nv.ma_nv AS ma_nguoi_kiem_tra,
        FORMAT(kt.thoi_gian_he_thong, 'yyyy-MM-dd HH:mm:ss') AS thoi_gian_he_thong,
        FORMAT(kt.thoi_gian_bat_dau,  'yyyy-MM-dd HH:mm:ss') AS thoi_gian_bat_dau,
        FORMAT(kt.thoi_gian_ket_thuc, 'yyyy-MM-dd HH:mm:ss') AS thoi_gian_ket_thuc,
        kt.khu_vuc,
        kt.ghi_chu
    FROM dbo.KIEM_TRA_THOI_GIAN kt
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = kt.ma_nv_kiem_tra
    WHERE (@ma_nv IS NULL OR kt.ma_nv_kiem_tra = @ma_nv)
      AND (@tu_ngay IS NULL OR kt.thoi_gian_bat_dau >= @tu_ngay)
      AND (@den_ngay IS NULL OR kt.thoi_gian_bat_dau < DATEADD(DAY, 1, @den_ngay))
    ORDER BY kt.thoi_gian_bat_dau DESC;
END;
GO
EXEC dbo.SP_KiemTra_Export
    @ma_nv = 'ADM001';
EXEC dbo.SP_KiemTra_Export
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-31';
  
-- ============================================================
-- SP_CAI_THIEN: Improvement Items
-- ============================================================
-- có tìm theo keyword hiện tượng mô tả, lọc filter ngày kiểm tra, tìm theo mã nv 
CREATE OR ALTER PROCEDURE dbo.SP_CaiThien_GetList
    @tu_ngay    DATE          = NULL,
    @den_ngay   DATE          = NULL,
    @ma_nv      NVARCHAR(20)  = NULL,
    @page       INT           = 1,
    @page_size  INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@page - 1) * @page_size;

    SELECT
        ct.id,
        ct.id_kiem_tra,
        ct.ngay_kiem_tra,
        ct.hien_tuong,
        ct.ten_bo_phan_phu_trach,
        ct.ma_nv_kiem_tra,
        nv.ho_ten AS ten_nguoi_kiem_tra,
        ct.ghi_chu,
        ct.ngay_tao,
        COUNT(*) OVER() AS total_count

    FROM dbo.HANG_MUC_CAI_THIEN ct

    LEFT JOIN dbo.NHAN_VIEN nv
        ON nv.ma_nv = ct.ma_nv_kiem_tra

    WHERE (@tu_ngay  IS NULL OR ct.ngay_kiem_tra >= @tu_ngay)
      AND (@den_ngay IS NULL OR ct.ngay_kiem_tra <= @den_ngay)
      AND (@ma_nv    IS NULL OR ct.ma_nv_kiem_tra = @ma_nv)

    ORDER BY
        ct.ngay_tao DESC,
        ct.id DESC

    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO
EXEC dbo.SP_CaiThien_GetList
    @ma_nv = '30000176';
EXEC dbo.SP_CaiThien_GetList
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-31';
EXEC dbo.SP_CaiThien_GetList
    @page = 2,
    @page_size = 10;

CREATE OR ALTER PROCEDURE dbo.SP_CaiThien_Insert
    @id_kiem_tra            INT           = NULL,
    @ngay_kiem_tra          DATE          = NULL,
    @hien_tuong             NVARCHAR(MAX) = NULL,
    @ten_bo_phan_phu_trach  NVARCHAR(100) = NULL,
    @ma_nv_kiem_tra         NVARCHAR(20)  = NULL,
    @ghi_chu                NVARCHAR(500) = NULL,
    @nguoi_tao              NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        INSERT INTO dbo.HANG_MUC_CAI_THIEN
        (
            id_kiem_tra,
            ngay_kiem_tra,
            hien_tuong,
            ten_bo_phan_phu_trach,
            ma_nv_kiem_tra,
            ghi_chu,
            nguoi_tao
        )
        VALUES
        (
            @id_kiem_tra,
            @ngay_kiem_tra,
            @hien_tuong,
            @ten_bo_phan_phu_trach,
            @ma_nv_kiem_tra,
            @ghi_chu,
            @nguoi_tao
        );

        SELECT
            SCOPE_IDENTITY() AS id,
            N'OK' AS msg;

    END TRY

    BEGIN CATCH

        SELECT
            -1 AS id,
            ERROR_MESSAGE() AS msg;

    END CATCH
END;
GO
EXEC dbo.SP_CaiThien_Insert
    @id_kiem_tra = 2,
    @ngay_kiem_tra = '2026-05-13',
    @hien_tuong = N'消防通道堵塞',
    @ten_bo_phan_phu_trach = N'外销生产',
    @ma_nv_kiem_tra = '30000176',
    @ghi_chu = N'今日改善',
    @nguoi_tao = 'admin';

CREATE OR ALTER PROCEDURE dbo.SP_CaiThien_Update
    @id                     INT,
    @ngay_kiem_tra          DATE          = NULL,
    @hien_tuong             NVARCHAR(MAX) = NULL,
    @ten_bo_phan_phu_trach  NVARCHAR(100) = NULL,
    @ghi_chu                NVARCHAR(500) = NULL,
    @nguoi_cap_nhat         NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE dbo.HANG_MUC_CAI_THIEN
        SET
            ngay_kiem_tra =
                COALESCE(@ngay_kiem_tra, ngay_kiem_tra),

            hien_tuong =
                COALESCE(@hien_tuong, hien_tuong),

            ten_bo_phan_phu_trach =
                COALESCE(@ten_bo_phan_phu_trach, ten_bo_phan_phu_trach),

            ghi_chu =
                COALESCE(@ghi_chu, ghi_chu),

            ngay_cap_nhat = GETDATE(),

            nguoi_cap_nhat = @nguoi_cap_nhat

        WHERE id = @id;

        SELECT
            @@ROWCOUNT AS rows_affected,
            N'OK' AS msg;

    END TRY

    BEGIN CATCH

        SELECT
            -1 AS rows_affected,
            ERROR_MESSAGE() AS msg;

    END CATCH
END;
GO
EXEC dbo.SP_CaiThien_Update
    @id = 7,
    @hien_tuong = N'new update',
    @nguoi_cap_nhat = 'admin';

CREATE OR ALTER PROCEDURE dbo.SP_CaiThien_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DELETE FROM dbo.HANG_MUC_CAI_THIEN
        WHERE id = @id;
        SELECT
            @@ROWCOUNT AS rows_affected,
            N'OK' AS msg;
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS rows_affected,
            ERROR_MESSAGE() AS msg;
    END CATCH
END;
GO
EXEC dbo.SP_CaiThien_Delete
    @id = 7;

CREATE PROCEDURE dbo.SP_CaiThien_Export
    @tu_ngay   DATE = NULL,
    @den_ngay  DATE = NULL,
    @bo_phan   NVARCHAR(100) = NULL,
    @ma_nv     NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ct.id,
        ct.id_kiem_tra,
        ct.ngay_kiem_tra,
        ct.hien_tuong,
        ct.ten_bo_phan_phu_trach,

        ct.ma_nv_kiem_tra,
        nv.ho_ten AS ten_nguoi_kiem_tra,

        ct.ghi_chu,
        ct.ngay_tao

    FROM dbo.HANG_MUC_CAI_THIEN ct

    LEFT JOIN dbo.NHAN_VIEN nv
        ON nv.ma_nv = ct.ma_nv_kiem_tra

    WHERE
        (@tu_ngay IS NULL
            OR ct.ngay_kiem_tra >= @tu_ngay)

        AND (@den_ngay IS NULL
            OR ct.ngay_kiem_tra <= @den_ngay)

        AND (@bo_phan IS NULL
            OR ct.ten_bo_phan_phu_trach = @bo_phan)

        AND (@ma_nv IS NULL
            OR ct.ma_nv_kiem_tra = @ma_nv)

    ORDER BY
        ct.ngay_kiem_tra DESC,
        ct.id DESC;
END;
GO

EXEC dbo.SP_CaiThien_Export
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-31';
   

-- ============================================================
-- SP_VI_PHAM: Violations
-- ============================================================
-- có thể search theo phạm vi ngày, trạng thái đã xử phạt chưa, keyword: tên, mã người vi phạm, mô tả vi phạm
CREATE OR ALTER PROCEDURE dbo.SP_ViPham_GetList
    @keyword      NVARCHAR(200) = NULL,
    @tu_ngay      DATETIME2     = NULL,
    @den_ngay     DATETIME2     = NULL,
    @trang_thai   NVARCHAR(20)  = NULL,
    @page         INT           = 1,
    @page_size    INT           = 25
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @offset INT = (@page - 1) * @page_size;

    SELECT
        vp.id,
        vp.id_kiem_tra,

        vp.ten_bo_phan,
        vp.ma_nv as ma_nv_vipham,
        vp.ho_ten as ten_nv_vipham,

        vp.thoi_gian_vi_pham,
        vp.dia_diem,
        vp.hien_tuong_vi_pham,

        vp.ma_nv_kiem_tra,
        nv_kt.ho_ten AS ten_nguoi_kiem_tra,

        vp.bien_phap_xu_phat,
        vp.ten_cap_tren,
        vp.email_cc,

        vp.trang_thai_dong,

        vp.ngay_tao,
        vp.nguoi_tao,
        vp.ngay_cap_nhat,

        COUNT(*) OVER() AS total_count

    FROM dbo.VI_PHAM_KY_LUAT vp

    LEFT JOIN dbo.NHAN_VIEN nv_kt
        ON nv_kt.ma_nv = vp.ma_nv_kiem_tra
	LEFT JOIN dbo.KIEM_TRA_THOI_GIAN kt
        ON kt.id = vp.id_kiem_tra

    WHERE
        (@tu_ngay IS NULL
            OR vp.thoi_gian_vi_pham >= @tu_ngay)

        AND (@den_ngay IS NULL
            OR vp.thoi_gian_vi_pham < DATEADD(DAY, 1, @den_ngay))

        AND (@trang_thai IS NULL
            OR vp.trang_thai_dong = @trang_thai)

        AND (
                @keyword IS NULL
                OR vp.ho_ten LIKE N'%' + @keyword + '%'
                OR vp.ma_nv LIKE '%' + @keyword + '%'
                OR vp.hien_tuong_vi_pham LIKE N'%' + @keyword + '%'
            )

    ORDER BY
        vp.ngay_tao DESC,
        vp.id DESC

    OFFSET @offset ROWS
    FETCH NEXT @page_size ROWS ONLY;
END;
GO
EXEC dbo.SP_ViPham_GetList;
EXEC dbo.SP_ViPham_GetList
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-13';
EXEC dbo.SP_ViPham_GetList
    @trang_thai = N'未关闭';
EXEC dbo.SP_ViPham_GetList
    @keyword = N'消防';

	-- lấy ra thông tin bảng Vi Phạm và ID của KIỂM tra và Tên nhân viên
CREATE OR ALTER PROCEDURE dbo.SP_ViPham_GetById
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT vp.*, kt.id as id_kiemtra2,nv.ho_ten AS ten_nguoi_kiem_tra
    FROM dbo.VI_PHAM_KY_LUAT vp
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = vp.ma_nv_kiem_tra
	LEFT JOIN dbo.KIEM_TRA_THOI_GIAN kt ON kt.id = vp.id_kiem_tra
    WHERE vp.id = @id;
END;
GO
EXEC dbo.SP_ViPham_GetById @id = 3;

-- sau này front end: tạo data của KIEMTRA_THOIGIAN trước, sau đó lấy id_kieremtra và ma_nv_kiem_tra từ bảng KIEMTRA_THOIGIAN để insert
CREATE OR ALTER PROCEDURE dbo.SP_ViPham_Insert
    @id_kiem_tra        INT           = NULL,
    @ten_bo_phan        NVARCHAR(100) = NULL,
    @ma_nv              NVARCHAR(20)  = NULL,
    @ho_ten             NVARCHAR(100) = NULL,
    @thoi_gian_vi_pham  DATETIME2,
    @dia_diem           NVARCHAR(200) = NULL,
    @hien_tuong_vi_pham NVARCHAR(MAX) = NULL,
    @ma_nv_kiem_tra     NVARCHAR(20)  = NULL,
    @bien_phap_xu_phat  NVARCHAR(MAX) = NULL,
    @ten_cap_tren       NVARCHAR(100) = NULL,
    @email_cc           NVARCHAR(500) = NULL,
    @nguoi_tao          NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.VI_PHAM_KY_LUAT
        (id_kiem_tra, ten_bo_phan, ma_nv, ho_ten, thoi_gian_vi_pham, dia_diem,
         hien_tuong_vi_pham, ma_nv_kiem_tra, bien_phap_xu_phat, ten_cap_tren, email_cc, nguoi_tao)
    VALUES
        (@id_kiem_tra, @ten_bo_phan, @ma_nv, @ho_ten, @thoi_gian_vi_pham, @dia_diem,
         @hien_tuong_vi_pham, @ma_nv_kiem_tra, @bien_phap_xu_phat, @ten_cap_tren, @email_cc, @nguoi_tao);
    SELECT SCOPE_IDENTITY() AS id;
END;
GO

EXEC dbo.SP_ViPham_Insert
    @id_kiem_tra = 9,
    @ten_bo_phan = N'Sản xuất',
    @ma_nv = '30145888',
    @ho_ten = N'Nguyễn Văn A',
    @thoi_gian_vi_pham = '2026-05-15 10:30:00',
    @dia_diem = N'Khu A - Line 1',
    @hien_tuong_vi_pham = N'Không đeo bảo hộ lao động',
    @ma_nv_kiem_tra = '30000176',
    @bien_phap_xu_phat = N'Nhắc nhở + ghi biên bản',
    @ten_cap_tren = N'Trưởng chuyền A',
    @email_cc = 'hr@company.com',
    @nguoi_tao = 'admin';


CREATE OR ALTER PROCEDURE dbo.SP_ViPham_Update
    @id                 INT,
    @ten_bo_phan        NVARCHAR(100) = NULL,
    @ma_nv              NVARCHAR(20)  = NULL,
    @ho_ten             NVARCHAR(100) = NULL,
    @thoi_gian_vi_pham  DATETIME2     = NULL,
    @dia_diem           NVARCHAR(200) = NULL,
    @hien_tuong_vi_pham NVARCHAR(MAX) = NULL,
    @bien_phap_xu_phat  NVARCHAR(MAX) = NULL,
    @ten_cap_tren       NVARCHAR(100) = NULL,
    @email_cc           NVARCHAR(500) = NULL,
    @trang_thai_dong    NVARCHAR(20)  = NULL,
    @nguoi_cap_nhat     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.VI_PHAM_KY_LUAT SET
        ten_bo_phan        = COALESCE(@ten_bo_phan, ten_bo_phan),
        ma_nv              = COALESCE(@ma_nv, ma_nv),
        ho_ten             = COALESCE(@ho_ten, ho_ten),
        thoi_gian_vi_pham  = COALESCE(@thoi_gian_vi_pham, thoi_gian_vi_pham),
        dia_diem           = COALESCE(@dia_diem, dia_diem),
        hien_tuong_vi_pham = COALESCE(@hien_tuong_vi_pham, hien_tuong_vi_pham),
        bien_phap_xu_phat  = @bien_phap_xu_phat,
        ten_cap_tren       = COALESCE(@ten_cap_tren, ten_cap_tren),
        email_cc           = COALESCE(@email_cc, email_cc),
        trang_thai_dong    = COALESCE(@trang_thai_dong, trang_thai_dong),
        ngay_cap_nhat      = GETDATE(),
        nguoi_cap_nhat     = @nguoi_cap_nhat
    WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

EXEC dbo.SP_ViPham_Update
    @id = 7,
    @ten_bo_phan = N'Sản xuất',
    @ma_nv = '30000176',
    @ho_ten = N'Nguyễn Văn A (Updated)',
    @thoi_gian_vi_pham = '2026-05-13 09:00:00',
    @dia_diem = N'Khu B - Line 2',
    @hien_tuong_vi_pham = N'Không đội mũ bảo hộ',
    @bien_phap_xu_phat = N'Cảnh cáo',
    @ten_cap_tren = N'Trưởng chuyền B',
    @email_cc = 'hr@company.com',
    @trang_thai_dong = N'已关闭',
    @nguoi_cap_nhat = 'admin';

--SP_ViPham_Insert:	tạo mới
--SP_ViPham_Update:	sửa toàn bộ
--SP_ViPham_UpdateXuPhat:	xử lý sau vi phạm (Chỉ cập nhật biện pháp xử phạt + trạng thái (cho audit user) )
CREATE OR ALTER PROCEDURE dbo.SP_ViPham_UpdateXuPhat
    @id                 INT,
    @bien_phap_xu_phat  NVARCHAR(MAX),
    @trang_thai_dong    NVARCHAR(20),
    @nguoi_cap_nhat     NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.VI_PHAM_KY_LUAT SET
        bien_phap_xu_phat = @bien_phap_xu_phat,
        trang_thai_dong   = @trang_thai_dong,
        ngay_cap_nhat     = GETDATE(),
        nguoi_cap_nhat    = @nguoi_cap_nhat
    WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_ViPham_UpdateXuPhat
    @id = 7,
    @bien_phap_xu_phat = N'Cảnh cáo + training lại an toàn',
    @trang_thai_dong = N'已关闭',
    @nguoi_cap_nhat = 'admin';

CREATE OR ALTER PROCEDURE dbo.SP_ViPham_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.VI_PHAM_KY_LUAT WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_ViPham_Delete @id = 3;

-- nếu muốn có thể tìm theo thời gian vi phạm hoặc từ khóa theo tên, mã người audit, mô tả hiện tượng hoặc trạng thái chưa xử phạt '未关闭'
CREATE OR ALTER PROCEDURE dbo.SP_ViPham_Export
    @tu_ngay     DATETIME2 = NULL,
    @den_ngay    DATETIME2 = NULL,
    @keyword     NVARCHAR(200) = NULL,
    @trang_thai  NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        vp.id,
        vp.ten_bo_phan,
        vp.ma_nv as ma_nv_vipham ,
        vp.ho_ten as ten_nv_vipham,

        FORMAT(vp.thoi_gian_vi_pham, 'yyyy-MM-dd HH:mm') AS thoi_gian_vi_pham,

        vp.dia_diem,
        vp.hien_tuong_vi_pham,

		nv.ma_nv AS ma_nguoi_kiem_tra,
        nv.ho_ten AS ten_nguoi_kiem_tra,

        vp.bien_phap_xu_phat,
        vp.ten_cap_tren,
		vp.email_cc,
        vp.trang_thai_dong

    FROM dbo.VI_PHAM_KY_LUAT vp
    LEFT JOIN dbo.NHAN_VIEN nv
        ON nv.ma_nv = vp.ma_nv_kiem_tra

    WHERE
        (@tu_ngay IS NULL OR vp.thoi_gian_vi_pham >= @tu_ngay)
        AND (@den_ngay IS NULL OR vp.thoi_gian_vi_pham < DATEADD(DAY, 1, @den_ngay))
        AND (@trang_thai IS NULL OR vp.trang_thai_dong = @trang_thai)
        AND (
            @keyword IS NULL
            OR nv.ho_ten LIKE N'%' + @keyword + '%'
            OR vp.hien_tuong_vi_pham LIKE N'%' + @keyword + '%'
			OR vp.ma_nv_kiem_tra LIKE '%' + @keyword + '%'
        )

    ORDER BY vp.thoi_gian_vi_pham DESC;
END;
GO
EXEC dbo.SP_ViPham_Export;
EXEC dbo.SP_ViPham_Export
    @tu_ngay = '2026-05-01',
    @den_ngay = '2026-05-13';
EXEC dbo.SP_ViPham_Export
    @trang_thai = N'未关闭';
-- ============================================================
-- SP_TAI_KHOAN: User account management
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_TaiKhoan_GetList
    @page INT = 1, @page_size INT = 25
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @offset INT = (@page-1)*@page_size;
    SELECT
        tk.id, tk.ten_dang_nhap, tk.ma_nv, nv.ho_ten,
        tk.email, tk.vai_tro, tk.ngon_ngu, tk.trang_thai, tk.ngay_tao,
        COUNT(*) OVER() AS total_count
    FROM dbo.TAI_KHOAN tk
    LEFT JOIN dbo.NHAN_VIEN nv ON nv.ma_nv = tk.ma_nv
    ORDER BY tk.ngay_tao DESC
    OFFSET @offset ROWS FETCH NEXT @page_size ROWS ONLY;
END;
GO
EXEC dbo.SP_TaiKhoan_GetList;
EXEC dbo.SP_TaiKhoan_GetList
    @page = 1,
    @page_size = 25;

CREATE OR ALTER PROCEDURE dbo.SP_TaiKhoan_Insert
    @ten_dang_nhap  NVARCHAR(50),
    @mat_khau_hash  NVARCHAR(255),
    @ma_nv          NVARCHAR(20) = NULL,
    @email          NVARCHAR(200) = NULL,
    @vai_tro        NVARCHAR(20) = 'audit',
    @nguoi_tao      NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS(SELECT 1 FROM dbo.TAI_KHOAN WHERE ten_dang_nhap = @ten_dang_nhap)
    BEGIN
        SELECT -1 AS id, N'Tên đăng nhập đã tồn tại' AS msg; RETURN;
    END
    INSERT INTO dbo.TAI_KHOAN (ten_dang_nhap, mat_khau_hash, ma_nv, email, vai_tro, nguoi_tao)
    VALUES (@ten_dang_nhap, @mat_khau_hash, @ma_nv, @email, @vai_tro, @nguoi_tao);
    SELECT SCOPE_IDENTITY() AS id, N'OK' AS msg;
END;
GO
EXEC dbo.SP_TaiKhoan_Insert
    @ten_dang_nhap = 'admin01',
    @mat_khau_hash = '123456_hash',
    @ma_nv = 'MGR_ZHANG',
    @email = 'admin@test.com',
    @vai_tro = 'audit1',
    @nguoi_tao = 'system';

CREATE OR ALTER PROCEDURE dbo.SP_TaiKhoan_ResetPassword
    @id             INT,
    @mat_khau_hash  NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TAI_KHOAN SET mat_khau_hash = @mat_khau_hash WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_TaiKhoan_ResetPassword
    @id = 10,
    @mat_khau_hash = 'new_password_hash';

CREATE OR ALTER PROCEDURE dbo.SP_TaiKhoan_SetStatus
    @id         INT,
    @trang_thai BIT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.TAI_KHOAN SET trang_thai = @trang_thai WHERE id = @id;
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO
EXEC dbo.SP_TaiKhoan_SetStatus
    @id = 10,
    @trang_thai = 0;

-- ============================================================
-- SP_DASHBOARD: Thống kê tổng hợp
-- ============================================================
CREATE OR ALTER PROCEDURE dbo.SP_Dashboard_Summary
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @month_start DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    SELECT
        (SELECT COUNT(*) FROM dbo.KIEM_TRA_THOI_GIAN WHERE CAST(ngay_tao AS DATE) = @today) AS kiem_tra_hom_nay,
        (SELECT COUNT(*) FROM dbo.VI_PHAM_KY_LUAT WHERE trang_thai_dong = N'未关闭') AS vi_pham_chua_dong,
        (SELECT COUNT(*) FROM dbo.VI_PHAM_KY_LUAT WHERE thoi_gian_vi_pham >= @month_start) AS vi_pham_thang_nay,
        (SELECT COUNT(*) FROM dbo.HANG_MUC_CAI_THIEN WHERE ngay_kiem_tra >= @month_start) AS cai_thien_thang_nay,
        (SELECT COUNT(*) FROM dbo.PHAN_CONG_TRUC_BAN WHERE ngay_truc = @today) AS truc_ban_hom_nay;
END;
GO
EXEC dbo.SP_Dashboard_Summary

PRINT 'Stored Procedures created successfully.';
GO
