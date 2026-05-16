// ── Floating dots decoration ─────────────────────────────
(function() {
  const dots = [
    { w: 220, h: 220, l: '5%',  t: '10%', dur: '8s' },
    { w: 150, h: 150, l: '75%', t: '60%', dur: '11s' },
    { w: 100, h: 100, l: '50%', t: '5%',  dur: '9s' },
    { w:  80, h:  80, l: '88%', t: '20%', dur: '13s' },
    { w:  60, h:  60, l: '20%', t: '75%', dur: '7s' },
  ];
  dots.forEach(d => {
    const el = document.createElement('div');
    el.className = 'float-dot';
    Object.assign(el.style, {
      width: d.w + 'px', height: d.h + 'px',
      left: d.l, top: d.t,
      animationDuration: d.dur,
      animationDelay: Math.random() * -10 + 's'
    });
    document.body.appendChild(el);
  });
})();

// ── Toggle password visibility ───────────────────────────
function toggleEye() {
  const pwd  = document.getElementById('password');
  const icon = document.getElementById('eyeIcon');
  const isText = pwd.type === 'text';
  pwd.type  = isText ? 'password' : 'text';
  icon.className = isText ? 'fas fa-eye' : 'fas fa-eye-slash';
}

// ── Enter key support ────────────────────────────────────
document.addEventListener('keydown', e => {
  if (e.key === 'Enter') doLogin();
});

// ── Login logic ──────────────────────────────────────────
async function doLogin() {
  const API = "http://127.0.0.1:8000";

  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  const remember = document.getElementById('rememberMe').checked;

  document.getElementById('alertError').classList.remove('show');
  document.getElementById('alertSuccess').classList.remove('show');

  if (!username || !password) {
    showError('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.');
    return;
  }

  setLoading(true);

  try {
    const res = await fetch(`${API}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ten_dang_nhap: username,
        mat_khau: password
      })
    });

    const data = await res.json();

    if (res.ok && data.access_token) {

      localStorage.setItem('access_token', data.access_token);
      localStorage.setItem('user', JSON.stringify(data.user || {}));

      document.getElementById('alertSuccess').classList.add('show');
      document.getElementById('loginText').textContent = 'Thành công!';

      setTimeout(() => {
        location.href = 'main3.html';
      }, 900);

    } else {
      showError(data.detail || 'Tên đăng nhập hoặc mật khẩu không đúng.');
    }

  } catch (err) {
    console.error(err);
    showError('Không thể kết nối máy chủ. Vui lòng thử lại.');
  } finally {
    setLoading(false);
  }
}

function showError(msg) {
  document.getElementById('errorMsg').textContent = msg;
  document.getElementById('alertError').classList.add('show');
}

function setLoading(on) {
  const btn    = document.getElementById('loginBtn');
  const spinner= document.getElementById('spinner');
  const icon   = document.getElementById('loginIcon');
  const text   = document.getElementById('loginText');

  btn.disabled      = on;
  spinner.style.display = on ? 'block' : 'none';
  icon.style.display    = on ? 'none'  : '';
  if (!on && text.textContent !== 'Thành công!')
    text.textContent = 'Đăng Nhập';
}