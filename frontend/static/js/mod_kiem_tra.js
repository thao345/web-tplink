/**
 * mod_kiem_tra.js
 * CRUD Kiểm Tra Thời Gian
 * API: http://127.0.0.1:8000/api/kiemtrathoigian
 */
 
function getUsername() {
    return localStorage.getItem("username") || "admin";
}

function formatDateTime(value) {

    if (!value) return '';

    const d = new Date(value);

    const yyyy = d.getFullYear();

    const mm = String(d.getMonth() + 1).padStart(2, '0');

    const dd = String(d.getDate()).padStart(2, '0');

    const hh = String(d.getHours()).padStart(2, '0');

    const mi = String(d.getMinutes()).padStart(2, '0');

    return `${yyyy}-${mm}-${dd} ${hh}:${mi}`;
}

const KiemTra = (() => {

    const API = "http://127.0.0.1:8000/api/kiemtrathoigian";

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
    // SEARCH
    // ─────────────────────────────────────────────
    function search() {

        state.keyword = $('#kt-search-inspector').val().trim();

        state.page = 1;

        loadList();
    }

    // ─────────────────────────────────────────────
    // REFRESH
    // ─────────────────────────────────────────────
    function refresh() {

        $('#kt-search-inspector').val('');

        state.keyword = '';

        state.page = 1;

        loadList();
    }

    // ─────────────────────────────────────────────
    // LOAD LIST
    // ─────────────────────────────────────────────
    async function loadList() {

        state.keyword = $('#kt-search-inspector').val().trim();

        let url = `${API}?`;

        const params = [];

        if (state.keyword) {
            params.push(
                `keyword=${encodeURIComponent(state.keyword)}`
            );
        }

        params.push(`page=${state.page}`);
        params.push(`page_size=${state.pageSize}`);

        url += params.join('&');

        try {

            const res = await fetch(url, {
                method: 'GET',
                headers: getHeaders()
            });

            const data = await res.json();

            if (!res.ok) {
                throw new Error(data.detail || 'Load failed');
            }

            renderTable(data.data || []);
            renderPagination(data.data[0]?.total_count || 0);

        } catch (err) {

            console.error(err);
            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // RENDER TABLE
    // ─────────────────────────────────────────────
    function renderTable(rows) {

        const tbody = $('#tbody-time');

        if (!rows || rows.length === 0) {

            tbody.html(`
        <tr>
          <td colspan="11" style="text-align:center;padding:20px" data-i18n="noData>
            Không có dữ liệu
          </td>
        </tr>
      `);
            applyLang();
            return;
        }

        let html = '';

        rows.forEach((r, index) => {

            html += `
        <tr>

          <td>
            ${((state.page - 1) * state.pageSize) + index + 1}
          </td>

        <td>${formatDateTime(r.thoi_gian_he_thong)}</td>

        <td>${formatDateTime(r.thoi_gian_bat_dau)}</td>

        <td>${formatDateTime(r.thoi_gian_ket_thuc)}</td>

          <td>${r.khu_vuc || ''}</td>

           <td>
            ${r.ten_nguoi_kiem_tra || ''}
            <br>
            <small style="color:#888">${r.ma_nv_kiem_tra || ''}</small>
          </td>

          <td>${r.ghi_chu || ''}</td>

          <td>

            <button onclick="KiemTra.openEdit(${r.id})" data-i18n="edit">
              Sửa
            </button>

            <button onclick="KiemTra.delete(${r.id})" data-i18n="delete">
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

        $('#pag-info-time').text(`${text}: ${total}`);

        let html = '';

        for (let i = 1; i <= totalPages; i++) {

            html += `
        <button
          class="pag-btn ${i === state.page ? 'active' : ''}"
          onclick="KiemTra.goPage(${i})"
        >
          ${i}
        </button>
      `;
        }

        $('#pag-btns-time').html(html);
    }

    // ─────────────────────────────────────────────
    // GO PAGE
    // ─────────────────────────────────────────────
    function goPage(page) {

        state.page = page;

        loadList();
    }

    // ─────────────────────────────────────────────
    // OPEN ADD (mở modal)
    // ─────────────────────────────────────────────
    function openAdd() {

        $('#kt-form-id').val('');

        const maNV = localStorage.getItem('ma_nv');
        const hoTen = localStorage.getItem('ho_ten');
        // console.log(hoTen);
        // console.log(maNV);
        // thông tin nhân viên lấy từ tài khoản đăng nhập
        $('#MaNguoikiemtra-inspector').val(
            maNV || ''
        );
        $('#Tenkiemtra-inspector').val(
            hoTen || ''
        );

        $('#audit-start').val('');
        $('#audit-end').val('');
        $('#audit-area-text').val('');
        $('#audit-remark').val('');

        // disable phần cải thiện + vi phạm
        $('.left-panel :input').prop('disabled', true);
        $('.right-panel :input').prop('disabled', true);

        // thêm hiệu ứng disabled
        $('.left-panel').addClass('disabled-panel');
        $('.right-panel').addClass('disabled-panel');

        openModal('modal-audit');
    }
    // ─────────────────────────────────────────────
    // OPEN EDIT
    // ─────────────────────────────────────────────
    async function openEdit(id) {

        try {

            const res = await fetch(`${API}/${id}`, {
                method: 'GET',
                headers: getHeaders()
            });

            const result = await res.json();

            if (!res.ok) {
                throw new Error(result.detail || 'Load failed');
            }
            //  console.log(result);

            // lấy object  của kiemtra
            const data = result.master || {};
            const maNV = localStorage.getItem('ma_nv');
            const hoTen = localStorage.getItem('ho_ten');
            // console.log(hoTen);
            // console.log(maNV);
            // thông tin nhân viên lấy từ tài khoản đăng nhập
            $('#MaNguoikiemtra-inspector').val(
                maNV || ''
            );
            $('#Tenkiemtra-inspector').val(
                hoTen || ''
            );
            $('#kt-form-id').val(data.id || '');

            $('#audit-start').val(formatDateTimeLocal(data.thoi_gian_bat_dau));
            $('#audit-end').val(formatDateTimeLocal(data.thoi_gian_ket_thuc));

            $('#audit-area-text').val(data.khu_vuc || '');

            $('#audit-remark').val(data.ghi_chu_kiemtra || '');

            // enable
            $('.left-panel :input').prop('disabled', false);
            $('.left-panel textarea').prop('disabled', false);
            $('.left-panel select').prop('disabled', false);

            $('.right-panel :input').prop('disabled', false);
            $('.right-panel textarea').prop('disabled', false);

            // cho phép nhập cải thiện và vi phạm   
            $('.left-panel').removeClass('disabled-panel');
            $('.right-panel').removeClass('disabled-panel');

            openModal('modal-audit');

        } catch (err) {

            console.error(err);
            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // SAVE
    // ─────────────────────────────────────────────
    async function save() {

        const id = $('#kt-form-id').val();

        const body = {

            thoi_gian_bat_dau:
                $('#audit-start').val().replace('T', ' ') + ':00',

            thoi_gian_ket_thuc:
                $('#audit-end').val().replace('T', ' ') + ':00',

            khu_vuc:
                $('#audit-area-text').val(),

            ghi_chu:
                $('#audit-remark').val(),

            ma_nv_kiem_tra:
                localStorage.getItem('ma_nv'),

            nguoi_tao:
                getUsername(),

            nguoi_cap_nhat:
                getUsername()
        };

        try {

            let res;

            // INSERT
            if (!id) {

                res = await fetch(API, {
                    method: 'POST',
                    headers: getHeaders(),
                    body: JSON.stringify(body)
                });

            } else {

                // UPDATE
                res = await fetch(`${API}/${id}`, {
                    method: 'PUT',
                    headers: getHeaders(),
                    body: JSON.stringify(body)
                });
            }

            const data = await res.json();

            if (!res.ok) {
                throw new Error(data.detail || 'Save failed');
            }

            showToast(i18n[currentLang].staffSaveSuccess, 'success');

            closeModal('modal-audit');

            loadList();

        } catch (err) {

            console.error(err);

            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────
    async function del(id) {

        const dict = i18n[currentLang];

        if (!confirm(`Delete ID ${id}?`)) {
            return;
        }


        try {

            const res = await fetch(
                `${API}/${id}?nguoi_xoa=${encodeURIComponent(getUsername())}`,
                {
                    method: 'DELETE',
                    headers: getHeaders()
                }
            );

            const data = await res.json();

            if (!res.ok) {
                throw new Error(data.detail || 'Delete failed');
            }

            showToast(dict.staffDeleteSuccess, 'success');

            loadList();

        } catch (err) {

            console.error(err);

            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // FORMAT DATETIME
    // ─────────────────────────────────────────────
    function formatDateTimeLocal(value) {

        if (!value) return '';

        return value.substring(0, 16);
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

    KiemTra.loadList();

});