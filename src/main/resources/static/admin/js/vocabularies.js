(function () {
	if (AdminCommon.redirectIfNoToken()) return;

	var page = 0;
	var size = 20;
	var totalPages = 0;

	var flash = document.getElementById('flash');
	function showFlash(msg, ok) {
		flash.textContent = msg;
		flash.className = 'flash show ' + (ok ? 'flash-ok' : 'flash-err');
	}
	function hideFlash() {
		flash.className = 'flash';
	}

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

	fetch('/api/users/me', { headers: AdminCommon.authHeaders() })
		.then(function (r) {
			if (r.status === 401) {
				window.location.href = '/admin/login';
				return null;
			}
			return r.json();
		})
		.then(function (me) {
			if (!me || me.role !== 'ADMIN') {
				window.location.href = '/admin/login';
				return;
			}
			document.getElementById('user-line').textContent = me.email + (me.fullName ? ' · ' + me.fullName : '');
		});

	function buildQuery() {
		var q = document.getElementById('q').value.trim();
		var inc = document.getElementById('includeDeleted').checked;
		var params = new URLSearchParams();
		params.set('page', String(page));
		params.set('size', String(size));
		params.set('includeDeleted', String(inc));
		params.append('sort', 'createdAt,desc');
		if (q) params.set('q', q);
		return '/api/admin/vocabularies?' + params.toString();
	}

	function renderTable(data) {
		var body = document.getElementById('tbl-body');
		body.innerHTML = '';
		var rows = data.content || [];
		rows.forEach(function (row) {
			var tr = document.createElement('tr');
			var mean = row.meaningVi || '';
			if (mean.length > 80) mean = mean.slice(0, 80) + '…';
			var del = row.deletedAt != null;
			tr.innerHTML =
				'<td>' +
				escapeHtml(row.word) +
				'</td><td>' +
				escapeHtml(mean) +
				'</td><td>' +
				escapeHtml(row.cefrLevel || '—') +
				'</td><td>' +
				(del ? '<span class="badge badge-del">Đã xóa mềm</span>' : '<span class="badge badge-ok">Active</span>') +
				'</td><td class="btn-row">' +
				'<button type="button" class="btn-secondary btn-sm btn-edit" data-id="' +
				row.id +
				'">Sửa</button> ' +
				(!del ? '<button type="button" class="btn-danger btn-sm btn-del" data-id="' + row.id + '">Xóa mềm</button>' : '') +
				'</td>';
			body.appendChild(tr);
		});

		body.querySelectorAll('.btn-edit').forEach(function (btn) {
			btn.addEventListener('click', function () {
				fillEdit(btn.getAttribute('data-id'), rows);
			});
		});
		body.querySelectorAll('.btn-del').forEach(function (btn) {
			btn.addEventListener('click', function () {
				var id = btn.getAttribute('data-id');
				if (!confirm('Xóa mềm từ vựng này?')) return;
				AdminCommon.apiJson('/api/admin/vocabularies/' + id, { method: 'DELETE' }).then(function (r) {
					if (!r.ok) {
						return r.json().then(function (j) {
							throw new Error(j.message || r.status);
						});
					}
					showFlash('Đã xóa mềm.', true);
					load();
				}).catch(function (e) {
					showFlash(e.message || 'Lỗi', false);
				});
			});
		});

		totalPages = data.totalPages || 0;
		document.getElementById('page-info').textContent =
			'Trang ' + ((data.number != null ? data.number : page) + 1) + ' / ' + (totalPages || 1) +
			' · ' +
			(data.totalElements != null ? data.totalElements : rows.length) +
			' bản ghi';
		document.getElementById('btn-prev').disabled = page <= 0;
		document.getElementById('btn-next').disabled = page >= totalPages - 1 || totalPages === 0;
	}

	function fillEdit(id, rows) {
		var row = rows.find(function (r) {
			return r.id === id;
		});
		if (!row) return;
		document.getElementById('e-id').value = row.id;
		document.getElementById('e-word').value = row.word || '';
		document.getElementById('e-meaning').value = row.meaningVi || '';
		document.getElementById('e-phonetic').value = row.phonetic || '';
		document.getElementById('e-pos').value = row.partOfSpeech || '';
		document.getElementById('e-example').value = row.exampleSentence || '';
		document.getElementById('e-audio').value = row.audioUrl || '';
		document.getElementById('e-image').value = row.imageUrl || '';
		var sel = document.getElementById('e-cefr');
		sel.value = row.cefrLevel || '';
		document.getElementById('form-edit').scrollIntoView({ behavior: 'smooth', block: 'start' });
	}

	function load() {
		hideFlash();
		AdminCommon.apiJson(buildQuery())
			.then(function (r) {
				return r.json();
			})
			.then(renderTable)
			.catch(function (e) {
				if (e.message !== 'Unauthorized') showFlash(e.message || 'Không tải được danh sách', false);
			});
	}

	function escapeHtml(s) {
		if (!s) return '';
		return String(s)
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;');
	}

	document.getElementById('btn-search').addEventListener('click', function () {
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

	document.getElementById('form-create').addEventListener('submit', function (e) {
		e.preventDefault();
		var body = {
			word: document.getElementById('c-word').value.trim(),
			meaningVi: document.getElementById('c-meaning').value.trim(),
			phonetic: nullIfEmpty(document.getElementById('c-phonetic').value),
			partOfSpeech: nullIfEmpty(document.getElementById('c-pos').value),
			exampleSentence: nullIfEmpty(document.getElementById('c-example').value),
			audioUrl: nullIfEmpty(document.getElementById('c-audio').value),
			imageUrl: nullIfEmpty(document.getElementById('c-image').value),
			cefrLevel: nullIfEmpty(document.getElementById('c-cefr').value),
		};
		AdminCommon.apiJson('/api/admin/vocabularies', {
			method: 'POST',
			body: JSON.stringify(body),
		})
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || 'Lỗi ' + r.status);
					});
				}
				return r.json();
			})
			.then(function () {
				showFlash('Đã tạo từ vựng.', true);
				document.getElementById('form-create').reset();
				load();
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	document.getElementById('form-edit').addEventListener('submit', function (e) {
		e.preventDefault();
		var id = document.getElementById('e-id').value;
		if (!id) {
			showFlash('Chưa chọn bản ghi (bấm Sửa trên bảng).', false);
			return;
		}
		var patch = {};
		var w = document.getElementById('e-word').value;
		if (w.trim()) patch.word = w.trim();
		var m = document.getElementById('e-meaning').value;
		if (m !== '') patch.meaningVi = m.trim();
		if (document.getElementById('e-phonetic').value !== '') patch.phonetic = nullIfEmpty(document.getElementById('e-phonetic').value);
		if (document.getElementById('e-pos').value !== '') patch.partOfSpeech = nullIfEmpty(document.getElementById('e-pos').value);
		if (document.getElementById('e-example').value !== '') patch.exampleSentence = nullIfEmpty(document.getElementById('e-example').value);
		if (document.getElementById('e-audio').value !== '') patch.audioUrl = nullIfEmpty(document.getElementById('e-audio').value);
		if (document.getElementById('e-image').value !== '') patch.imageUrl = nullIfEmpty(document.getElementById('e-image').value);
		var cef = document.getElementById('e-cefr').value;
		if (cef) patch.cefrLevel = cef;

		if (Object.keys(patch).length === 0) {
			showFlash('Không có trường nào để cập nhật.', false);
			return;
		}

		AdminCommon.apiJson('/api/admin/vocabularies/' + id, {
			method: 'PATCH',
			body: JSON.stringify(patch),
		})
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || 'Lỗi ' + r.status);
					});
				}
				return r.json();
			})
			.then(function () {
				showFlash('Đã cập nhật.', true);
				load();
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	document.getElementById('form-import').addEventListener('submit', function (e) {
		e.preventDefault();
		var f = document.getElementById('import-file').files[0];
		if (!f) {
			showFlash('Chọn file trước.', false);
			return;
		}
		var fd = new FormData();
		fd.append('file', f);
		var out = document.getElementById('import-out');
		out.style.display = 'block';
		out.textContent = 'Đang gửi…';
		fetch('/api/admin/vocabularies/import', {
			method: 'POST',
			headers: { Authorization: 'Bearer ' + AdminCommon.getAdminToken() },
			body: fd,
		})
			.then(function (r) {
				if (r.status === 401) {
					window.location.href = '/admin/login';
					return null;
				}
				return r.json().then(function (j) {
					return { ok: r.ok, body: j };
				});
			})
			.then(function (x) {
				if (!x) return;
				out.textContent = JSON.stringify(x.body, null, 2);
				if (x.ok) showFlash('Import xong: ' + (x.body.successCount || 0) + ' dòng thành công.', true);
				else showFlash(x.body.message || 'Import lỗi', false);
				load();
			})
			.catch(function () {
				out.textContent = 'Lỗi mạng hoặc server.';
				showFlash('Lỗi kết nối.', false);
			});
	});

	function nullIfEmpty(s) {
		if (s == null || String(s).trim() === '') return null;
		return String(s).trim();
	}

	load();
})();
