# Kilwinning - REST API Backend

Complete PHP REST API for the Kilwinning Sistema Gestione Tornate.

## 🔐 Database Connection

The API connects to the MySQL database `jmvvznbb_tornate_db` hosted on Netsons using credentials defined in `config.php`.

**Database Credentials:**
- Host: `localhost`
- Database: `jmvvznbb_tornate_db`
- Username: `jmvvznbb_tornate_user`
- Password: `Puntorosso22`

## 📁 File Structure

```
/api/
├── config.php              # Database configuration and CORS headers
├── audio_discussioni.php   # Audio discussions management
├── libri.php              # Library catalog management
├── prestiti.php           # Library loan management
├── chat.php               # Internal messaging system
└── notifiche.php          # In-app notifications
```

## 🔌 API Endpoints

### 1. Audio Discussions (`audio_discussioni.php`)

Handles audio discussions linked to tornate.

**GET** `/api/audio_discussioni.php?id_tornata=XX`
- Get all audio discussions for a specific tornata
- Returns: Array of audio discussion objects

**GET** `/api/audio_discussioni.php`
- Get all audio discussions
- Returns: Array of all audio discussion objects

**POST** `/api/audio_discussioni.php`
- Create new audio discussion
- Body (JSON):
  ```json
  {
    "id_tornata": 1,
    "fratello_intervento": "Nome Fratello",
    "titolo_intervento": "Titolo della discussione",
    "durata": "15:30",
    "audio_url": "https://pcloud.com/..."
  }
  ```

**DELETE** `/api/audio_discussioni.php?id=XX`
- Delete audio discussion by ID

---

### 2. Library Catalog (`libri.php`)

Manages the library catalog with search and filtering.

**GET** `/api/libri.php`
- Get all books
- Optional query parameters:
  - `categoria`: Filter by category
  - `stato`: Filter by availability status
  - `search`: Search in title or author
- Returns: Array of book objects

**GET** `/api/libri.php?id=XX`
- Get specific book by ID
- Returns: Single book object

**POST** `/api/libri.php`
- Create or update book
- Body (JSON):
  ```json
  {
    "id": 1,  // Optional, for update
    "titolo": "Book Title",
    "autore": "Author Name",
    "anno": 2024,
    "categoria": "Filosofia",
    "codice_archivio": "FIL-001",
    "stato": "Disponibile",
    "copertina_url": "https://..."
  }
  ```

**DELETE** `/api/libri.php?id=XX`
- Delete book by ID
- Note: Cannot delete books currently on loan

---

### 3. Library Loans (`prestiti.php`)

Manages library loans and automatically updates book availability.

**GET** `/api/prestiti.php?id_fratello=XX`
- Get all loans for a specific member
- Returns: Array of loan objects with book details

**GET** `/api/prestiti.php`
- Get all active loans
- Returns: Array of active loan objects

**POST** `/api/prestiti.php`
- Create new loan
- Body (JSON):
  ```json
  {
    "id_libro": 1,
    "id_fratello": 5,
    "giorni_prestito": 30  // Optional, default 30 days
  }
  ```
- Automatically sets book status to "In prestito"

**POST** `/api/prestiti.php` (Close loan)
- Close existing loan
- Body (JSON):
  ```json
  {
    "id": 1,
    "close_loan": true
  }
  ```
- Automatically sets book status to "Disponibile"

---

### 4. Chat System (`chat.php`)

Internal messaging system with chat rooms and messages.

**GET** `/api/chat.php?rooms=1`
- Get all chat rooms with message counts
- Returns: Array of chat room objects

**GET** `/api/chat.php?id_chat=XX`
- Get all messages for specific chat room
- Returns: Array of message objects with sender info

**POST** `/api/chat.php` (Create room)
- Create new chat room
- Body (JSON):
  ```json
  {
    "create_room": true,
    "nome_chat": "Room Name",
    "descrizione": "Room description"
  }
  ```

**POST** `/api/chat.php` (Send message)
- Send new message
- Body (JSON):
  ```json
  {
    "id_chat": 1,
    "id_mittente": 5,
    "testo": "Message text"
  }
  ```

**PUT** `/api/chat.php`
- Mark message as read
- Body (JSON):
  ```json
  {
    "id": 1
  }
  ```

---

### 5. Notifications (`notifiche.php`)

In-app notifications for tornate, audio, tavole, libri, and chat.

**GET** `/api/notifiche.php?id_fratello=XX`
- Get all notifications for a member
- Optional query parameters:
  - `letta`: Filter by read status (0 or 1)
  - `tipo`: Filter by notification type
  - `limit`: Limit number of results
- Returns: Array of notifications with unread count

**POST** `/api/notifiche.php`
- Create new notification
- Body (JSON):
  ```json
  {
    "id_fratello": 5,
    "tipo": "tornata",  // tornata, audio, tavola, libro, chat, sistema
    "titolo": "Notification Title",
    "messaggio": "Notification message",
    "id_riferimento": 1  // Optional reference ID
  }
  ```

**POST** `/api/notifiche.php?mark_read=XX`
- Mark notification as read

**POST** `/api/notifiche.php?mark_all_read=1`
- Mark all notifications as read for a user
- Body (JSON):
  ```json
  {
    "id_fratello": 5
  }
  ```

**DELETE** `/api/notifiche.php?id=XX`
- Delete notification by ID

---

## 🔒 Security Features

- **PDO Prepared Statements**: All queries use prepared statements to prevent SQL injection
- **Parameter Binding**: All user inputs are properly sanitized using PDO parameter binding
- **Error Handling**: Comprehensive exception handling with JSON error responses
- **CORS Headers**: Configured for cross-origin requests from SwiftUI app
- **UTF-8 Encoding**: All responses use UTF-8 charset

## ✅ Response Format

All endpoints return JSON responses with consistent format:

**Success Response:**
```json
{
  "success": true,
  "data": [...],
  "message": "Operation completed successfully"
}
```

**Error Response:**
```json
{
  "error": "Error description",
  "details": "Additional error details"
}
```

## 🌐 CORS Configuration

The API is configured to accept requests from any origin with the following headers:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Content-Type, Authorization`

## 📝 Database Tables

The API works with the following database tables:
- `tornate`: Lodge meetings
- `utenti`: Members/users
- `audio_discussioni`: Audio recordings of discussions
- `libri`: Library catalog
- `prestiti`: Library loans
- `chat_rooms`: Chat rooms
- `chat_messages`: Chat messages
- `notifiche`: Notifications

## 🚀 Deployment

To deploy on Netsons hosting:

1. Upload all files from `/api/` directory to your web hosting
2. Ensure the database credentials in `config.php` are correct
3. Set proper file permissions (644 for PHP files)
4. Test endpoints using a REST client or the SwiftUI app

## 🧪 Testing

You can test the API endpoints using:
- cURL
- Postman
- SwiftUI app (async/await compatible)
- Any REST client

Example cURL request:
```bash
curl -X GET "https://yourdomain.com/api/libri.php"
```

## 📞 Support

For issues or questions about the API, please contact the development team.

---

**Version:** 1.0.0  
**Last Updated:** November 2025  
**Developed for:** Spettabile Loggia Kilwinning 🏛️
