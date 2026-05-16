/**
 * i18n.js — Đa ngôn ngữ: zh / vi / en
 * Dùng: setLang('vi') hoặc applyLang()
 */

const i18n = {
  zh: {
    saveSuccess: '保存成功',
    deleteSuccess: '删除成功',
    saveError: '保存失败',
    
    appName: '广部管理系统', appSub: '厂部管理', appTitle: '广部管理系统',
    navAudit: '巡检', navAdmin: '管理', menuDayShift: '白班巡检记录',
    menuTime: '巡检时间登记', menuImprove: '要改善项目登记', menuViolation: '违纪登记',
    menuStaff: '员工管理', menuSchedule: '值班排班', logout: '退出',
    inspector: '巡检人员:', date: '日期:', keyword: '关键字:', time: '时间:',
    search: '查询', addNew: '新增', columns: '列', export: '导出', save: '保存', close: '关闭',
    colSeq: '序号', colSysTime: '系统记录时间', colStartTime: '开始时间', colEndTime: '结束时间',
    colArea: '巡检区域', colInspector2: '巡检人员', colRemark: '备注', colActions: '操作',
    colDate: '日期', colIssue: '需改善现象', colDept: '违纪部门', colDeptResp: '检查区域负责部门',
    colChecker: '检查人', colEmpId: '违纪工号', colName: '违纪姓名', colVioTime: '违纪时间',
    colLocation: '发生地点', colVioType: '违纪现象', colPunish: '处罚措施',
    colSuperior: '上级领导', colCCMail: '邮件抄送', colStatus: '关闭状态',
    // STAFF
    staffTitle: '员工管理',
    staffAdd: '新增员工',
    staffEdit: '编辑员工',
    empCode: '工号',
    fullName: '姓名',
    department: '部门',
    position: '职位',
    email: '邮箱',
    phone: '电话',
    manager: '管理员',
    canInspect: '允许巡检',
    active: '启用',
    inactive: '停用',
    refresh: '刷新',
    edit: '编辑',
    delete: '删除',
    noData: '暂无数据',
    totalRecords: '总记录数',
    placeholderEmp: '工号 / 姓名...',
    placeholderName: '请输入姓名',
    placeholderPosition: '例如: Auditor, Manager...',
    placeholderPhone: '请输入电话号码',
    auditAreaPlaceholder: '请选择巡检区域...',


    staffSearchPlaceholder: '工号 / 姓名...',
    staffStatus: '状态',
    staffIsManager: '管理员',
    staffAllowInspect: '允许巡检',
    staffConfirmDelete: '确认删除？',
    staffDeleteYes: '删除',
    staffDeleteNo: '取消',

    staffAdd: '新增员工',
    staffEdit: '编辑员工',

    staffCode: '工号',
    staffFullName: '姓名',
    staffDepartment: '部门',
    staffPosition: '职位',
    staffEmail: '邮箱',
    staffPhone: '电话',

    staffManager: '管理员',
    staffCanInspect: '允许巡检',
    staffActive: '启用',

    staffSelectDepartment: '选择部门',

    staffSave: '保存',
    staffClose: '关闭',

    staffDeleteTitle: '确认删除',
    staffDeleteConfirm: '确定要删除这条记录吗？',
    staffDelete: '删除',
    staffCancel: '取消',

    staffDeleteConfirmMsg: '确定删除员工 {0} 吗？',
    staffDeleteSuccess: '删除成功',
    staffDeleteFail: '删除失败',

    staffSaveSuccess: '保存成功',
    staffSaveFail: '保存失败',

  },
  vi: {
    saveSuccess: 'Lưu thành công',
    deleteSuccess: 'Xóa thành công',
    saveError: 'Lỗi lưu dữ liệu',

    appName: 'Hệ Thống Quản Lý', appSub: 'Nhà Máy', appTitle: 'Hệ Thống Quản Lý Nhà Máy',
    navAudit: 'KIỂM TRA', navAdmin: 'QUẢN TRỊ', menuDayShift: 'Ca Ngày Tuần Tra',
    menuTime: 'Đăng Ký Thời Gian', menuImprove: 'Đăng Ký Cải Thiện', menuViolation: 'Đăng Ký Vi Phạm',
    menuStaff: 'Quản Lý NV', menuSchedule: 'Lịch Trực Ban', logout: 'Đăng xuất',
    inspector: 'Người kiểm tra:', date: 'Ngày:', keyword: 'Từ khóa:', time: 'Thời gian:',
    search: 'Tìm kiếm', addNew: 'Thêm mới', columns: 'Cột', export: 'Xuất Excel', save: 'Lưu', close: 'Đóng',
    colSeq: 'STT', colSysTime: 'Thời Gian Hệ Thống', colStartTime: 'Thời Gian Bắt Đầu', colEndTime: 'Thời Gian Kết Thúc',
    colArea: 'Khu Vực Tuần Tra', colInspector2: 'Người Tuần Tra', colRemark: 'Ghi Chú', colActions: 'Thao Tác',
    colDate: 'Ngày', colIssue: 'Hiện Tượng Cần Cải Thiện', colDept: 'Bộ Phận vi phạm', colDeptResp: 'BP Phụ Trách Khu Vực',
    colChecker: 'Người Kiểm Tra', colEmpId: 'Mã NV vi phạm', colName: 'Họ Tên vi phạm', colVioTime: 'Thời Gian Vi Phạm',
    colLocation: 'Địa Điểm', colVioType: 'Hiện Tượng Vi Phạm', colPunish: 'Biện Pháp Xử Phạt',
    colSuperior: 'Cấp Trên', colCCMail: 'CC Email', colStatus: 'Trạng Thái',

    // STAFF
    staffTitle: 'Quản Lý Nhân Viên',
    staffAdd: 'Thêm Nhân Viên',
    staffEdit: 'Sửa Nhân Viên',
    empCode: 'Mã NV',
    fullName: 'Họ Tên',
    department: 'Bộ Phận',
    position: 'Chức Vụ',
    email: 'Email',
    phone: 'Điện Thoại',
    manager: 'Quản Lý',
    canInspect: 'Được Kiểm Tra',
    active: 'Hoạt Động',
    inactive: 'Dừng',
    refresh: 'Load Lại',
    edit: 'Sửa',
    delete: 'Xóa',
    noData: 'Không có dữ liệu',
    totalRecords: 'Tổng số bản ghi',

    placeholderEmp: 'Mã NV / Họ tên...',
    placeholderName: 'Nhập họ tên',
    placeholderPosition: 'VD: Auditor, Manager...',
    placeholderPhone: '0900000000',
    staffSearchPlaceholder: 'Mã NV / Họ tên...',
    auditAreaPlaceholder: 'Chọn khu vực kiểm tra...',

    staffSave: 'Lưu',
    staffClose: 'Đóng',
    staffDeleteConfirm: 'Bạn có chắc muốn xóa bản ghi này không?',
    staffDeleteTitle: 'Xác Nhận Xóa',
    staffDelete: 'Xóa',
    staffCancel: 'Hủy',
    staffAdd: 'Thêm Nhân Viên',
    staffEdit: 'Sửa Nhân Viên',

    staffCode: 'Mã NV',
    staffFullName: 'Họ Tên',
    staffDepartment: 'Bộ Phận',
    staffPosition: 'Chức Vụ',
    staffEmail: 'Email',
    staffPhone: 'Điện Thoại',

    staffManager: 'Là Quản Lý',
    staffCanInspect: 'Được Phép Kiểm Tra',
    staffActive: 'Đang Hoạt Động',

    staffSelectDepartment: 'Chọn Bộ Phận',

    staffSave: 'Lưu',
    staffClose: 'Đóng',

    staffDeleteTitle: 'Xác Nhận Xóa',
    staffDeleteConfirm: 'Bạn có chắc muốn xóa bản ghi này không?',
    staffDelete: 'Xóa',
    staffCancel: 'Hủy',

    staffDeleteConfirmMsg: 'Xóa nhân viên {0}?',
    staffDeleteSuccess: 'Xóa thành công',
    staffDeleteFail: 'Lỗi xóa',

    staffSaveSuccess: 'Lưu thành công',
    staffSaveFail: 'Lỗi lưu dữ liệu',
  },
  en: {
    saveSuccess: 'Saved successfully',
    deleteSuccess: 'Deleted successfully',
    saveError: 'Save failed',

    appName: 'Factory Management', appSub: 'System', appTitle: 'Factory Management System',
    navAudit: 'AUDIT', navAdmin: 'ADMIN', menuDayShift: 'Day Shift Inspection',
    menuTime: 'Inspection Time', menuImprove: 'Improvement Items', menuViolation: 'Violations',
    menuStaff: 'Staff Management', menuSchedule: 'Duty Schedule', logout: 'Logout',
    inspector: 'Inspector:', date: 'Date:', keyword: 'Keyword:', time: 'Time:',
    search: 'Search', addNew: 'Add New', columns: 'Columns', export: 'Export', save: 'Save', close: 'Close',
    colSeq: 'No.', colSysTime: 'System Time', colStartTime: 'Start Time', colEndTime: 'End Time',
    colArea: 'Inspection Area', colInspector2: 'Inspector', colRemark: 'Remark', colActions: 'Actions',
    colDate: 'Date', colIssue: 'Issue to Improve', colDept: 'Violation Department', colDeptResp: 'Responsible Dept',
    colChecker: 'Checker', colEmpId: 'Violation Employee ID', colName: 'Violation Employee Name', colVioTime: 'Violation Time',
    colLocation: 'Location', colVioType: 'Violation Type', colPunish: 'Punishment',
    colSuperior: 'Superior', colCCMail: 'CC Email', colStatus: 'Status',

    // STAFF
    staffTitle: 'Staff Management',
    staffAdd: 'Add Staff',
    staffEdit: 'Edit Staff',
    empCode: 'Employee ID',
    fullName: 'Full Name',
    department: 'Department',
    position: 'Position',
    email: 'Email',
    phone: 'Phone',
    manager: 'Manager',
    canInspect: 'Can Inspect',
    active: 'Active',
    inactive: 'Inactive',
    refresh: 'Refresh',
    edit: 'Edit',
    delete: 'Delete',
    noData: 'No data',
    totalRecords: 'Total records',
    placeholderEmp: 'Emp ID / Name...',
    placeholderName: 'Enter full name',
    placeholderPosition: 'Ex: Auditor, Manager...',
    placeholderPhone: '0900000000',
    staffSearchPlaceholder: 'Emp ID / Name...',
    auditAreaPlaceholder: 'Select inspection area...',

    staffStatus: 'Status',
    staffIsManager: 'Manager',
    staffAllowInspect: 'Can Inspect',
    staffConfirmDelete: 'Are you sure to delete?',
    staffDeleteYes: 'Delete',
    staffDeleteNo: 'Cancel',
    staffAdd: 'Add Staff',
    staffEdit: 'Edit Staff',

    staffCode: 'Employee ID',
    staffFullName: 'Full Name',
    staffDepartment: 'Department',
    staffPosition: 'Position',
    staffEmail: 'Email',
    staffPhone: 'Phone',

    staffManager: 'Manager',
    staffCanInspect: 'Can Inspect',
    staffActive: 'Active',

    staffSelectDepartment: 'Select Department',

    staffSave: 'Save',
    staffClose: 'Close',

    staffDeleteTitle: 'Confirm Delete',
    staffDeleteConfirm: 'Are you sure you want to delete this record?',
    staffDelete: 'Delete',
    staffCancel: 'Cancel',

    staffDeleteConfirmMsg: 'Delete employee {0}?',
    staffDeleteSuccess: 'Deleted successfully',
    staffDeleteFail: 'Delete failed',

    staffSaveSuccess: 'Saved successfully',
    staffSaveFail: 'Save failed',

  }
};

let currentLang = localStorage.getItem('lang') || 'zh';

function setLang(lang, triggerEl) {
  currentLang = lang;
  localStorage.setItem('lang', lang);
  document.querySelectorAll('.lang-btn').forEach(b => b.classList.remove('active'));
  if (triggerEl) triggerEl.classList.add('active');
  else document.querySelector(`.lang-btn[data-lang="${lang}"]`)?.classList.add('active');
  applyLang();

}

function applyLang() {
  const dict = i18n[currentLang] || i18n['zh'];

  // TEXT
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (dict[key] !== undefined) {
      el.textContent = dict[key];
    }
  });

  // PLACEHOLDER  <<< FIX Ở ĐÂY
  document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
    const key = el.getAttribute('data-i18n-placeholder');
    if (dict[key] !== undefined) {
      el.placeholder = dict[key];
    }
  });
}

// Áp dụng ngôn ngữ đã lưu khi tải trang
document.addEventListener('DOMContentLoaded', () => {
  applyLang();
  document.querySelector(`.lang-btn[data-lang="${currentLang}"]`)?.classList.add('active');
});