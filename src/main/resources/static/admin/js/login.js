(function () {
	const form = document.getElementById('login-form');
	const alertEl = document.getElementById('alert');
	const btn = document.getElementById('btn-submit');

	function showError(msg) {
		alertEl.textContent = msg;
		alertEl.classList.add('show');
	}
	function hideError() {
		alertEl.classList.remove('show');
		alertEl.textContent = '';
	}

	form.addEventListener('submit', async function (e) {
		e.preventDefault();
		hideError();
		const email = document.getElementById('email').value.trim();
		const password = document.getElementById('password').value;
		if (!email || !password) {
			showError('Vui lòng nhập email và mật khẩu.');
			return;
		}
		btn.disabled = true;
		try {
			const loginRes = await fetch('/api/auth/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ email, password }),
			});
			const loginBody = await loginRes.json().catch(function () { return {}; });
			if (!loginRes.ok) {
				showError(loginBody.message || 'Đăng nhập thất bại.');
				return;
			}
			const accessToken = loginBody.accessToken;
			if (!accessToken) {
				showError('Phản hồi không hợp lệ.');
				return;
			}
			const meRes = await fetch('/api/users/me', {
				headers: { Authorization: 'Bearer ' + accessToken },
			});
			const me = await meRes.json().catch(function () { return {}; });
			if (!meRes.ok) {
				showError(me.message || 'Không lấy được thông tin tài khoản.');
				return;
			}
			if (me.role !== 'ADMIN') {
				showError('Tài khoản này không có quyền quản trị viên.');
				return;
			}
			localStorage.setItem('admin_access_token', accessToken);
			if (loginBody.refreshToken) {
				localStorage.setItem('admin_refresh_token', loginBody.refreshToken);
			}
			window.location.href = '/admin/dashboard';
		} catch (err) {
			showError('Lỗi kết nối. Kiểm tra server và thử lại.');
		} finally {
			btn.disabled = false;
		}
	});
})();
