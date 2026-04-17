const express = require('express');
const mysql = require('mysql2');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 3000;
const SECRET_KEY = 'g4mexchange_secret_key_2024';

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// MySQL Connection
const db = mysql.createPool({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'Abhi$1106',
    database: 'g4mexchange',
    waitForConnections: true,
    connectionLimit: 10
});

const promiseDb = db.promise();

// Function to fix passwords on startup
async function fixPasswords() {
    try {
        const hashedPassword = await bcrypt.hash('demo123', 10);
        await promiseDb.query('UPDATE users SET password = ? WHERE username IN ("gamer_alex", "retro_mike", "game_master", "retro_gamer", "xbox_fan")', [hashedPassword]);
        console.log('✅ Passwords fixed for demo users');
    } catch (error) {
        console.log('Note: Run the SQL script first to create tables');
    }
}

// Test connection and fix passwords
db.getConnection(async (err, connection) => {
    if (err) {
        console.error('❌ MySQL Error:', err.message);
        console.log('💡 Make sure MySQL is running');
        console.log('💡 Run the database_G4ME.sql script first');
        process.exit(1);
    }
    console.log('✅ Connected to MySQL database');
    connection.release();
    await fixPasswords();
});

// ============ AUTH ROUTES ============

// Register
app.post('/api/register', async (req, res) => {
    const { full_name, username, email, phone, password, city, gaming_platform, preferred_game } = req.body;

    if (!full_name || !username || !email || !phone || !password) {
        return res.status(400).json({ error: 'Please fill all required fields' });
    }

    if (password.length < 6) {
        return res.status(400).json({ error: 'Password must be at least 6 characters' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        
        const [result] = await promiseDb.query(
            `INSERT INTO users (full_name, username, email, phone, password, city, gaming_platform, preferred_game, role) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'buyer')`,
            [full_name, username, email, phone, hashedPassword, city, gaming_platform, preferred_game]
        );
        
        const token = jwt.sign({ id: result.insertId, username, role: 'buyer' }, SECRET_KEY, { expiresIn: '7d' });
        
        res.json({ message: 'Registration successful!', token, user: { id: result.insertId, username, email, role: 'buyer', full_name } });
        
    } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ error: 'Username, email, or phone already exists' });
        }
        res.status(500).json({ error: 'Registration failed' });
    }
});

// Login
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    console.log('Login attempt for:', username);

    if (!username || !password) {
        return res.status(400).json({ error: 'Please enter username/email and password' });
    }

    try {
        const [rows] = await promiseDb.query('SELECT * FROM users WHERE username = ? OR email = ?', [username, username]);
        
        if (rows.length === 0) {
            console.log('User not found:', username);
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        const user = rows[0];
        
        const validPassword = await bcrypt.compare(password, user.password);
        console.log('Password valid:', validPassword);
        
        if (!validPassword) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }
        
        await promiseDb.query('UPDATE users SET last_login = NOW() WHERE id = ?', [user.id]);
        
        const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, SECRET_KEY, { expiresIn: '7d' });
        
        res.json({
            message: 'Login successful!',
            token,
            user: { id: user.id, username: user.username, email: user.email, full_name: user.full_name, role: user.role }
        });
        
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ error: 'Login failed' });
    }
});

// Verify token
app.post('/api/verify', async (req, res) => {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }

    try {
        const decoded = jwt.verify(token, SECRET_KEY);
        const [rows] = await promiseDb.query('SELECT id, username, email, full_name, role FROM users WHERE id = ?', [decoded.id]);
        
        if (rows.length === 0) {
            return res.status(401).json({ error: 'User not found' });
        }
        
        res.json({ valid: true, user: rows[0] });
    } catch (error) {
        res.status(401).json({ error: 'Invalid token' });
    }
});

// ============ USER ROUTES ============

app.get('/api/users/:id', async (req, res) => {
    try {
        const [rows] = await promiseDb.query('SELECT id, username, email, phone, full_name, city, state, gaming_platform, preferred_game, trust_score, is_verified FROM users WHERE id = ?', [req.params.id]);
        res.json(rows[0]);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.put('/api/users/:id', async (req, res) => {
    const { full_name, phone, city, state, gaming_platform, preferred_game } = req.body;
    try {
        await promiseDb.query('UPDATE users SET full_name=?, phone=?, city=?, state=?, gaming_platform=?, preferred_game=? WHERE id=?', 
            [full_name, phone, city, state, gaming_platform, preferred_game, req.params.id]);
        res.json({ message: 'Profile updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users/:id/stats', async (req, res) => {
    try {
        const [transactions] = await promiseDb.query(
            'SELECT COALESCE(SUM(amount), 0) as total_spent, COUNT(*) as total_purchases FROM transactions WHERE buyer_id = ? AND trans_status = "completed"',
            [req.params.id]
        );
        const [user] = await promiseDb.query('SELECT trust_score FROM users WHERE id = ?', [req.params.id]);
        
        const [monthlyData] = await promiseDb.query(
            `SELECT MONTH(created_at) as month, COALESCE(SUM(amount), 0) as total 
             FROM transactions 
             WHERE buyer_id = ? AND trans_status = "completed" AND YEAR(created_at) = YEAR(CURDATE())
             GROUP BY MONTH(created_at)`,
            [req.params.id]
        );
        
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const spendingData = Array(12).fill(0);
        monthlyData.forEach(d => { spendingData[d.month - 1] = d.total; });
        
        const [categoryData] = await promiseDb.query(
            `SELECT i.category, COUNT(*) as count 
             FROM transactions t 
             JOIN items i ON t.item_id = i.id 
             WHERE t.buyer_id = ? AND t.trans_status = "completed"
             GROUP BY i.category`,
            [req.params.id]
        );
        
        const categories = ['Console', 'Game', 'Accessory'];
        const categoryValues = [0, 0, 0];
        categoryData.forEach(c => {
            const index = categories.indexOf(c.category);
            if (index !== -1) categoryValues[index] = c.count;
        });
        
        res.json({ 
            total_spent: transactions[0]?.total_spent || 0,
            total_purchases: transactions[0]?.total_purchases || 0,
            trust_score: user[0]?.trust_score || 0,
            spending_data: spendingData.slice(0, 6),
            months: months.slice(0, 6),
            category_data: categoryValues,
            recent_activities: [
                { icon: 'fa-shopping-cart', message: 'Welcome to G4MEXCHANGE!', date: 'Just now' },
                { icon: 'fa-star', message: 'Start exploring marketplace', date: 'Today' }
            ]
        });
    } catch (error) {
        res.json({ total_spent: 0, total_purchases: 0, trust_score: 0, spending_data: [0,0,0,0,0,0], months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'], category_data: [0,0,0] });
    }
});

app.get('/api/users/:id/transactions', async (req, res) => {
    try {
        const [rows] = await promiseDb.query(
            `SELECT t.*, i.title as item_title, i.console_type, i.category, i.listing_type, u.username as seller_name 
             FROM transactions t 
             JOIN items i ON t.item_id = i.id 
             JOIN users u ON t.seller_id = u.id
             WHERE t.buyer_id = ? OR t.seller_id = ? 
             ORDER BY t.created_at DESC LIMIT 50`,
            [req.params.id, req.params.id]
        );
        res.json(rows);
    } catch (error) {
        res.json([]);
    }
});

// ============ ITEMS ROUTES ============

app.get('/api/items', async (req, res) => {
    try {
        let query = `SELECT i.*, u.username as seller_name, u.trust_score as seller_trust 
                     FROM items i 
                     JOIN users u ON i.seller_id = u.id 
                     WHERE i.status = 'active'`;
        const params = [];
        
        if (req.query.category && req.query.category !== 'all') {
            query += ' AND i.category = ?';
            params.push(req.query.category);
        }
        if (req.query.console_type && req.query.console_type !== 'all') {
            query += ' AND i.console_type = ?';
            params.push(req.query.console_type);
        }
        if (req.query.listing_type && req.query.listing_type !== 'all') {
            query += ' AND i.listing_type = ?';
            params.push(req.query.listing_type);
        }
        if (req.query.search) {
            query += ' AND (i.title LIKE ? OR i.description LIKE ?)';
            params.push(`%${req.query.search}%`, `%${req.query.search}%`);
        }
        
        query += ' ORDER BY i.created_at DESC';
        
        const [rows] = await promiseDb.query(query, params);
        res.json(rows);
    } catch (error) {
        res.json([]);
    }
});

app.get('/api/users/:userId/listings', async (req, res) => {
    try {
        const [rows] = await promiseDb.query(
            `SELECT i.*, u.username as seller_name 
             FROM items i 
             JOIN users u ON i.seller_id = u.id 
             WHERE i.seller_id = ? 
             ORDER BY i.created_at DESC`,
            [req.params.userId]
        );
        res.json(rows);
    } catch (error) {
        res.json([]);
    }
});

app.post('/api/items', async (req, res) => {
    const { title, category, console_type, description, price, listing_type, item_condition, location, seller_id } = req.body;
    
    if (!title || !category || !price || !seller_id) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    try {
        const [result] = await promiseDb.query(
            `INSERT INTO items (title, category, console_type, description, price, listing_type, item_condition, location, seller_id)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [title, category, console_type, description, price, listing_type, item_condition || 'good', location, seller_id]
        );
        res.json({ id: result.insertId, message: 'Item listed' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.delete('/api/items/:id', async (req, res) => {
    const { seller_id } = req.body;
    try {
        const [result] = await promiseDb.query('DELETE FROM items WHERE id = ? AND seller_id = ?', [req.params.id, seller_id]);
        if (result.affectedRows === 0) {
            return res.status(403).json({ error: 'Not authorized' });
        }
        res.json({ message: 'Item removed' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/items/:id/view', async (req, res) => {
    try {
        await promiseDb.query('UPDATE items SET views = views + 1 WHERE id = ?', [req.params.id]);
        res.json({ success: true });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// ============ TRANSACTION ROUTES ============

app.post('/api/transactions', async (req, res) => {
    const { item_id, buyer_id, transaction_type, amount, rent_start_date, rent_end_date } = req.body;
    
    try {
        const [itemRows] = await promiseDb.query('SELECT seller_id, title FROM items WHERE id = ? AND status = "active"', [item_id]);
        
        if (itemRows.length === 0) {
            return res.status(404).json({ error: 'Item not available' });
        }
        
        const seller_id = itemRows[0].seller_id;
        
        if (seller_id == buyer_id) {
            return res.status(400).json({ error: 'Cannot buy your own item' });
        }
        
        const transactionId = `TXN${Date.now()}${Math.floor(Math.random() * 1000)}`;
        
        await promiseDb.query(
            `INSERT INTO transactions (transaction_id, item_id, buyer_id, seller_id, transaction_type, amount, trans_status, payment_status, rent_start_date, rent_end_date)
             VALUES (?, ?, ?, ?, ?, ?, 'completed', 'paid', ?, ?)`,
            [transactionId, item_id, buyer_id, seller_id, transaction_type, amount, rent_start_date || null, rent_end_date || null]
        );
        
        if (transaction_type === 'buy') {
            await promiseDb.query("UPDATE items SET status = 'sold' WHERE id = ?", [item_id]);
        } else {
            await promiseDb.query("UPDATE items SET status = 'rented' WHERE id = ?", [item_id]);
        }
        
        await promiseDb.query('UPDATE users SET total_transactions = total_transactions + 1, successful_transactions = successful_transactions + 1 WHERE id = ?', [seller_id]);
        await promiseDb.query('UPDATE users SET total_transactions = total_transactions + 1 WHERE id = ?', [buyer_id]);
        
        res.json({ 
            message: 'Transaction completed', 
            transaction_id: transactionId,
            seller_id: seller_id,
            item_title: itemRows[0].title
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/transactions/:id/return', async (req, res) => {
    const transactionId = req.params.id;
    const { user_id } = req.body;
    
    try {
        const [transRows] = await promiseDb.query(
            'SELECT * FROM transactions WHERE id = ? AND buyer_id = ?',
            [transactionId, user_id]
        );
        
        if (transRows.length === 0) {
            return res.status(404).json({ error: 'Transaction not found' });
        }
        
        const transaction = transRows[0];
        const item_id = transaction.item_id;
        const transaction_type = transaction.transaction_type;
        
        if (transaction_type === 'rent') {
            await promiseDb.query("UPDATE transactions SET trans_status = 'returned' WHERE id = ?", [transactionId]);
            await promiseDb.query("UPDATE items SET status = 'active' WHERE id = ?", [item_id]);
            res.json({ message: 'Item returned successfully! It is now available in marketplace.' });
        } else {
            await promiseDb.query("UPDATE transactions SET trans_status = 'cancelled' WHERE id = ?", [transactionId]);
            await promiseDb.query("UPDATE items SET status = 'active' WHERE id = ?", [item_id]);
            res.json({ message: 'Item removed from history and is now available in marketplace.' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/validate-card', async (req, res) => {
    const { card_number, expiry, cvv, card_name } = req.body;
    
    const cardNumberClean = card_number.replace(/\s/g, '');
    const isValidCard = /^\d{16}$/.test(cardNumberClean);
    const isValidExpiry = /^(0[1-9]|1[0-2])\/\d{2}$/.test(expiry);
    const isValidCVV = /^\d{3,4}$/.test(cvv);
    const isValidName = card_name && card_name.length > 3;
    
    if (isValidCard && isValidExpiry && isValidCVV && isValidName) {
        res.json({ valid: true, message: 'Card validated successfully' });
    } else {
        let error = '';
        if (!isValidCard) error = 'Invalid card number (16 digits required)';
        else if (!isValidExpiry) error = 'Invalid expiry date (MM/YY)';
        else if (!isValidCVV) error = 'Invalid CVV (3-4 digits)';
        else error = 'Invalid card details';
        res.json({ valid: false, error });
    }
});

// ============ TRUST SCORE ROUTES ============

app.post('/api/users/:id/update-trust', async (req, res) => {
    const userId = req.params.id;
    const { action } = req.body;
    
    try {
        const [user] = await promiseDb.query('SELECT trust_score FROM users WHERE id = ?', [userId]);
        let currentScore = user[0]?.trust_score || 0;
        let increment = 0;
        let message = '';
        
        switch(action) {
            case 'transaction_complete':
                increment = 5;
                message = '+5 Trust: Completed a transaction';
                break;
            case 'received_5star':
                increment = 10;
                message = '+10 Trust: Received 5-star rating';
                break;
            case 'received_4star':
                increment = 5;
                message = '+5 Trust: Received 4-star rating';
                break;
            case 'item_sold':
                increment = 3;
                message = '+3 Trust: Sold an item';
                break;
            case 'on_time_return':
                increment = 4;
                message = '+4 Trust: Returned item on time';
                break;
            default:
                return res.json({ trust_score: currentScore, message: 'No change' });
        }
        
        const newScore = Math.min(currentScore + increment, 100);
        await promiseDb.query('UPDATE users SET trust_score = ? WHERE id = ?', [newScore, userId]);
        
        res.json({ trust_score: newScore, increment, message });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users/:id/trust-details', async (req, res) => {
    try {
        const [user] = await promiseDb.query('SELECT trust_score, total_transactions, successful_transactions, is_verified FROM users WHERE id = ?', [req.params.id]);
        
        const userData = user[0];
        let factors = [];
        
        if (userData.total_transactions > 0) {
            const successRate = (userData.successful_transactions / userData.total_transactions) * 100;
            factors.push({
                name: 'Transaction Success Rate',
                value: Math.floor(successRate),
                max: 100,
                contribution: Math.floor(successRate * 0.3)
            });
        }
        
        if (userData.is_verified) {
            factors.push({
                name: 'Account Verification',
                value: 100,
                max: 100,
                contribution: 25
            });
        }
        
        if (userData.total_transactions >= 10) {
            factors.push({
                name: 'Experienced Trader (10+ transactions)',
                value: 100,
                max: 100,
                contribution: 15
            });
        } else if (userData.total_transactions >= 5) {
            factors.push({
                name: 'Active Trader (5+ transactions)',
                value: 100,
                max: 100,
                contribution: 10
            });
        }
        
        res.json({
            trust_score: userData.trust_score,
            factors: factors,
            total_transactions: userData.total_transactions,
            successful_transactions: userData.successful_transactions
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/ratings', async (req, res) => {
    const { transaction_id, reviewer_id, reviewee_id, rating, comment } = req.body;
    
    if (!transaction_id || !reviewer_id || !reviewee_id || !rating) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    
    if (rating < 1 || rating > 5) {
        return res.status(400).json({ error: 'Rating must be between 1 and 5' });
    }
    
    try {
        const [existing] = await promiseDb.query('SELECT id FROM reviews WHERE transaction_id = ? AND reviewer_id = ?', [transaction_id, reviewer_id]);
        if (existing.length > 0) {
            return res.status(400).json({ error: 'You have already reviewed this transaction' });
        }
        
        await promiseDb.query(
            'INSERT INTO reviews (transaction_id, reviewer_id, reviewee_id, rating, comment) VALUES (?, ?, ?, ?, ?)',
            [transaction_id, reviewer_id, reviewee_id, rating, comment]
        );
        
        let action = '';
        if (rating === 5) action = 'received_5star';
        else if (rating === 4) action = 'received_4star';
        
        if (action) {
            const [user] = await promiseDb.query('SELECT trust_score FROM users WHERE id = ?', [reviewee_id]);
            let currentScore = user[0]?.trust_score || 0;
            let increment = rating === 5 ? 10 : 5;
            const newScore = Math.min(currentScore + increment, 100);
            await promiseDb.query('UPDATE users SET trust_score = ? WHERE id = ?', [newScore, reviewee_id]);
        }
        
        res.json({ message: 'Review submitted! Trust score updated.' });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users/:id/reviews', async (req, res) => {
    try {
        const [rows] = await promiseDb.query(
            `SELECT r.*, u.username as reviewer_name 
             FROM reviews r 
             JOIN users u ON r.reviewer_id = u.id 
             WHERE r.reviewee_id = ? 
             ORDER BY r.created_at DESC`,
            [req.params.id]
        );
        res.json(rows);
    } catch (error) {
        res.json([]);
    }
});

// ============ PAYMENT ROUTES ============

app.post('/api/record-payment', async (req, res) => {
    const { user_id, amount, payment_type, transaction_id, card_number, card_holder_name } = req.body;
    
    try {
        const [userRows] = await promiseDb.query('SELECT username FROM users WHERE id = ?', [user_id]);
        
        if (userRows.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const username = userRows[0].username;
        const cardNumberClean = card_number.replace(/\s/g, '');
        const last4 = cardNumberClean.slice(-4);
        
        let cardType = 'Unknown';
        if (cardNumberClean.startsWith('4')) cardType = 'Visa';
        else if (cardNumberClean.startsWith('5')) cardType = 'Mastercard';
        else if (cardNumberClean.startsWith('3')) cardType = 'Amex';
        else if (cardNumberClean.startsWith('6')) cardType = 'Discover';
        
        await promiseDb.query(
            `INSERT INTO payments (user_id, username, amount, payment_type, transaction_id, card_number_last4, card_type, card_holder_name, payment_status)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'success')`,
            [user_id, username, amount, payment_type, transaction_id || null, last4, cardType, card_holder_name]
        );
        
        res.json({ success: true, message: 'Payment recorded successfully' });
        
    } catch (error) {
        console.error('Payment recording error:', error);
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/users/:id/payments', async (req, res) => {
    try {
        const [rows] = await promiseDb.query(
            `SELECT id, amount, payment_type, transaction_id, card_number_last4, card_type, card_holder_name, payment_status, created_at
             FROM payments
             WHERE user_id = ?
             ORDER BY created_at DESC`,
            [req.params.id]
        );
        res.json(rows);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
    console.log(`💡 Demo login: gamer_alex / demo123`);
    console.log(`💡 Or register a new account`);
});