<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover, user-scalable=no">
<title>AR Measure Tool - Enhanced</title>
<style>
* {
margin: 0;
padding: 0;
box-sizing: border-box;
user-select: none;
-webkit-tap-highlight-color: transparent;
}

body {
overflow: hidden;
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
background: #000;
touch-action: none;
}

#container {
position: relative;
width: 100vw;
height: 100vh;
background: #000;
}

#video {
position: absolute;
top: 0;
left: 0;
width: 100%;
height: 100%;
object-fit: cover;
}

#canvas {
position: absolute;
top: 0;
left: 0;
width: 100%;
height: 100%;
z-index: 10;
touch-action: none;
}

/* Mobile-friendly overlay - larger touch targets (44px+ per Apple HIG) */
    .overlay {
position: fixed;
bottom: 0;
left: 0;
right: 0;
background: rgba(0, 0, 0, 0.95);
backdrop-filter: blur(20px);
padding: 20px;
z-index: 20;
border-top: 1px solid rgba(255, 255, 255, 0.1);
padding-bottom: max(20px, env(safe-area-inset-bottom));
}

    .distance-card {
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
border-radius: 20px;
padding: 20px;
margin-bottom: 15px;
text-align: center;
transition: transform 0.2s;
}

    .distance-card:active {
transform: scale(0.98);
}

    .distance-label {
color: rgba(255, 255, 255, 0.8);
font-size: 14px;
letter-spacing: 1px;
margin-bottom: 8px;
}

    .distance-value {
color: white;
font-size: 48px;
font-weight: bold;
font-family: monospace;
}

    .distance-unit {
font-size: 20px;
margin-left: 5px;
}

/* Buttons: minimum 44x44px touch target (Apple HIG) */
    .button-group {
display: flex;
gap: 12px;
margin-bottom: 15px;
flex-wrap: wrap;
}

button {
flex: 1;
min-width: 70px;
background: rgba(255, 255, 255, 0.1);
border: 1px solid rgba(255, 255, 255, 0.2);
padding: 16px;
border-radius: 14px;
color: white;
font-size: 14px;
font-weight: 600;
cursor: pointer;
transition: all 0.2s;
min-height: 52px;
touch-action: manipulation;
}

button:active {
transform: scale(0.97);
background: rgba(255, 255, 255, 0.2);
}

button:disabled {
opacity: 0.5;
transform: none;
}

    .status {
text-align: center;
color: rgba(255, 255, 255, 0.6);
font-size: 12px;
padding: 10px;
}

/* Instruction banner - mobile optimized */
    .instruction {
position: fixed;
top: 20px;
left: 20px;
right: 20px;
background: rgba(0, 0, 0, 0.8);
backdrop-filter: blur(10px);
padding: 14px;
border-radius: 16px;
color: white;
font-size: 14px;
font-weight: 500;
text-align: center;
z-index: 20;
pointer-events: none;
top: max(20px, env(safe-area-inset-top));
}

/* Crosshair with pulse animation */
    .crosshair {
position: fixed;
top: 50%;
left: 50%;
width: 50px;
height: 50px;
transform: translate(-50%, -50%);
z-index: 15;
pointer-events: none;
animation: pulse 2s infinite;
}

@keyframes pulse {
0%, 100% { opacity: 0.5; transform: translate(-50%, -50%) scale(1); }
50% { opacity: 1; transform: translate(-50%, -50%) scale(1.1); }
}

    .crosshair::before,
    .crosshair::after {
content: '';
position: absolute;
background: rgba(255, 255, 255, 0.9);
}

    .crosshair::before {
top: 50%;
left: 0;
right: 0;
height: 2px;
transform: translateY(-50%);
}

    .crosshair::after {
left: 50%;
top: 0;
bottom: 0;
width: 2px;
transform: translateX(-50%);
}

    .crosshair-circle {
position: absolute;
top: 50%;
left: 50%;
width: 40px;
height: 40px;
transform: translate(-50%, -50%);
border: 2px solid rgba(255, 255, 255, 0.9);
border-radius: 50%;
}

/* History panel - slide up */
    .history-panel {
position: fixed;
bottom: 0;
left: 0;
right: 0;
background: rgba(0, 0, 0, 0.95);
backdrop-filter: blur(20px);
border-radius: 20px 20px 0 0;
transform: translateY(100%);
transition: transform 0.3s ease-out;
z-index: 30;
max-height: 50vh;
display: flex;
flex-direction: column;
padding-bottom: env(safe-area-inset-bottom);
}

    .history-panel.open {
transform: translateY(0);
}

    .history-header {
display: flex;
justify-content: space-between;
align-items: center;
padding: 16px 20px;
border-bottom: 1px solid rgba(255,255,255,0.1);
}

    .history-title {
font-size: 18px;
font-weight: bold;
color: white;
}

    .history-close {
background: none;
border: none;
color: #667eea;
font-size: 24px;
padding: 8px;
min-height: auto;
}

    .history-list {
overflow-y: auto;
padding: 12px;
}

    .history-item {
display: flex;
justify-content: space-between;
align-items: center;
padding: 14px 16px;
background: rgba(255,255,255,0.08);
margin: 8px 0;
border-radius: 14px;
}

    .history-distance {
font-size: 18px;
font-weight: bold;
color: #4CAF50;
}

    .history-time {
font-size: 12px;
color: rgba(255,255,255,0.5);
}

    .history-empty {
text-align: center;
color: rgba(255,255,255,0.5);
padding: 40px;
}

/* Calibration panel */
    .calibration-panel {
position: fixed;
top: 50%;
left: 50%;
transform: translate(-50%, -50%);
background: rgba(0, 0, 0, 0.95);
backdrop-filter: blur(20px);
border-radius: 24px;
padding: 24px;
z-index: 40;
min-width: 280px;
max-width: 340px;
border: 1px solid rgba(255,255,255,0.2);
text-align: center;
}

    .calibration-panel h3 {
color: white;
margin-bottom: 12px;
}

    .calibration-panel p {
color: rgba(255,255,255,0.7);
margin-bottom: 20px;
font-size: 14px;
line-height: 1.4;
}

    .calibration-buttons {
display: flex;
gap: 12px;
}

/* Visual feedback for taps */
    .tap-feedback {
position: fixed;
background: rgba(255,255,255,0.3);
border-radius: 50%;
width: 60px;
height: 60px;
transform: translate(-50%, -50%);
pointer-events: none;
z-index: 100;
animation: ripple 0.3s ease-out forwards;
}

@keyframes ripple {
0% { transform: translate(-50%, -50%) scale(0); opacity: 0.8; }
100% { transform: translate(-50%, -50%) scale(2); opacity: 0; }
}

/* Calibration badge */
    .calibration-badge {
position: fixed;
bottom: 120px;
right: 16px;
background: rgba(76, 175, 80, 0.9);
padding: 8px 14px;
border-radius: 20px;
font-size: 11px;
font-weight: bold;
color: white;
z-index: 20;
pointer-events: none;
backdrop-filter: blur(4px);
}

/* Share button */
    .share-btn {
background: rgba(255, 255, 255, 0.15);
border: 1px solid rgba(255, 255, 255, 0.3);
}

/* Loading indicator */
    .loading {
position: fixed;
top: 50%;
left: 50%;
transform: translate(-50%, -50%);
color: white;
z-index: 50;
background: rgba(0,0,0,0.8);
padding: 16px 24px;
border-radius: 30px;
font-size: 14px;
}
</style>
</head>
<body>
<div id="container">
<video id="video" autoplay playsinline muted></video>
<canvas id="canvas"></canvas>

<div class="crosshair">
<div class="crosshair-circle"></div>
</div>

<div class="instruction" id="instruction">
🎯 Tap screen to place point A
</div>

<div class="overlay">
<div class="distance-card">
<div class="distance-label">MEASURED DISTANCE</div>
<div class="distance-value">
<span id="distanceValue">0.00</span>
<span class="distance-unit">cm</span>
</div>
</div>

<div class="button-group">
<button id="calibrateBtn">📐 Calibrate</button>
<button id="historyBtn">📊 History</button>
<button id="shareBtn" class="share-btn">📤 Share</button>
<button id="clearBtn">🗑️ Clear</button>
</div>

<div class="status" id="status">
Ready to measure
</div>
</div>

<!-- History Panel -->
<div class="history-panel" id="historyPanel">
<div class="history-header">
<span class="history-title">📊 Measurement History</span>
<button class="history-close" id="closeHistoryBtn">✕</button>
</div>
<div class="history-list" id="historyList">
<div class="history-empty">No measurements yet</div>
</div>
</div>

<!-- Calibration Badge -->
<div class="calibration-badge" id="calibrationBadge" style="display: none;">
✓ Calibrated
</div>
</div>

<script>
// ==================== DOM Elements ====================
const video = document.getElementById('video');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
const distanceValue = document.getElementById('distanceValue');
const instruction = document.getElementById('instruction');
const status = document.getElementById('status');
const historyPanel = document.getElementById('historyPanel');
const historyList = document.getElementById('historyList');
const calibrationBadge = document.getElementById('calibrationBadge');

// ==================== State ====================
let points = [];
let measurements = [];
let currentDistance = 0;
let lastTapTime = 0;
let calibrationFactor = 1.0;
let isCalibrated = false;

// Camera parameters
let focalLength = 800;
let referenceWidth = 30;

// ==================== Haptic Feedback ====================
function vibrate(duration = 30) {
if ('vibrate' in navigator) {
navigator.vibrate(duration);
}
}

function showTapFeedback(x, y) {
const feedback = document.createElement('div');
feedback.className = 'tap-feedback';
feedback.style.left = x + 'px';
feedback.style.top = y + 'px';
document.body.appendChild(feedback);
setTimeout(() => feedback.remove(), 300);
}

// ==================== Camera Initialization ====================
async function initCamera() {
try {
const stream = await navigator.mediaDevices.getUserMedia({
video: {
facingMode: 'environment',
width: { ideal: 1920 },
height: { ideal: 1080 }
}
});
video.srcObject = stream;
await video.play();

resizeCanvas();
requestAnimationFrame(draw);

status.textContent = 'Camera ready! Tap screen to measure';
instruction.textContent = '🎯 Tap screen to place point A';
vibrate(50);

} catch (err) {
console.error('Camera error:', err);
status.textContent = '⚠️ Camera access required. Please allow camera permission.';
instruction.textContent = 'Camera permission needed';
}
}

// ==================== Canvas Drawing ====================
function resizeCanvas() {
canvas.width = window.innerWidth;
canvas.height = window.innerHeight;
}

function draw() {
if (!video.videoWidth) {
requestAnimationFrame(draw);
return;
}

ctx.clearRect(0, 0, canvas.width, canvas.height);
ctx.drawImage(video, 0, 0, canvas.width, canvas.height);

// Draw saved measurements
measurements.forEach(measure => {
drawMeasurement(measure);
});

// Draw current points
if (points.length >= 1) {
drawPoint(points[0], '#4CAF50', 'A', 'Start');
if (points.length >= 2) {
drawPoint(points[1], '#FF5252', 'B', 'End');
drawLine(points[0], points[1]);
const midX = (points[0].x + points[1].x) / 2;
const midY = (points[0].y + points[1].y) / 2;
drawText(`${currentDistance.toFixed(1)} cm`, midX, midY - 15, '#FFD700', 'bold 18px');
}
}

requestAnimationFrame(draw);
}

function drawPoint(point, color, label, text) {
ctx.beginPath();
ctx.arc(point.x, point.y, 14, 0, 2 * Math.PI);
ctx.fillStyle = color + '80';
ctx.fill();
ctx.strokeStyle = color;
ctx.lineWidth = 4;
ctx.stroke();

ctx.fillStyle = color;
ctx.font = 'bold 16px -apple-system';
ctx.shadowBlur = 4;
ctx.shadowColor = 'black';
ctx.fillText(label, point.x + 18, point.y - 12);
ctx.font = '12px -apple-system';
ctx.fillText(text, point.x + 18, point.y + 5);
}

function drawLine(p1, p2) {
ctx.beginPath();
ctx.moveTo(p1.x, p1.y);
ctx.lineTo(p2.x, p2.y);
ctx.strokeStyle = '#FFD700';
ctx.lineWidth = 4;
ctx.setLineDash([10, 6]);
ctx.stroke();
ctx.setLineDash([]);
}

function drawText(text, x, y, color, font) {
ctx.fillStyle = color;
ctx.font = font;
ctx.shadowBlur = 4;
ctx.shadowColor = 'black';
ctx.fillText(text, x, y);
}

function drawMeasurement(measure) {
drawPoint(measure.p1, '#9C27B0', measure.id.toString(), '');
drawPoint(measure.p2, '#9C27B0', measure.id.toString(), '');
drawLine(measure.p1, measure.p2);
const midX = (measure.p1.x + measure.p2.x) / 2;
const midY = (measure.p1.y + measure.p2.y) / 2;
drawText(`${measure.distance.toFixed(1)} cm`, midX, midY - 15, '#9C27B0', 'bold 16px');
}

// ==================== Measurement Logic ====================
function calculateDistance(pixelDistance) {
let estimatedCm = (pixelDistance / focalLength) * referenceWidth;
estimatedCm *= calibrationFactor;
return Math.min(Math.max(estimatedCm, 0), 500);
}

function updateHistoryDisplay() {
if (measurements.length === 0) {
historyList.innerHTML = '<div class="history-empty">📭 No measurements yet\nTap "Start" and measure something!</div>';
return;
}

historyList.innerHTML = measurements.map(m => `
<div class="history-item">
<span class="history-distance">📏 ${m.distance.toFixed(1)} cm</span>
<span class="history-time">${m.time}</span>
</div>
`).join('');
}

// ==================== Calibration ====================
function showCalibrationDialog() {
const panel = document.createElement('div');
panel.className = 'calibration-panel';
panel.innerHTML = `
<h3>📐 Calibrate Measurements</h3>
<p>Place a known 10cm object on screen.<br>
Drag from one end to the other to calibrate.</p>
<div class="calibration-buttons">
<button id="calStartBtn" style="background:#4CAF50;">Start</button>
<button id="calCancelBtn">Cancel</button>
</div>
`;
document.body.appendChild(panel);

document.getElementById('calStartBtn').onclick = () => {
panel.remove();
startCalibration();
};
document.getElementById('calCancelBtn').onclick = () => panel.remove();
}

function startCalibration() {
instruction.textContent = '📐 Drag to draw a 10cm reference line';
status.textContent = 'Draw a line on a 10cm object';

let calibrationStart = null;

const showCalibrationMessage = (msg) => {
status.textContent = msg;
};

const handleCalibrationStart = (e) => {
e.preventDefault();
let clientX, clientY;
if (e.touches) {
clientX = e.touches[0].clientX;
clientY = e.touches[0].clientY;
} else {
clientX = e.clientX;
clientY = e.clientY;
}

const rect = canvas.getBoundingClientRect();
const x = (clientX - rect.left) * (canvas.width / rect.width);
const y = (clientY - rect.top) * (canvas.height / rect.height);
calibrationStart = { x, y };
showCalibrationMessage('Drag to the other end of the 10cm object');
vibrate(20);
};

const handleCalibrationEnd = (e) => {
if (!calibrationStart) return;

e.preventDefault();
let clientX, clientY;
if (e.changedTouches) {
clientX = e.changedTouches[0].clientX;
clientY = e.changedTouches[0].clientY;
} else {
clientX = e.clientX;
clientY = e.clientY;
}

const rect = canvas.getBoundingClientRect();
const x = (clientX - rect.left) * (canvas.width / rect.width);
const y = (clientY - rect.top) * (canvas.height / rect.height);
const calibrationEnd = { x, y };

const dx = calibrationStart.x - calibrationEnd.x;
const dy = calibrationStart.y - calibrationEnd.y;
const pixelDistance = Math.sqrt(dx * dx + dy * dy);

if (pixelDistance > 10) {
const rawCm = (pixelDistance / focalLength) * referenceWidth;
calibrationFactor = 10 / rawCm;
isCalibrated = true;

calibrationBadge.style.display = 'block';
setTimeout(() => {
calibrationBadge.style.opacity = '0';
setTimeout(() => {
calibrationBadge.style.display = 'none';
calibrationBadge.style.opacity = '1';
}, 500);
}, 3000);

status.textContent = `✓ Calibrated! Factor: ${calibrationFactor.toFixed(2)}x`;
instruction.textContent = '🎯 Tap screen to place point A';
vibrate(100);
} else {
status.textContent = '❌ Calibration failed - drag a longer line';
setTimeout(() => {
status.textContent = 'Ready to measure';
}, 2000);
}

// Clean up
canvas.removeEventListener('touchstart', handleCalibrationStart);
canvas.removeEventListener('touchend', handleCalibrationEnd);
canvas.removeEventListener('mousedown', handleCalibrationStart);
canvas.removeEventListener('mouseup', handleCalibrationEnd);
};

canvas.addEventListener('touchstart', handleCalibrationStart);
canvas.addEventListener('touchend', handleCalibrationEnd);
canvas.addEventListener('mousedown', handleCalibrationStart);
canvas.addEventListener('mouseup', handleCalibrationEnd);
}

// ==================== Share Measurements ====================
async function shareMeasurements() {
if (measurements.length === 0) {
status.textContent = 'No measurements to share yet';
setTimeout(() => {
status.textContent = 'Ready to measure';
}, 2000);
return;
}

const summary = measurements.slice(0, 5).map((m, i) =>
`${i+1}. ${m.distance.toFixed(1)} cm at ${m.time}`
).join('\n');

const shareText = `📏 AR Measure Results:\n${summary}\n\nTotal: ${measurements.length} measurements`;

if (navigator.share) {
try {
await navigator.share({
title: 'My AR Measurements',
text: shareText,
});
status.textContent = 'Shared successfully!';
vibrate(50);
} catch (err) {
status.textContent = 'Share cancelled';
}
} else {
// Fallback - copy to clipboard
await navigator.clipboard.writeText(shareText);
status.textContent = 'Copied to clipboard!';
vibrate(50);
setTimeout(() => {
status.textContent = 'Ready to measure';
}, 2000);
}
}

// ==================== Touch/Click Handling ====================
function handleTap(e) {
e.preventDefault();

let clientX, clientY;
if (e.touches) {
clientX = e.touches[0].clientX;
clientY = e.touches[0].clientY;
} else {
clientX = e.clientX;
clientY = e.clientY;
}

const rect = canvas.getBoundingClientRect();
const x = (clientX - rect.left) * (canvas.width / rect.width);
const y = (clientY - rect.top) * (canvas.height / rect.height);

const now = Date.now();
if (now - lastTapTime < 300) return;
lastTapTime = now;

showTapFeedback(clientX, clientY);
vibrate(20);

if (points.length === 0) {
points = [{ x, y }];
instruction.textContent = '📍 Tap again to measure distance';
status.textContent = 'Tap to place point B';
} else if (points.length === 1) {
const p2 = { x, y };
const dx = points[0].x - p2.x;
const dy = points[0].y - p2.y;
const pixelDistance = Math.sqrt(dx * dx + dy * dy);
currentDistance = calculateDistance(pixelDistance);

measurements.unshift({
id: Date.now(),
p1: { ...points[0] },
p2: { ...p2 },
distance: currentDistance,
time: new Date().toLocaleTimeString()
});

distanceValue.textContent = currentDistance.toFixed(2);
instruction.textContent = '✓ Saved! Tap anywhere to start new measurement';
status.textContent = `${currentDistance.toFixed(1)} cm measured`;
points = [];

vibrate(50);
updateHistoryDisplay();
}
}

// ==================== UI Actions ====================
function toggleHistory() {
historyPanel.classList.toggle('open');
vibrate(20);
}

function closeHistory() {
historyPanel.classList.remove('open');
}

function clearAll() {
measurements = [];
points = [];
currentDistance = 0;
distanceValue.textContent = '0.00';
instruction.textContent = '🎯 Tap screen to place point A';
status.textContent = 'All measurements cleared';
updateHistoryDisplay();
vibrate(50);
closeHistory();
}

// ==================== Event Listeners ====================
canvas.addEventListener('click', handleTap);
canvas.addEventListener('touchstart', (e) => {
e.preventDefault();
handleTap(e);
});

document.getElementById('clearBtn').addEventListener('click', clearAll);
document.getElementById('calibrateBtn').addEventListener('click', showCalibrationDialog);
document.getElementById('historyBtn').addEventListener('click', toggleHistory);
document.getElementById('closeHistoryBtn').addEventListener('click', closeHistory);
document.getElementById('shareBtn').addEventListener('click', shareMeasurements);

window.addEventListener('resize', resizeCanvas);
window.addEventListener('orientationchange', () => setTimeout(resizeCanvas, 100));

// Safe areas for notched phones
function updateSafeAreas() {
document.body.style.paddingTop = 'env(safe-area-inset-top)';
document.body.style.paddingBottom = 'env(safe-area-inset-bottom)';
}
updateSafeAreas();

// ==================== Initialize ====================
initCamera();
updateHistoryDisplay();

console.log('AR Measure Tool Ready - Enhanced with haptics, calibration, history & share');
</script>
</body>
</html>