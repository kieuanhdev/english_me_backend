<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Pronunciation Practice</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; }
        .row { margin-bottom: 12px; }
        .button-group button { margin-right: 8px; }
        #results li.bad { color: #c62828; }
        #results li.ok { color: #2e7d32; }
        .muted { color: #6b7280; }
    </style>
</head>
<body>
<h2>AI Pronunciation Practice (MVP)</h2>

<div class="row">
    <label for="token">Firebase Bearer token:</label><br/>
    <input id="token" style="width: 100%;" placeholder="Paste token here"/>
</div>

<div class="row">
    <label for="referenceText">Reference sentence:</label><br/>
    <textarea id="referenceText" rows="3" style="width: 100%;">I would like to improve my English pronunciation every day.</textarea>
</div>

<div class="row">
    <label for="exerciseId">Exercise ID (optional UUID):</label><br/>
    <input id="exerciseId" style="width: 100%;" placeholder="Optional"/>
</div>

<div class="row button-group">
    <button id="startBtn">Start Recording</button>
    <button id="stopBtn" disabled>Stop</button>
    <button id="submitBtn" disabled>Submit for Scoring</button>
</div>

<p id="status" class="muted">Status: idle</p>
<h3>Result</h3>
<pre id="scoreCard">No result yet.</pre>
<ul id="results"></ul>

<script>
    let recorder = null;
    let chunks = [];
    let audioBlob = null;

    const startBtn = document.getElementById('startBtn');
    const stopBtn = document.getElementById('stopBtn');
    const submitBtn = document.getElementById('submitBtn');
    const statusEl = document.getElementById('status');
    const scoreCard = document.getElementById('scoreCard');
    const resultsEl = document.getElementById('results');

    startBtn.addEventListener('click', async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            recorder = new MediaRecorder(stream);
            chunks = [];
            recorder.ondataavailable = event => {
                if (event.data && event.data.size > 0) chunks.push(event.data);
            };
            recorder.onstop = () => {
                audioBlob = new Blob(chunks, { type: 'audio/webm' });
                submitBtn.disabled = false;
                statusEl.textContent = 'Status: recording stopped, ready to submit';
            };
            recorder.start();
            startBtn.disabled = true;
            stopBtn.disabled = false;
            submitBtn.disabled = true;
            statusEl.textContent = 'Status: recording...';
        } catch (error) {
            statusEl.textContent = 'Status: microphone access failed';
        }
    });

    stopBtn.addEventListener('click', () => {
        if (recorder && recorder.state !== 'inactive') {
            recorder.stop();
        }
        startBtn.disabled = false;
        stopBtn.disabled = true;
    });

    submitBtn.addEventListener('click', async () => {
        if (!audioBlob) return;
        const token = document.getElementById('token').value.trim();
        const referenceText = document.getElementById('referenceText').value.trim();
        const exerciseId = document.getElementById('exerciseId').value.trim();
        if (!token || !referenceText) {
            statusEl.textContent = 'Status: token and reference text are required';
            return;
        }

        const formData = new FormData();
        formData.append('audio', audioBlob, 'attempt.webm');
        formData.append('expectedText', referenceText);
        formData.append('language', 'en-us');
        if (exerciseId) formData.append('exerciseId', exerciseId);

        statusEl.textContent = 'Status: uploading and scoring...';
        submitBtn.disabled = true;

        try {
            const response = await fetch('/api/pronunciation/assess', {
                method: 'POST',
                headers: { 'Authorization': 'Bearer ' + token },
                body: formData
            });
            const data = await response.json();
            if (!response.ok) {
                throw new Error(data.message || 'Scoring failed');
            }

            scoreCard.textContent = [
                'Score: ' + data.score,
                'Accuracy: ' + data.accuracy,
                'Fluency: ' + data.fluency,
                'Completeness: ' + data.completeness,
                'Transcription: ' + data.transcription,
                'Comment: ' + data.overallComment
            ].join('\\n');

            resultsEl.innerHTML = '';
            (data.errors || []).forEach(item => {
                const li = document.createElement('li');
                li.className = 'bad';
                li.textContent = item.word + ' (position ' + item.position + ') - ' + item.suggestion;
                resultsEl.appendChild(li);
            });
            statusEl.textContent = 'Status: scored successfully';
        } catch (error) {
            statusEl.textContent = 'Status: ' + error.message;
        } finally {
            submitBtn.disabled = false;
        }
    });
</script>
</body>
</html>
