-- ============================================================
-- FACTORY MANAGEMENT SYSTEM - DATABASE SCHEMA
-- Microsoft SQL Server
-- ============================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'FactoryManagement')
    CREATE DATABASE FactoryManagement
    COLLATE Chinese_PRC_CI_AS;
GO

USE FactoryManagement;
GO

-- ============================================================
-- 1. NHAN_VIEN (Employees / 员工)
-- ============================================================
IF OBJECT_ID('dbo.NHAN_VIEN', 'U') IS NULL
CREATE TABLE dbo.NHAN_VIEN (
    ma_nv           NVARCHAR(20)  NOT NULL PRIMARY KEY,   -- 工号
    ho_ten          NVARCHAR(100) NOT NULL,                -- 姓名
    bo_phan			NVARCHAR(20) ,
    chuc_vu         NVARCHAR(100),
    email           NVARCHAR(200) NOT NULL,
    dien_thoai      NVARCHAR(20),
    la_quan_ly      BIT DEFAULT 0,           -- 1 = manager/superior
    la_kiem_tra     BIT DEFAULT 1,           -- 1 = can do audit
    trang_thai      BIT DEFAULT 1,
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    ngay_cap_nhat   DATETIME2,
    nguoi_tao       NVARCHAR(50)
);

-- ============================================================
-- 2. TAI_KHOAN (User Accounts / 账号)
-- ============================================================
IF OBJECT_ID('dbo.TAI_KHOAN', 'U') IS NULL
CREATE TABLE dbo.TAI_KHOAN (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    ten_dang_nhap   NVARCHAR(50)  NOT NULL UNIQUE,
    mat_khau_hash   NVARCHAR(255) NOT NULL,
    ma_nv           NVARCHAR(20)  REFERENCES dbo.NHAN_VIEN(ma_nv),
    email           NVARCHAR(200),
    vai_tro         NVARCHAR(20)  NOT NULL DEFAULT 'audit',  -- 'admin','audit','viewer'
    ngon_ngu        NVARCHAR(10)  DEFAULT 'zh',
    trang_thai      BIT DEFAULT 1,
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    nguoi_tao       NVARCHAR(50)
);


-- ============================================================
-- 3. PHAN_CONG_TRUC_BAN (Duty Schedule / 值班排班)
-- ============================================================
IF OBJECT_ID('dbo.PHAN_CONG_TRUC_BAN', 'U') IS NULL
CREATE TABLE dbo.PHAN_CONG_TRUC_BAN (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    ngay_truc       DATE          NOT NULL,
    ma_nv           NVARCHAR(20)  NOT NULL REFERENCES dbo.NHAN_VIEN(ma_nv),
    ca_truc         NVARCHAR(20)  DEFAULT 'day',   -- 'day','night'
    da_gui_mail     BIT DEFAULT 0,
    thoi_gian_gui   DATETIME2,
    ghi_chu         NVARCHAR(255),
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    nguoi_tao       NVARCHAR(50),
    CONSTRAINT UQ_TrucBan UNIQUE (ngay_truc, ma_nv, ca_truc) --Không cho phép: 1 nhân viên trực, cùng ca, cùng ngày ,nhiều lần
);

-- ============================================================
-- 4. KIEM_TRA_THOI_GIAN (Inspection Time Records / 巡检时间登记)
-- ============================================================
IF OBJECT_ID('dbo.KIEM_TRA_THOI_GIAN', 'U') IS NULL
CREATE TABLE dbo.KIEM_TRA_THOI_GIAN (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    thoi_gian_he_thong  DATETIME2 DEFAULT GETDATE(),  -- 系统记录时间 -- thời gian thác tác lưu database
    thoi_gian_bat_dau   DATETIME2 NOT NULL,            -- 开始时间 *
    thoi_gian_ket_thuc  DATETIME2 NOT NULL,            -- 结束时间 *
	khu_vuc         NVARCHAR(500) NOT NULL,            -- 巡检区域 (comma-separated or JSON) -- có thể chọn nhiều khu vực ở thẻ select : 负1-1楼, 2-3楼, 4-5楼, 6-8楼, 9-13楼, 1-4楼, 5-8楼, 其他
    ma_nv_kiem_tra  NVARCHAR(20)  REFERENCES dbo.NHAN_VIEN(ma_nv), -- 巡检人员 : thông qua mã lấy tên nv audit                 
    ghi_chu         NVARCHAR(500),                     -- 备注
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    nguoi_tao       NVARCHAR(50),
    ngay_cap_nhat   DATETIME2,
    nguoi_cap_nhat  NVARCHAR(50)
);
 
-- ============================================================
-- 5. HANG_MUC_CAI_THIEN (Improvement Items / 要改善项目登记)
-- ============================================================
IF OBJECT_ID('dbo.HANG_MUC_CAI_THIEN', 'U') IS NULL
CREATE TABLE dbo.HANG_MUC_CAI_THIEN (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    id_kiem_tra     INT           REFERENCES dbo.KIEM_TRA_THOI_GIAN(id),  -- linked audit session
    ngay_kiem_tra   DATE          ,            -- 日期 -- có thể null
    hien_tuong      NVARCHAR(MAX)		,            -- 需改善现象 -- có thể null
    ten_bo_phan_phu_trach NVARCHAR(100), -- 检查区域负责部门 -- 外销生产,  外销工程, 外销品管 ,其他 
    ma_nv_kiem_tra  NVARCHAR(20)  REFERENCES dbo.NHAN_VIEN(ma_nv), -- 检查人: thông qua mã lấy tên nv audit                        
    ghi_chu         NVARCHAR(500),                     -- 备注
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    nguoi_tao       NVARCHAR(50),
    ngay_cap_nhat   DATETIME2,
    nguoi_cap_nhat  NVARCHAR(50)
);

-- ============================================================
-- 6. VI_PHAM_KY_LUAT (Violations / 违纪登记)
-- ============================================================
IF OBJECT_ID('dbo.VI_PHAM_KY_LUAT', 'U') IS NULL
CREATE TABLE dbo.VI_PHAM_KY_LUAT (
    id              INT IDENTITY(1,1) PRIMARY KEY,
    id_kiem_tra     INT           REFERENCES dbo.KIEM_TRA_THOI_GIAN(id),  -- linked audit session
    ten_bo_phan     NVARCHAR(100),                    -- 部门 : tên bộ phận người vi phạm
    ma_nv           NVARCHAR(20),                      -- 工号 : mã NV người vi phạm
    ho_ten          NVARCHAR(100),                     -- 姓名 : họ tên ng vi phạm
    thoi_gian_vi_pham   DATETIME2 NOT NULL,            -- 违纪时间
    dia_diem        NVARCHAR(200),                     -- 发生地点
    hien_tuong_vi_pham  NVARCHAR(MAX),                 -- 违纪现象
    ma_nv_kiem_tra  NVARCHAR(20)  REFERENCES dbo.NHAN_VIEN(ma_nv),  -- 检查人: thông qua mã lấy tên nv audit 
    bien_phap_xu_phat   NVARCHAR(MAX),                 -- 处罚措施
    ten_cap_tren    NVARCHAR(100),
    email_cc        NVARCHAR(500),                     -- 邮件抄送
    trang_thai_dong NVARCHAR(20) DEFAULT N'未关闭',    -- 关闭状态: 未关闭/已关闭
    ngay_tao        DATETIME2 DEFAULT GETDATE(),
    nguoi_tao       NVARCHAR(50),
    ngay_cap_nhat   DATETIME2,
    nguoi_cap_nhat  NVARCHAR(50)
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE NONCLUSTERED INDEX IX_KiemTra_ThoiGian ON dbo.KIEM_TRA_THOI_GIAN(thoi_gian_bat_dau DESC);
CREATE NONCLUSTERED INDEX IX_KiemTra_NV ON dbo.KIEM_TRA_THOI_GIAN(ma_nv_kiem_tra);
CREATE NONCLUSTERED INDEX IX_CaiThien_Ngay ON dbo.HANG_MUC_CAI_THIEN(ngay_kiem_tra DESC);
CREATE NONCLUSTERED INDEX IX_ViPham_ThoiGian ON dbo.VI_PHAM_KY_LUAT(thoi_gian_vi_pham DESC);
CREATE NONCLUSTERED INDEX IX_ViPham_MaNV ON dbo.VI_PHAM_KY_LUAT(ma_nv);


-- ============================================================
-- SEED DATA
-- ============================================================


-- ============================================================
-- INSERT NHAN_VIEN -- Sample employees (managers / supervisors)
-- ============================================================
INSERT INTO dbo.NHAN_VIEN
(ma_nv, ho_ten, bo_phan, chuc_vu, email, dien_thoai, la_quan_ly, la_kiem_tra, nguoi_tao)
VALUES
('ADM001',    N'黄佳东',  N'NGOAI_KT', N'Auditor',         'huangjiadong@company.com', '0900000001', 0, 1, N'admin'),
('MGR_CAO',   N'曹子然',  N'SMT',      N'SMT Manager',     'caozyran@company.com',     '0900000002', 1, 1, N'admin'),
('MGR_YE',    N'叶方俊',  N'SUACHUA',  N'Maintenance MGR', 'yefangjun@company.com',    '0900000003', 1, 1, N'admin'),
('MGR_ZHANG', N'张博文',  N'TCKHOA',   N'Technical MGR',   'zhangbowen@company.com',   '0900000004', 1, 1, N'admin'),
('MGR_BAI',   N'白翁文',  N'MANG',     N'Network Manager', 'baiwengwen@company.com',   '0900000005', 1, 1, N'admin'),
('MGR_TAN',   N'谭婧',    N'QC',       N'QC Manager',      'tanjing@company.com',      '0900000006', 1, 1, N'admin'),
('50236917',  N'陈梓光',  N'BPKHO',    N'Staff',           '',                          '0900000011', 0, 1, N'admin'),
('50237210',  N'何家远',  N'SMT',      N'Operator',        '',                          '0900000012', 0, 1, N'admin'),
('50182892',  N'李超',    N'BPKHO',    N'Warehouse Staff', '',                          '0900000013', 0, 1, N'admin'),
('50229070',  N'范家辉',  N'SUACHUA',  N'Technician',      '',                          '0900000014', 0, 1, N'admin'),
('60109595',  N'杨致娴',  N'TCKHOA',   N'Engineer',        '',                          '0900000015', 0,1, N'admin'),
('50233085',  N'黄建满',  N'TCKHOA',   N'Engineer',        '',                          '0900000016', 0, 1, N'admin'),
('60108092',  N'陈卓杰',  N'TCKHOA',   N'Engineer',        '',                          '0900000017', 0, 1, N'admin'),
('50217252',  N'何政',    N'TCKHOA',   N'Technician',      '',                          '0900000018', 0, 1, N'admin'),
('50142694',  N'陈治升',  N'TCKHOA',   N'Technician',      '',                          '0900000019', 0, 1, N'admin'),
('50113014',  N'邱学操',  N'KT',       N'Inspection Staff','',                          '0900000020', 0, 1, N'admin'),
('50240267',  N'胡磊',    N'BPKHO',    N'Warehouse Staff', '',                          '0900000021', 0, 1, N'admin'),
('50237076',  N'梁志明',  N'BPKHO',    N'Warehouse Staff', '',                          '0900000022', 0, 1, N'admin');


-- ============================================================
-- INSERT TAI_KHOAN
-- Admin account (password: Admin@123)
-- Hash generated via bcrypt
-- ============================================================

INSERT INTO dbo.TAI_KHOAN
(ten_dang_nhap, mat_khau_hash, ma_nv, email, vai_tro, nguoi_tao)
VALUES
('admin',  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMlJbekRSJLx3mmn6YVtbDe26S', 'ADM001', 'admin@company.com',  'admin', N'admin'),
('audit1', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMlJbekRSJLx3mmn6YVtbDe26S', 'ADM001', 'audit1@company.com', 'audit', N'admin');

-- ============================================================
-- INSERT PHAN_CONG_TRUC_BAN
-- ============================================================

INSERT INTO dbo.PHAN_CONG_TRUC_BAN
(ngay_truc, ma_nv, ca_truc, da_gui_mail, thoi_gian_gui, ghi_chu, nguoi_tao)
VALUES
('2026-05-12', 'ADM001',   'day',   1, GETDATE(), N'白班值班', N'admin'),
('2026-05-12', 'MGR_CAO',  'night', 0, NULL,      N'晚班值班', N'admin'),
('2026-05-13', 'MGR_TAN',  'day',   1, GETDATE(), N'QC值班',   N'admin');

-- ============================================================
-- INSERT KIEM_TRA_THOI_GIAN
-- ============================================================

INSERT INTO dbo.KIEM_TRA_THOI_GIAN
(thoi_gian_bat_dau, thoi_gian_ket_thuc, khu_vuc, ma_nv_kiem_tra, ghi_chu, nguoi_tao)
VALUES
('2026-05-12 08:00:00', '2026-05-12 09:00:00', N'负1-1楼,2-3楼', 'ADM001', N'早班巡检', N'admin'),
('2026-05-12 13:00:00', '2026-05-12 14:30:00', N'4-5楼,6-8楼',   'ADM001', N'下午巡检', N'admin'),
('2026-05-13 08:30:00', '2026-05-13 10:00:00', N'9-13楼',        'ADM001', N'仓库检查', N'admin');

-- ============================================================
-- INSERT HANG_MUC_CAI_THIEN
-- ============================================================

INSERT INTO dbo.HANG_MUC_CAI_THIEN
(id_kiem_tra, ngay_kiem_tra, hien_tuong, ten_bo_phan_phu_trach, ma_nv_kiem_tra, ghi_chu, nguoi_tao)
VALUES
(1, '2026-05-12', N'SMT机器下方发现漏油现象，需要立即处理。', N'外销工程', 'ADM001', N'要求当天改善', N'admin'),
(1, '2026-05-12', N'2楼消防器材标签模糊。',                 N'外销生产', 'ADM001', N'重新张贴标签', N'admin'),
(2, '2026-05-12', N'仓库区域物料摆放不整齐。',             N'外销品管', 'ADM001', N'5S整改',       N'admin'),
(3, '2026-05-13', N'部分区域照明不足。',                   N'其他',     'ADM001', N'申请维修',     N'admin');

-- ============================================================
-- INSERT VI_PHAM_KY_LUAT
-- ============================================================

INSERT INTO dbo.VI_PHAM_KY_LUAT
(id_kiem_tra, ten_bo_phan, ma_nv, ho_ten, thoi_gian_vi_pham, dia_diem,
 hien_tuong_vi_pham, ma_nv_kiem_tra, bien_phap_xu_phat,
 ten_cap_tren, email_cc, trang_thai_dong, nguoi_tao)
VALUES
(1, N'SMT',      '50237210', N'何家远', '2026-05-12 08:35:00', N'2-3楼',
 N'未佩戴静电手环进入生产区域。',
 'ADM001',
 N'口头警告并重新培训ESD规范。',
 N'曹子然',
 N'caozyran@company.com',
 N'未关闭',
 N'admin'),

(1, N'BPKHO',    '50236917', N'陈梓光', '2026-05-12 08:50:00', N'负1-1楼',
 N'物料未按规定区域摆放。',
 'ADM001',
 N'要求立即整改。',
 N'黄佳东',
 N'huangjiadong@company.com',
 N'已关闭',
 N'admin'),

(2, N'TCKHOA',   '60109595', N'杨致娴', '2026-05-12 13:40:00', N'6-8楼',
 N'巡检时未填写设备点检表。',
 'ADM001',
 N'补填写点检记录并警告一次。',
 N'张博文',
 N'zhangbowen@company.com',
 N'未关闭',
 N'admin'),

(3, N'SUACHUA',  '50229070', N'范家辉', '2026-05-13 09:20:00', N'9-13楼',
 N'维修工具未按规定归位。',
 'ADM001',
 N'现场整改。',
 N'叶方俊',
 N'yefangjun@company.com',
 N'未关闭',
 N'admin');


PRINT 'Database created successfully.';
GO
