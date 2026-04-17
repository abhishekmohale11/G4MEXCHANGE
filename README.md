# 🎮 G4MEXCHANGE - Gaming Marketplace Platform

[![Node.js](https://img.shields.io/badge/Node.js-18.x-green.svg)](https://nodejs.org/)
[![Express.js](https://img.shields.io/badge/Express.js-4.x-blue.svg)](https://expressjs.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.x-orange.svg)](https://mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📌 Overview

G4MEXCHANGE is a comprehensive online marketplace platform specifically designed for gamers to **buy, sell, and rent** gaming-related items. It bridges the gap between gaming enthusiasts who want to trade their pre-owned gaming equipment.

### ✨ Key Features

- 🔐 **User Authentication** - Secure login/register with JWT
- 👥 **Role-Based Access** - Buyer and Seller modes
- 🎯 **Item Management** - List, browse, filter gaming items
- 💰 **Wallet System** - Add money and make digital payments
- 🛒 **Buy & Rent** - Purchase items or rent games for short periods
- ⭐ **Rating System** - Rate sellers after transactions
- 📊 **Trust Score** - Dynamic credibility system (0-100)
- 📈 **Analytics Dashboard** - Spending charts and insights
- 📱 **Responsive Design** - Works on all devices

---

## 🚀 Live Demo

**Demo Credentials:**
- Username: `gamer_alex`
- Password: `demo123`

---

## 🛠️ Technologies Used

### Frontend
| Technology | Purpose |
|------------|---------|
| HTML5 | Page structure |
| CSS3 | Styling & animations |
| JavaScript | Frontend logic |
| Chart.js | Analytics charts |
| Font Awesome | Icons |

### Backend
| Technology | Purpose |
|------------|---------|
| Node.js | JavaScript runtime |
| Express.js | Web framework |
| JWT | Authentication |
| bcryptjs | Password hashing |

### Database
| Technology | Purpose |
|------------|---------|
| MySQL | Relational database |
| MySQL2 | Database driver |

---

## 📊 Database Schema

| Table | Description |
|-------|-------------|
| users | User accounts & trust scores |
| items | Gaming product listings |
| transactions | Buy/rent records |
| reviews | Ratings & feedback |
| payments | Payment history |

### Sample Data
- **5 Demo Users** (Buyers & Sellers)
- **65+ Gaming Items** (PS5, Xbox, Nintendo, PC)
- **7 Transactions** (Completed, Pending, Returned)
- **6 Reviews** (4-5 star ratings)

---

## 🔧 Installation & Setup

### Prerequisites

- Node.js (v14 or higher)
- MySQL Server (XAMPP/WAMP/MAMP)
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusabhishekmohale11/g4mexchange.git
cd g4mexchange
