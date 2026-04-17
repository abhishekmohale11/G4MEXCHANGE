const API_URL = 'http://localhost:3000/api';

// Create floating particles animation
function createParticles() {
    const particlesContainer = document.getElementById('particles');
    if (!particlesContainer) return;
    
    for (let i = 0; i < 50; i++) {
        const particle = document.createElement('div');
        particle.className = 'particle';
        particle.style.left = Math.random() * 100 + '%';
        particle.style.animationDelay = Math.random() * 20 + 's';
        particle.style.animationDuration = 15 + Math.random() * 10 + 's';
        particle.style.width = Math.random() * 6 + 2 + 'px';
        particle.style.height = particle.style.width;
        particlesContainer.appendChild(particle);
    }
}

// Tab switching
document.getElementById('loginTab')?.addEventListener('click', () => {
    document.getElementById('loginTab').classList.add('active');
    document.getElementById('registerTab').classList.remove('active');
    document.getElementById('loginForm').classList.add('active');
    document.getElementById('registerForm').classList.remove('active');
});

document.getElementById('registerTab')?.addEventListener('click', () => {
    document.getElementById('registerTab').classList.add('active');
    document.getElementById('loginTab').classList.remove('active');
    document.getElementById('registerForm').classList.add('active');
    document.getElementById('loginForm').classList.remove('active');
});

function showToast(message, type = 'success') {
    const toast = document.getElementById('toast');
    if (!toast) return;
    
    toast.textContent = message;
    toast.className = `toast ${type}`;
    toast.classList.remove('hidden');
    
    setTimeout(() => {
        toast.classList.add('hidden');
    }, 3000);
}

// Login Form Submit
document.getElementById('loginFormElement')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    if (!username || !password) {
        showToast('Please fill all fields', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            showToast('Login successful! Redirecting...', 'success');
            
            setTimeout(() => {
                window.location.href = '/dashboard.html';
            }, 1000);
        } else {
            showToast(data.error || 'Login failed', 'error');
        }
    } catch (error) {
        showToast('Network error. Is the server running?', 'error');
    }
});

// Register Form Submit
document.getElementById('registerFormElement')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const full_name = document.getElementById('regFullName').value;
    const username = document.getElementById('regUsername').value;
    const email = document.getElementById('regEmail').value;
    const phone = document.getElementById('regPhone').value;
    const password = document.getElementById('regPassword').value;
    const city = document.getElementById('regCity').value;
    const gaming_platform = document.getElementById('regPlatform').value;
    const preferred_game = document.getElementById('regGame').value;
    
    if (!full_name || !username || !email || !phone || !password) {
        showToast('Please fill all required fields (*)', 'error');
        return;
    }
    
    if (password.length < 6) {
        showToast('Password must be at least 6 characters', 'error');
        return;
    }
    
    if (!/^\d{10}$/.test(phone)) {
        showToast('Please enter a valid 10-digit phone number', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ 
                full_name, username, email, phone, password, 
                city, gaming_platform, preferred_game 
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            showToast('Registration successful! Redirecting...', 'success');
            
            setTimeout(() => {
                window.location.href = '/dashboard.html';
            }, 1000);
        } else {
            showToast(data.error || 'Registration failed', 'error');
        }
    } catch (error) {
        showToast('Network error. Is the server running?', 'error');
    }
});

// Initialize particles on page load
document.addEventListener('DOMContentLoaded', () => {
    createParticles();
    
    // Add input formatting for card fields if they exist
    const cardNumberFields = ['cardNumber', 'addCardNumber'];
    cardNumberFields.forEach(fieldId => {
        const field = document.getElementById(fieldId);
        if (field) {
            field.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length > 16) value = value.slice(0, 16);
                value = value.replace(/(\d{4})(?=\d)/g, '$1 ');
                e.target.value = value;
            });
        }
    });
    
    const expiryFields = ['cardExpiry', 'addCardExpiry'];
    expiryFields.forEach(fieldId => {
        const field = document.getElementById(fieldId);
        if (field) {
            field.addEventListener('input', function(e) {
                let value = e.target.value.replace(/\D/g, '');
                if (value.length >= 2) value = value.slice(0,2) + '/' + value.slice(2,4);
                if (value.length > 5) value = value.slice(0,5);
                e.target.value = value;
            });
        }
    });
});

// Login Form Submit - Updated version
document.getElementById('loginFormElement')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    if (!username || !password) {
        showToast('Please fill all fields', 'error');
        return;
    }
    
    try {
        const response = await fetch(`${API_URL}/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            localStorage.setItem('token', data.token);
            localStorage.setItem('user', JSON.stringify(data.user));
            showToast('Login successful! Redirecting...', 'success');
            
            setTimeout(() => {
                // Use replace instead of href to prevent back button issues
                window.location.replace('/dashboard.html');
            }, 1000);
        } else {
            showToast(data.error || 'Login failed', 'error');
        }
    } catch (error) {
        showToast('Network error. Is the server running?', 'error');
    }
});