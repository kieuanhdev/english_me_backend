(function (global) {
	function getAdminToken() {
		return localStorage.getItem('admin_access_token');
	}

	function redirectIfNoToken() {
		if (!getAdminToken()) {
			window.location.href = '/admin/login';
			return true;
		}
		return false;
	}

	function authHeadersJson() {
		return {
			'Content-Type': 'application/json',
			Authorization: 'Bearer ' + getAdminToken(),
		};
	}

	function authHeaders() {
		return { Authorization: 'Bearer ' + getAdminToken() };
	}

	/**
	 * @param {string} url
	 * @param {RequestInit} [options]
	 */
	async function apiJson(url, options) {
		const opts = options || {};
		const headers = Object.assign({}, opts.headers || {});
		headers.Authorization = 'Bearer ' + getAdminToken();
		if (opts.body != null && !headers['Content-Type']) {
			headers['Content-Type'] = 'application/json';
		}
		const res = await fetch(url, Object.assign({}, opts, { headers }));
		if (res.status === 401) {
			localStorage.removeItem('admin_access_token');
			localStorage.removeItem('admin_refresh_token');
			window.location.href = '/admin/login';
			throw new Error('Unauthorized');
		}
		return res;
	}

	global.AdminCommon = {
		getAdminToken,
		redirectIfNoToken,
		authHeadersJson,
		authHeaders,
		apiJson,
	};
})(window);
