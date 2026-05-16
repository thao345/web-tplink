/**
 * mod_nhan_vien.js
 * CRUD Nhân Viên
 * API: http://127.0.0.1:8000/api/nhanvien/
 */
function getUsername() {
  return localStorage.getItem("username") || "admin";
}

const NhanVien = (() => {

  const API = "http://127.0.0.1:8000/api/nhanvien";

  let state = {
    page: 1,
    pageSize: 25,
    total: 0
  };

  // ─────────────────────────────────────────────
  // TOKEN
  // ─────────────────────────────────────────────
  function getToken() {
    return localStorage.getItem("access_token") || "";
  }

  function getHeaders() {
    return {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${getToken()}`
    };
  }
  // ─────────────────────────────────────────────
  // search theo keyword
  // ─────────────────────────────────────────────
  function search() {

    state.keyword = $('#nv-keyword').val().trim();

    state.page = 1;

    loadList();
  }
  function refresh() {

    // xóa ô tìm kiếm
    $('#nv-keyword').val('');

    // reset state
    state.keyword = '';

    // về page 1
    state.page = 1;

    // load lại toàn bộ data
    loadList();
  }

  // ─────────────────────────────────────────────
  // LOAD LIST
  // ─────────────────────────────────────────────
  async function loadList() {

    // luôn đọc input hiện tại
    state.keyword = $('#nv-keyword').val().trim();

    let url = `${API}/?`;

    const params = [];

    // keyword
    if (state.keyword) {
      params.push(
        `keyword=${encodeURIComponent(state.keyword)}`
      );
    }

    // page
    if (state.page) {
      params.push(`page=${state.page}`);
    }

    // page_size
    if (state.pageSize) {
      params.push(`page_size=${state.pageSize}`);
    }

    url += params.join('&');

    try {

      const res = await fetch(url, {
        method: 'GET',
        headers: getHeaders()
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.detail || 'Lỗi tải dữ liệu');
      }

      renderTable(data.data || []);
      renderPagination(data.data[0].total_count || 0);

    } catch (err) {

      console.error(err);
      // alert(err.message);
      showToast(err.message, 'error');
    }
  }


  // ─────────────────────────────────────────────
  // RENDER TABLE
  // ─────────────────────────────────────────────
  function renderTable(rows) {

    const tbody = $('#tbody-staff');

    if (!rows || rows.length === 0) {

      tbody.html(`
        <tr>
          <td colspan="11" style="text-align:center;padding:20px" data-i18n="noData>
            Không có dữ liệu
          </td>
        </tr>
      `);
      applyLang(); // <- quan trọng
      return;
    }

    let html = '';

    rows.forEach((r, index) => {

      html += `
        <tr>

          <td>${((state.page - 1) * state.pageSize) + index + 1}</td>

          <td>${r.ma_nv || ''}</td>

          <td>${r.ho_ten || ''}</td>

          <td>${r.bo_phan || ''}</td>

          <td>${r.chuc_vu || ''}</td>

          <td>${r.email || ''}</td>

          <td>${r.dien_thoai || ''}</td>

          <td style="text-align:center">
            ${r.la_quan_ly ? '✔' : ''}
          </td>

          <td style="text-align:center">
            ${r.la_kiem_tra ? '✔' : ''}
          </td>

          <td style="text-align:center">
            
             ${r.trang_thai ? i18n[currentLang].active : i18n[currentLang].inactive}
          </td>

          <td>
            <button onclick="NhanVien.openEdit('${r.ma_nv}')" data-i18n="edit">
              Sửa
            </button>

            <button onclick="NhanVien.delete('${r.ma_nv}')" data-i18n="delete">
              Xóa
            </button>
          </td>

        </tr>
      `;
    });

    tbody.html(html);
    applyLang(); // <- bắt buộc để re-translate sau khi render
  }

  // ─────────────────────────────────────────────
  // PAGINATION
  // ─────────────────────────────────────────────
  function renderPagination(total) {

    state.total = total;

    const totalPages = Math.ceil(total / state.pageSize);

    const text = i18n[currentLang].totalRecords || 'Total records';
    $('#pag-info-staff').text(`${text}: ${total}`);

    let html = '';

    for (let i = 1; i <= totalPages; i++) {

      html += `
        <button
          class="pag-btn ${i === state.page ? 'active' : ''}"
          onclick="NhanVien.goPage(${i})"
        >
          ${i}
        </button>
      `;
    }

    $('#pag-btns-staff').html(html);
  }

  // ─────────────────────────────────────────────
  // CHUYỂN TRANG
  // ─────────────────────────────────────────────
  function goPage(page) {
    state.page = page;
    loadList();
  }

  // ─────────────────────────────────────────────
  // OPEN ADD
  // ─────────────────────────────────────────────
  function openAdd() {

    $('#nv-form-mode').val('add');

    $('#nv-ma_nv').val('');
    $('#nv-ho_ten').val('');
    $('#nv-bo_phan').val('');
    $('#nv-chuc_vu').val('');
    $('#nv-email').val('');
    $('#nv-dien_thoai').val('');

    $('#nv-la_quan_ly').prop('checked', false);
    $('#nv-la_kiem_tra').prop('checked', false);

    openModal('modal-staff');
  }

  // ─────────────────────────────────────────────
  // OPEN EDIT
  // ─────────────────────────────────────────────
  async function openEdit(ma_nv) {

    try {

      const res = await fetch(`${API}/${ma_nv}`, {
        method: 'GET',
        headers: getHeaders()
      });

      const result = await res.json();

      if (!res.ok) {
        throw new Error(result.detail || 'Lỗi tải dữ liệu');
      }

      // lấy object nhân viên
      const data = result.data || result;

      $('#nv-form-mode').val('edit');

      $('#nv-ma_nv').val(data.ma_nv || '');
      $('#nv-ho_ten').val(data.ho_ten || '');
      $('#nv-bo_phan').val(data.bo_phan || '');
      $('#nv-chuc_vu').val(data.chuc_vu || '');
      $('#nv-email').val(data.email || '');
      $('#nv-dien_thoai').val(data.dien_thoai || '');

      $('#nv-la_quan_ly').prop('checked', !!data.la_quan_ly);
      $('#nv-la_kiem_tra').prop('checked', !!data.la_kiem_tra);

      openModal('modal-staff');
      // console.log(result); // lấy data theo id bấm nút edit

    } catch (err) {
      console.error(err);
      // alert(err.message);
      showToast(err.message, 'error');
    }
  }

  // ─────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────

  async function save() {

    const mode = $('#nv-form-mode').val();

    const body = {

      ma_nv: $('#nv-ma_nv').val().trim(),

      ho_ten: $('#nv-ho_ten').val().trim(),

      bo_phan: $('#nv-bo_phan').val(),

      chuc_vu: $('#nv-chuc_vu').val().trim(),

      email: $('#nv-email').val().trim(),

      dien_thoai: $('#nv-dien_thoai').val().trim(),

      la_quan_ly:
        $('#nv-la_quan_ly').is(':checked') ? 1 : 0,

      la_kiem_tra:
        $('#nv-la_kiem_tra').is(':checked') ? 1 : 0,

      nguoi_tao: getUsername()
    };

    try {

      const res = await fetch(API, {
        method: 'POST',
        headers: getHeaders(),
        body: JSON.stringify(body)
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.detail || dict.staffSaveFail);
      }

      closeModal('modal-staff');

      showToast(i18n[currentLang].staffSaveSuccess, 'success');
      // alert(dict.staffSaveSuccess);

      console.log(getUsername());

      loadList();

    } catch (err) {

      console.error(err);
      showToast(err.message, 'error');
      // alert(err.message);
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────
  async function del(ma_nv) {
    const username = getUsername();
    const dict = i18n[currentLang];

    const msg = (dict.staffDeleteConfirmMsg || 'Delete {0}?')
      .replace('{0}', ma_nv);

    if (!confirm(msg)) {
      return;
    }

    try {
      const res = await fetch(
        `${API}/${ma_nv}?nguoi_xoa=${encodeURIComponent(username)}`,
        {
          method: 'DELETE',
          headers: getHeaders()
        }
      );

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.detail || dict.staffDeleteFail);
      }
      
      showToast(i18n[currentLang].staffDeleteSuccess, 'success');
      // alert(dict.staffDeleteSuccess);

      loadList();

    } catch (err) {
      console.error(err);
      // alert(err.message || dict.staffDeleteFail);
      showToast(staffDeleteFail, 'error');
    }
  }

  // ─────────────────────────────────────────────
  // RETURN
  // ─────────────────────────────────────────────
  return {
    loadList,
    refresh,
    search,
    goPage,
    openAdd,
    openEdit,
    save,
    delete: del
  };
})();


// ─────────────────────────────────────────────
// AUTO LOAD
// ─────────────────────────────────────────────
$(document).ready(function () {
  NhanVien.loadList();
});