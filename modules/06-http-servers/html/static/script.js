// HTTP Server Test JavaScript
console.log('HTTP Server Test JavaScript loaded');

// Utility functions
function showResult(elementId, message, type = 'info') {
    const resultDiv = document.getElementById(elementId);
    resultDiv.style.display = 'block';
    resultDiv.className = `result ${type}`;
    resultDiv.innerHTML = message;
}

function formatTime(timestamp) {
    return new Date(timestamp).toLocaleString();
}

function updateCurrentTime() {
    const timeElement = document.getElementById('current-time');
    if (timeElement) {
        timeElement.textContent = new Date().toLocaleString();
    }
}

// Initialize page
document.addEventListener('DOMContentLoaded', function () {
    console.log('HTTP Server Test page loaded');
    updateCurrentTime();
    setInterval(updateCurrentTime, 1000);
});

// Export functions for global use
window.showResult = showResult;
window.formatTime = formatTime;
