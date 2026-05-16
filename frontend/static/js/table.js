/**
 * table.js — Tiện ích bảng dùng lại
 * - toggleColMenu: ẩn/hiện dropdown chọn cột
 * - toggleCol:     ẩn/hiện cột
 * - sortTable:     sắp xếp (stub, thực tế gọi API)
 * - selectRow:     highlight hàng được chọn
 * - renderPagination: render thanh phân trang
 */

/* ── Column toggle dropdown ─────────────────────────── */
function toggleColMenu(menuId) {
  document.querySelectorAll('.col-toggle-dropdown').forEach(d => {
    if (d.id !== menuId) d.classList.remove('open');
  });
  document.getElementById(menuId)?.classList.toggle('open');
}

// Đóng khi click ngoài
document.addEventListener('click', e => {
  if (
    !e.target.closest('[onclick*="toggleColMenu"]') &&
    !e.target.closest('.col-toggle-dropdown')
  ) {
    document.querySelectorAll('.col-toggle-dropdown').forEach(d => d.classList.remove('open'));
  }
});

/* ── Hide/show column by index (1-based) ────────────── */
function toggleCol(tableId, colIndex) {
  const table = document.getElementById(`table-${tableId}`);
  if (!table) return;
  table.querySelectorAll(`tr td:nth-child(${colIndex}), tr th:nth-child(${colIndex})`).forEach(cell => {
    cell.style.display = cell.style.display === 'none' ? '' : 'none';
  });
}

/* ── Sort (stub — override per module) ──────────────── */
function sortTable(tableId, col) {
  showToast(`Sắp xếp theo ${col}`, 'info');
  // Thực tế: gọi loadData(tableId, { sort_col: col, sort_dir: ... })
}

/* ── Row selection ──────────────────────────────────── */
function selectRow(tr) {
  const table = tr.closest('table');
  table.querySelectorAll('tbody tr').forEach(r => r.classList.remove('selected'));
  tr.classList.add('selected');
}

/* ── Render pagination bar ──────────────────────────── */
/**
 * @param {string} infoId   - id của span hiển thị "Hiển thị x-y / total"
 * @param {string} btnsId   - id của div chứa các nút trang
 * @param {object} state    - { page, pageSize, total, onPageChange }
 */
function renderPagination(infoId, btnsId, { page, pageSize, total, onPageChange }) {
  const totalPages = Math.max(1, Math.ceil(total / pageSize));
  const from = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const to   = Math.min(page * pageSize, total);

  const infoEl = document.getElementById(infoId);
  if (infoEl) infoEl.textContent = `显示第 ${from} 至 ${to} 记录，一共 ${total} 条`;

  const btnsEl = document.getElementById(btnsId);
  if (!btnsEl) return;

  const btn = (label, p, disabled = false, active = false) =>
    `<button class="pag-btn${active ? ' active' : ''}" ${disabled ? 'disabled' : ''}
      onclick="(${onPageChange.toString()})(${p})">${label}</button>`;

  const pages = [];
  for (let i = Math.max(1, page - 2); i <= Math.min(totalPages, page + 2); i++) {
    pages.push(btn(i, i, false, i === page));
  }

  btnsEl.innerHTML =
    btn('<i class="fas fa-angle-double-left"></i>', 1, page === 1) +
    btn('<i class="fas fa-angle-left"></i>', page - 1, page === 1) +
    pages.join('') +
    `<span style="padding:0 4px;font-size:12px;color:var(--text-muted)">/ ${totalPages}</span>` +
    btn('<i class="fas fa-angle-right"></i>', page + 1, page === totalPages) +
    btn('<i class="fas fa-angle-double-right"></i>', totalPages, page === totalPages) +
    `<button class="pag-btn" title="刷新" onclick="location.reload()"><i class="fas fa-sync-alt"></i></button>`;
}