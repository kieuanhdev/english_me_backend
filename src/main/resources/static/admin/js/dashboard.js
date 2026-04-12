(function () {
	var token = localStorage.getItem('admin_access_token');
	if (!token) {
		window.location.href = '/admin/login';
		return;
	}
	var userLine = document.getElementById('user-line');

	fetch('/api/auth/me', { headers: { Authorization: 'Bearer ' + token } })
		.then(function (r) {
			if (r.status === 401) {
				localStorage.removeItem('admin_access_token');
				localStorage.removeItem('admin_refresh_token');
				window.location.href = '/admin/login';
				return null;
			}
			return r.json();
		})
		.then(function (me) {
			if (!me || !me.email) return;
			if (me.role !== 'ADMIN') {
				localStorage.removeItem('admin_access_token');
				localStorage.removeItem('admin_refresh_token');
				window.location.href = '/admin/login';
				return;
			}
			userLine.textContent = me.email + (me.fullName ? ' · ' + me.fullName : '');
		})
		.catch(function () {
			userLine.textContent = 'Không tải được thông tin.';
		});

	document.getElementById('btn-logout').addEventListener('click', function () {
		var rt = localStorage.getItem('admin_refresh_token');
		localStorage.removeItem('admin_access_token');
		localStorage.removeItem('admin_refresh_token');
		if (rt) {
			fetch('/api/auth/logout', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ refreshToken: rt }),
			}).finally(function () {
				window.location.href = '/admin/login';
			});
		} else {
			window.location.href = '/admin/login';
		}
	});
})();
