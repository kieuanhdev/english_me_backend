(function () {
	if (AdminCommon.redirectIfNoToken()) return;

	var flash = document.getElementById('flash');
	function showFlash(msg, ok) {
		flash.textContent = msg;
		flash.className = 'flash show ' + (ok ? 'flash-ok' : 'flash-err');
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

	function showOut(id, obj) {
		var el = document.getElementById(id);
		el.style.display = 'block';
		el.textContent = typeof obj === 'string' ? obj : JSON.stringify(obj, null, 2);
	}

	document.getElementById('form-create-deck').addEventListener('submit', function (e) {
		e.preventDefault();
		var body = {
			name: document.getElementById('deck-name').value.trim(),
			description: emptyToNull(document.getElementById('deck-desc').value),
			topic: emptyToNull(document.getElementById('deck-topic').value),
		};
		AdminCommon.apiJson('/api/v1/decks', { method: 'POST', body: JSON.stringify(body) })
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (data) {
				showFlash('Đã tạo deck.', true);
				showOut('out-create-deck', data);
				document.getElementById('w-deck-id').value = data.deckId || '';
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	function emptyToNull(s) {
		if (s == null || String(s).trim() === '') return null;
		return String(s).trim();
	}

	document.getElementById('btn-load-system').addEventListener('click', function () {
		var topic = document.getElementById('sys-topic').value.trim();
		var level = document.getElementById('sys-level').value;
		var q = new URLSearchParams();
		if (topic) q.set('topic', topic);
		if (level) q.set('level', level);
		var url = '/api/v1/decks/system' + (q.toString() ? '?' + q.toString() : '');
		AdminCommon.apiJson(url, { method: 'GET' })
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (list) {
				var tb = document.getElementById('tbl-system');
				tb.innerHTML = '';
				(list || []).forEach(function (d) {
					var tr = document.createElement('tr');
					tr.innerHTML =
						'<td>' +
						esc(d.name) +
						'</td><td>' +
						esc(d.topic || '—') +
						'</td><td>' +
						esc(d.cefrLevel || '—') +
						'</td><td>' +
						d.wordCount +
						'</td><td class="cell-mono">' +
						esc(d.deckId) +
						'</td><td class="btn-row"><button type="button" class="btn-secondary btn-sm pick-deck" data-id="' +
						esc(d.deckId) +
						'">Chọn</button></td>';
					tb.appendChild(tr);
				});
				tb.querySelectorAll('.pick-deck').forEach(function (btn) {
					btn.addEventListener('click', function () {
						document.getElementById('op-deck-id').value = btn.getAttribute('data-id');
					});
				});
				showFlash('Đã tải ' + (list || []).length + ' deck.', true);
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	function esc(s) {
		if (s == null) return '';
		return String(s)
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/"/g, '&quot;');
	}

	document.getElementById('btn-subscribe').addEventListener('click', function () {
		var id = document.getElementById('op-deck-id').value.trim();
		if (!id) {
			showFlash('Nhập deckId.', false);
			return;
		}
		AdminCommon.apiJson('/api/v1/decks/system/' + encodeURIComponent(id) + '/subscribe', { method: 'POST' })
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (data) {
				showFlash('Đã đăng ký học deck.', true);
				showOut('out-subscribe', data);
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	document.getElementById('btn-clone').addEventListener('click', function () {
		var id = document.getElementById('op-deck-id').value.trim();
		if (!id) {
			showFlash('Nhập deckId.', false);
			return;
		}
		AdminCommon.apiJson('/api/v1/decks/system/' + encodeURIComponent(id) + '/clone', { method: 'POST' })
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (data) {
				showFlash('Đã clone deck.', true);
				showOut('out-clone', data);
				if (data.deckId) document.getElementById('w-deck-id').value = data.deckId;
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	document.getElementById('btn-add-word').addEventListener('click', function () {
		var deckId = document.getElementById('w-deck-id').value.trim();
		var vid = document.getElementById('w-vocab-id').value.trim();
		if (!deckId || !vid) {
			showFlash('Nhập deckId và vocabularyId.', false);
			return;
		}
		AdminCommon.apiJson('/api/v1/decks/' + encodeURIComponent(deckId) + '/words', {
			method: 'POST',
			body: JSON.stringify({ vocabularyId: vid }),
		})
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (data) {
				showFlash('Đã thêm từ.', true);
				showOut('out-word', data);
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});

	document.getElementById('btn-remove-word').addEventListener('click', function () {
		var deckId = document.getElementById('w-deck-id').value.trim();
		var vid = document.getElementById('w-vocab-id').value.trim();
		if (!deckId || !vid) {
			showFlash('Nhập deckId và vocabularyId (hoặc flashcardId nếu từ không gắn kho).', false);
			return;
		}
		if (!confirm('Xóa từ này khỏi deck?')) return;
		AdminCommon.apiJson('/api/v1/decks/' + encodeURIComponent(deckId) + '/words/' + encodeURIComponent(vid), {
			method: 'DELETE',
		})
			.then(function (r) {
				if (!r.ok) {
					return r.json().then(function (j) {
						throw new Error(j.message || r.status);
					});
				}
				return r.json();
			})
			.then(function (data) {
				showFlash('Đã xóa (wordCount: ' + data.wordCount + ').', true);
				showOut('out-word', data);
			})
			.catch(function (err) {
				showFlash(err.message || 'Lỗi', false);
			});
	});
})();
