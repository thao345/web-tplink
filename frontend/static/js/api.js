/**
 * api.js — Wrapper AJAX giao tiếp với FastAPI backend
 * Tự động gắn JWT token, xử lý lỗi 401, trả về JSON.
 *
 * Dùng:
 *   const data = await apiGet('/nhan-vien', { page: 1 });
 *   const data = await apiPost('/kiem-tra', { ... });
 *   const data = await apiPut('/vi-pham/5', { ... });
 *   await apiDel('/nhan-vien/NV001');
 */
 
const API_BASE = window.API_BASE_URL || 'http://localhost:8000';

function _getToken() {
  return localStorage.getItem('access_token') || '';
}

function _headers(isJson = true) {
  const h = { Authorization: `Bearer ${_getToken()}` };
  if (isJson) h['Content-Type'] = 'application/json';
  return h;
}

async function _handleResponse(res) {
  if (res.status === 401) {
    localStorage.removeItem('access_token');
    location.href = '/index.html';
    throw new Error('Phiên đăng nhập hết hạn');
  }
  const json = await res.json().catch(() => ({}));
  if (!res.ok) {
    throw new Error(json.detail || `HTTP ${res.status}`);
  }
  return json;
}

function _buildQuery(params = {}) {
  const q = Object.entries(params)
    .filter(([, v]) => v !== null && v !== undefined && v !== '')
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');
  return q ? `?${q}` : '';
}

async function apiGet(path, params = {}) {
  const url = `${API_BASE}${path}${_buildQuery(params)}`;
  const res = await fetch(url, { method: 'GET', headers: _headers() });
  return _handleResponse(res);
}

async function apiPost(path, body = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: 'POST',
    headers: _headers(),
    body: JSON.stringify(body),
  });
  return _handleResponse(res);
}

async function apiPut(path, body = {}) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: 'PUT',
    headers: _headers(),
    body: JSON.stringify(body),
  });
  return _handleResponse(res);
}

async function apiDel(path) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: 'DELETE',
    headers: _headers(),
  });
  return _handleResponse(res);
}

async function apiUpload(path, formData) {
  const res = await fetch(`${API_BASE}${path}`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${_getToken()}` }, // không set Content-Type để browser tự set boundary
    body: formData,
  });
  return _handleResponse(res);
}