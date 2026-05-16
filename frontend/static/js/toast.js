/**
 * toast.js — Thông báo nhanh (toast)
 * Dùng: showToast('Lưu thành công', 'success')
 *       showToast('Có lỗi xảy ra', 'error')
 *       showToast('Đang tải...', 'info')
 */

function showToast(msg, type = 'info', duration = 3000) {
  const icons  = { success: 'fa-check-circle', error: 'fa-times-circle', info: 'fa-info-circle' };
  const colors = { success: '#2e7d32',          error: '#c62828',          info: '#1565C0' };

  const el = document.createElement('div');
  el.className = `toast-msg ${type}`;
  el.innerHTML = `<i class="fas ${icons[type]}" style="color:${colors[type]}"></i> ${msg}`;

  const container = document.getElementById('toastContainer');
  container.appendChild(el);
  setTimeout(() => el.remove(), duration);
}