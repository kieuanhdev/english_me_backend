(function () {
	if (AdminCommon.redirectIfNoToken()) return;

	var page = 0;
	var size = 20;
	var totalPages = 0;
	var cacheRows = [];

	var flash = document.getElementById('flash');
	function showFlash(msg, ok) {
		flash.textContent = msg;
		flash.className = 'flash show ' + (ok ? 'flash-ok' : 'flash-err');
	}

	function esc(s) {
		if (s == null) return '';
		return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');
	}

	function currentFilters() {
		var p = new URLSearchParams();
		p.set('page', String(page));
		p.set('size', String(size));
		p.set('sort', 'updatedAt,desc');
		var cefr = document.getElementById('filter-cefr').value;
		var skill = document.getElementById('filter-skill').value;
		var deleted = document.getElementById('filter-deleted').checked;
		if (cefr) p.set('cefr', cefr);
		if (skill) p.set('skill', skill);
		p.set('includeDeleted', String(deleted));
		return '/api/admin/questions?' + p.toString();
	}

	function renderTable(data) {
		cacheRows = data.content || [];
		var tb = document.getElementById('tbl-questions');
		tb.innerHTML = '';
		cacheRows.forEach(function (q) {
			var short = q.content.length > 90 ? q.content.slice(0, 90) + '…' : q.content;
			var tr = document.createElement('tr');
			tr.innerHTML =
				'<td>' +
				esc(short) +
				'</td><td>' +
				esc(q.cefrBand) +
				'</td><td>' +
				esc(q.skillType) +
				'</td><td>' +
				q.difficultyScore +
				'</td><td>' +
				(q.deletedAt ? '<span class="badge badge-del">deleted</span>' : q.isActive ? '<span class="badge badge-ok">active</span>' : '<span class="badge badge-del">inactive</span>') +
				'</td><td class="btn-row">' +
				'<button type="button" class="btn-secondary btn-sm btn-edit" data-id="' +
				q.id +
				'">Sửa</button>' +
				'<button type="button" class="btn-danger btn-sm btn-delete" data-id="' +
				q.id +
				'">Xóa</button>' +
				'</td>';
			tb.appendChild(tr);
		});

		tb.querySelectorAll('.btn-edit').forEach(function (btn) {
			btn.addEventListener('click', function () {
				fillForm(btn.getAttribute('data-id'));
			});
		});
		tb.querySelectorAll('.btn-delete').forEach(function (btn) {
			btn.addEventListener('click', function () {
				var id = btn.getAttribute('data-id');
				if (!confirm('Xóa câu hỏi này?')) return;
				AdminCommon.apiJson('/api/admin/questions/' + id, { method: 'DELETE' })
					.then(function (r) { return r.json(); })
					.then(function (x) {
						showFlash('Đã xóa (' + x.mode + ').', true);
						load();
					})
					.catch(function (e) { showFlash(e.message || 'Lỗi', false); });
			});
		});

		totalPages = data.totalPages || 0;
		document.getElementById('page-info').textContent =
			'Trang ' + ((data.number || 0) + 1) + '/' + (totalPages || 1) + ' · ' + (data.totalElements || 0) + ' câu hỏi';
		document.getElementById('btn-prev').disabled = page <= 0;
		document.getElementById('btn-next').disabled = page >= totalPages - 1 || totalPages === 0;
	}

	function load() {
		AdminCommon.apiJson(currentFilters())
			.then(function (r) { return r.json(); })
			.then(renderTable)
			.catch(function (e) { if (e.message !== 'Unauthorized') showFlash(e.message || 'Không tải được dữ liệu', false); });
	}

	function fillForm(id) {
		var q = cacheRows.find(function (x) { return x.id === id; });
		if (!q) return;
		document.getElementById('q-id').value = q.id;
		document.getElementById('q-content').value = q.content || '';
		document.getElementById('q-opt-a').value = q.options && q.options[0] ? q.options[0] : '';
		document.getElementById('q-opt-b').value = q.options && q.options[1] ? q.options[1] : '';
		document.getElementById('q-opt-c').value = q.options && q.options[2] ? q.options[2] : '';
		document.getElementById('q-opt-d').value = q.options && q.options[3] ? q.options[3] : '';
		document.getElementById('q-answer').value = q.correctAnswer || 'A';
		document.getElementById('q-band').value = q.cefrBand || 'A1';
		document.getElementById('q-skill').value = q.skillType || 'VOCABULARY';
		document.getElementById('q-diff').value = q.difficultyScore;
		document.getElementById('q-active').checked = !!q.isActive;
	}

	function clearForm() {
		document.getElementById('q-id').value = '';
		document.getElementById('q-content').value = '';
		document.getElementById('q-opt-a').value = '';
		document.getElementById('q-opt-b').value = '';
		document.getElementById('q-opt-c').value = '';
		document.getElementById('q-opt-d').value = '';
		document.getElementById('q-answer').value = 'A';
		document.getElementById('q-band').value = 'A1';
		document.getElementById('q-skill').value = 'VOCABULARY';
		document.getElementById('q-diff').value = '0.5';
		document.getElementById('q-active').checked = true;
	}

	document.getElementById('form-question').addEventListener('submit', function (e) {
		e.preventDefault();
		var id = document.getElementById('q-id').value;
		var body = {
			content: document.getElementById('q-content').value.trim(),
			options: [
				document.getElementById('q-opt-a').value.trim(),
				document.getElementById('q-opt-b').value.trim(),
				document.getElementById('q-opt-c').value.trim(),
				document.getElementById('q-opt-d').value.trim(),
			],
			correctAnswer: document.getElementById('q-answer').value,
			cefrBand: document.getElementById('q-band').value,
			skillType: document.getElementById('q-skill').value,
			difficultyScore: Number(document.getElementById('q-diff').value),
			isActive: document.getElementById('q-active').checked,
		};

		var url = id ? '/api/admin/questions/' + id : '/api/admin/questions';
		var method = id ? 'PUT' : 'POST';
		AdminCommon.apiJson(url, { method: method, body: JSON.stringify(body) })
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) { throw new Error(j.message || 'Lỗi ' + r.status); });
				}
				return r.json();
			})
			.then(function () {
				showFlash(id ? 'Đã cập nhật câu hỏi.' : 'Đã tạo câu hỏi.', true);
				clearForm();
				load();
			})
			.catch(function (err) { showFlash(err.message || 'Lỗi', false); });
	});

	document.getElementById('btn-load').addEventListener('click', function () {
		page = 0;
		load();
	});
	document.getElementById('btn-prev').addEventListener('click', function () {
		if (page > 0) {
			page--;
			load();
		}
	});
	document.getElementById('btn-next').addEventListener('click', function () {
		if (page < totalPages - 1) {
			page++;
			load();
		}
	});
	document.getElementById('btn-clear').addEventListener('click', clearForm);

	document.getElementById('btn-load-warnings').addEventListener('click', function () {
		AdminCommon.apiJson('/api/admin/questions/warnings')
			.then(function (r) { return r.json(); })
			.then(function (data) {
				var box = document.getElementById('warning-out');
				box.style.display = 'block';
				box.textContent = JSON.stringify(data, null, 2);
				if (data.missingByBand && Object.keys(data.missingByBand).length > 0) {
					showFlash('Có band dưới ngưỡng tối thiểu.', false);
				} else {
					showFlash('Ngân hàng câu hỏi đã đạt ngưỡng tối thiểu.', true);
				}
			})
			.catch(function (err) { showFlash(err.message || 'Không tải được cảnh báo', false); });
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
			}).finally(function () { window.location.href = '/admin/login'; });
		} else {
			window.location.href = '/admin/login';
		}
	});

	fetch('/api/users/me', { headers: AdminCommon.authHeaders() })
		.then(function (r) { return r.ok ? r.json() : null; })
		.then(function (me) {
			if (!me || me.role !== 'ADMIN') {
				window.location.href = '/admin/login';
				return;
			}
			document.getElementById('user-line').textContent = me.email + (me.fullName ? ' · ' + me.fullName : '');
		});

	load();
})();
