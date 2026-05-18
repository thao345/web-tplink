/**
* mod_caithien.js
* CRUD Cải Thiện
* API: http://127.0.0.1:8000/api/caithien
*/

function formatDate(value) {

    if (!value) return '';

    const d = new Date(value);

    const yyyy = d.getFullYear();

    const mm = String(d.getMonth() + 1).padStart(2, '0');

    const dd = String(d.getDate()).padStart(2, '0');

    return `${yyyy}-${mm}-${dd}`;
}

const CaiThien = (() => {

    const API = "http://127.0.0.1:8000/api/caithien";

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
    // LOAD LIST
    // ─────────────────────────────────────────────
    async function loadList() {

        const keyword = $('#ct-keyword').val().trim();

        const tuNgay = $('#ct-from').val();

        const denNgay = $('#ct-to').val();

        let url = `${API}?`;

        const params = [];

        if (keyword) {
            params.push(
                `keyword=${encodeURIComponent(keyword)}`
            );
        }

        if (tuNgay) {
            params.push(
                `tu_ngay=${encodeURIComponent(tuNgay)}`
            );
        }

        if (denNgay) {
            params.push(
                `den_ngay=${encodeURIComponent(denNgay)}`
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

                throw new Error(
                    data.detail || 'Load failed'
                );
            }

            renderTable(data.items || []);

            renderPagination(data.total || 0);

        } catch (err) {

            console.error(err);

            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // RENDER TABLE
    // ─────────────────────────────────────────────
    function renderTable(rows) {

        const tbody = $('#tbody-improve');

        if (!rows || rows.length === 0) {

            tbody.html(`
                <tr>
                    <td colspan="7" style="text-align:center;padding:20px" data-i18n="noData>
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

                    <td>
                        ${r.ten_nguoi_kiem_tra || ''}
                        <br>
                        <small style="color:#888">
                            ${r.ma_nv_kiem_tra || ''}
                        </small>
                    </td>

                    <td>
                        ${formatDate(r.ngay_kiem_tra)}
                    </td>

                    <td>
                        ${r.ten_bo_phan_phu_trach || ''}
                    </td>

                    <td>
                        ${r.hien_tuong || ''}
                    </td>

                    <td>
                        ${r.ghi_chu || ''}
                    </td>

                    <td>

                        <button
                            onclick="CaiThien.openEdit(${r.id})"
                        >
                            Sửa
                        </button>

                        <button
                            onclick="CaiThien.delete(${r.id})"
                        >
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

        const totalPages = Math.ceil(
            total / state.pageSize
        );

        $('#pag-info-improve').text(
            `Total: ${total}`
        );

        let html = '';

        for (let i = 1; i <= totalPages; i++) {

            html += `
                <button
                    class="pag-btn ${i === state.page ? 'active' : ''}"
                    onclick="CaiThien.goPage(${i})"
                >
                    ${i}
                </button>
            `;
        }

        $('#pag-btns-improve').html(html);
    }

    // ─────────────────────────────────────────────
    // GO PAGE
    // ─────────────────────────────────────────────
    function goPage(page) {

        state.page = page;

        loadList();
    }

    // ─────────────────────────────────────────────
    // REFRESH
    // ─────────────────────────────────────────────
    function refresh() {

        $('#ct-keyword').val('');

        $('#ct-from').val('');

        $('#ct-to').val('');

        state.page = 1;

        loadList();
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

                throw new Error(
                    result.detail || 'Load failed'
                );
            }

            const data = result.data || {};

            // console.log(data);

            // ID hidden
            $('#ct-form-id').val(data.id || '');

            // Người kiểm tra
            $('#ct-inspector').val(
                `${data.ten_nguoi_kiem_tra || ''} (${data.ma_nv_kiem_tra || ''})`
            );

            // Ngày
            $('#ct-date').val(
                formatDate(data.ngay_kiem_tra)
            );

            // Bộ phận
            $('#ct-dept').val(
                data.ten_bo_phan_phu_trach || ''
            );

            // Hiện tượng
            $('#ct-issue').val(
                data.hien_tuong || ''
            );

            // Ghi chú
            $('#ct-remark').val(
                data.ghi_chu || ''
            );

            openModal('modal-improve');

        } catch (err) {

            console.error(err);

            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // SAVE UPDATE
    // ─────────────────────────────────────────────
    // ─────────────────────────────────────────────
    // SAVE UPDATE
    // ─────────────────────────────────────────────
    async function save() {

        const id = $('#ct-form-id').val();

        if (!id) {

            showToast('Không tìm thấy ID', 'error');

            return;
        }

        const body = {

            ngay_kiem_tra:
                $('#ct-date').val(),

            ten_bo_phan_phu_trach:
                $('#ct-dept').val(),

            hien_tuong:
                $('#ct-issue').val(),

            ghi_chu:
                $('#ct-remark').val(),

            nguoi_cap_nhat:
                localStorage.getItem("username") || "admin"
        };

        try {

            const res = await fetch(`${API}/${id}`, {

                method: 'PUT',

                headers: getHeaders(),

                body: JSON.stringify(body)
            });

            const data = await res.json();

            if (!res.ok) {

                throw new Error(
                    data.detail || 'Update failed'
                );
            }

            showToast(
                'Cập nhật thành công',
                'success'
            );

            closeModal('modal-improve');

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

        if (!confirm(`Xóa cải thiện ID ${id}?`)) {
            return;
        }

        try {

            const res = await fetch(`${API}/${id}`, {
                method: 'DELETE',
                headers: getHeaders()
            });

            const data = await res.json();

            if (!res.ok) {

                throw new Error(
                    data.detail || 'Delete failed'
                );
            }

            showToast(
                'Xóa thành công',
                'success'
            );

            loadList();

        } catch (err) {

            console.error(err);

            showToast(err.message, 'error');
        }
    }

    // ─────────────────────────────────────────────
    // RETURN
    // ─────────────────────────────────────────────
    return {
        loadList,
        refresh,
        goPage,
        openEdit,
        save,
        delete: del
    };

})();


// ─────────────────────────────────────────────
// AUTO LOAD
// ─────────────────────────────────────────────
$(document).ready(function () {

    CaiThien.loadList();

});