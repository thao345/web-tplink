/**
 * mod_kiem_tra.js — Module 巡检时间登记
 * Phụ thuộc: api.js, toast.js, table.js, modal.js
 */

const KiemTra = (() => {
  let state = { page: 1, pageSize: 25, total: 0, sort_col: 'thoi_gian_bat_dau', sort_dir: 'DESC' };

  /* ── Load danh sách ──────────────────────────────── */
  async function loadList() {
    const keyword = document.getElementById('kt-search-inspector')?.value || '';
    try {
      const res = await apiGet('/kiem-tra', {
        keyword, page: state.page, page_size: state.pageSize,
        sort_col: state.sort_col, sort_dir: state.sort_dir,
      });
      state.total = res.total;
      renderTable(res.data);
      renderPagination('pag-info-time', 'pag-btns-time', {
        page: state.page, pageSize: state.pageSize, total: state.total,
        onPageChange: p => { state.page = p; loadList(); },
      });
    } catch (err) {
      showToast('Lỗi tải dữ liệu kiểm tra', 'error');
    }
  }

  /* ── Render tbody ────────────────────────────────── */
  function renderTable(rows) {
    const tbody = document.getElementById('tbody-time');
    if (!rows || rows.length === 0) {
      tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;padding:20px;color:var(--text-muted)">Không có dữ liệu</td></tr>';
      return;
    }
    tbody.innerHTML = rows.map(r => `
      <tr onclick="selectRow(this)" data-id="${r.id}">
        <td>${r.id}</td>
        <td>${r.thoi_gian_he_thong || ''}</td>
        <td>${r.thoi_gian_bat_dau || ''}</td>
        <td>${r.thoi_gian_ket_thuc || ''}</td>
        <td>${r.khu_vuc || ''}</td>
        <td>${r.ho_ten || r.ma_nv_kiem_tra || ''}</td>
        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis" title="${r.ghi_chu || ''}">${r.ghi_chu || ''}</td>
        <td><span style="display:flex;gap:3px">
          <button class="action-btn action-edit" title="Sửa" onclick="KiemTra.openEdit(event,${r.id})"><i class="fas fa-edit"></i></button>
          <button class="action-btn action-del"  title="Xóa" onclick="KiemTra.del(event,${r.id})"><i class="fas fa-trash"></i></button>
        </span></td>
      </tr>`).join('');
  }

  /* ── Mở modal thêm mới ───────────────────────────── */
  function openAdd() {
    document.getElementById('kt-form-id').value = '';
    document.getElementById('audit-start').value = new Date().toISOString().slice(0, 16);
    document.getElementById('audit-end').value   = new Date().toISOString().slice(0, 16);
    document.getElementById('audit-remark').value = '';
    // Reset improve & violation fields
    document.getElementById('improve-issue').value   = '';
    document.getElementById('improve-remark').value  = '';
    document.getElementById('vio-location').value    = '';
    document.getElementById('vio-phenomenon').value  = '';
    openModal('modal-audit');
  }

  /* ── Mở modal sửa ────────────────────────────────── */
  async function openEdit(e, id) {
    e.stopPropagation();
    try {
      const res = await apiGet(`/kiem-tra/${id}`);
      const r = res.data;
      document.getElementById('kt-form-id').value     = r.id;
      document.getElementById('audit-start').value    = r.thoi_gian_bat_dau?.slice(0, 16) || '';
      document.getElementById('audit-end').value      = r.thoi_gian_ket_thuc?.slice(0, 16) || '';
      document.getElementById('audit-remark').value   = r.ghi_chu || '';
      // Chọn khu vực (multi-select)
      const areas = (r.khu_vuc || '').split(',').map(s => s.trim());
      Array.from(document.getElementById('audit-area').options).forEach(opt => {
        opt.selected = areas.includes(opt.value);
      });
      openModal('modal-audit');
    } catch {
      showToast('Không tải được dữ liệu', 'error');
    }
  }

  /* ── Lưu (thêm + sửa) ───────────────────────────── */
  async function save() {
    const id    = document.getElementById('kt-form-id').value;
    const start = document.getElementById('audit-start').value;
    const end   = document.getElementById('audit-end').value;
    if (!start || !end) { showToast('Vui lòng nhập thời gian bắt đầu và kết thúc', 'error'); return; }

    const areaSelect = document.getElementById('audit-area');
    const khu_vuc = Array.from(areaSelect.selectedOptions).map(o => o.value).join(', ');

    const payload = {
      thoi_gian_bat_dau:  start,
      thoi_gian_ket_thuc: end,
      khu_vuc,
      ghi_chu: document.getElementById('audit-remark').value,
      // Cải thiện đi kèm
      cai_thien: {
        ten_bo_phan_phu_trach: document.getElementById('improve-dept')?.value || '',
        hien_tuong:            document.getElementById('improve-issue')?.value || '',
        ghi_chu:               document.getElementById('improve-remark')?.value || '',
      },
      // Vi phạm đi kèm
      vi_pham: {
        ten_bo_phan:       document.getElementById('vio-dept')?.value || '',
        ma_nv:             document.getElementById('vio-empid')?.value || '',
        ho_ten:            document.getElementById('vio-name')?.value || '',
        thoi_gian_vi_pham: document.getElementById('vio-time')?.value || '',
        dia_diem:          document.getElementById('vio-location')?.value || '',
        ten_cap_tren:      document.getElementById('vio-superior')?.value || '',
        email_cc:          document.getElementById('vio-cc')?.value || '',
        hien_tuong_vi_pham:document.getElementById('vio-phenomenon')?.value || '',
      },
    };

    try {
      if (id) {
        await apiPut(`/kiem-tra/${id}`, payload);
        showToast('Cập nhật thành công', 'success');
      } else {
        await apiPost('/kiem-tra', payload);
        showToast('Thêm mới thành công', 'success');
      }
      closeModal('modal-audit');
      loadList();
    } catch (err) {
      showToast(err.message || 'Lưu thất bại', 'error');
    }
  }

  /* ── Xóa ─────────────────────────────────────────── */
  async function del(e, id) {
    e.stopPropagation();
    if (!confirm('Xác nhận xóa bản ghi này?')) return;
    try {
      await apiDel(`/kiem-tra/${id}`);
      showToast('Đã xóa bản ghi', 'success');
      loadList();
    } catch {
      showToast('Xóa thất bại', 'error');
    }
  }

  /* ── Sort ────────────────────────────────────────── */
  function sort(col) {
    if (state.sort_col === col) {
      state.sort_dir = state.sort_dir === 'ASC' ? 'DESC' : 'ASC';
    } else {
      state.sort_col = col; state.sort_dir = 'ASC';
    }
    state.page = 1;
    loadList();
  }

  return { loadList, openAdd, openEdit, save, del, sort };
})();

// Khởi động khi module được active
document.addEventListener('DOMContentLoaded', () => KiemTra.loadList());