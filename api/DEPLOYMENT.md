# 🚀 Deployment Guide - Kilwinning API to Netsons

This guide explains how to deploy the Kilwinning PHP REST API to your Netsons hosting.

## 📋 Prerequisites

Before deploying, ensure you have:

- ✅ Netsons hosting account with PHP 8+ support
- ✅ MySQL database `jmvvznbb_tornate_db` already created
- ✅ Database user `jmvvznbb_tornate_user` with password `Puntorosso22`
- ✅ Database tables already created (see Database Schema below)
- ✅ FTP/SFTP access to your hosting account
- ✅ SSL certificate configured (recommended for HTTPS)

## 📦 Deployment Steps

### Step 1: Upload Files

1. Connect to your Netsons hosting via FTP/SFTP
2. Navigate to your web root directory (usually `public_html` or `www`)
3. Create an `api` directory if it doesn't exist
4. Upload ALL files from the local `/api/` directory:
   - `config.php`
   - `audio_discussioni.php`
   - `libri.php`
   - `prestiti.php`
   - `chat.php`
   - `notifiche.php`
   - `index.php`
   - `.htaccess`
   - `README.md`

### Step 2: Set File Permissions

Set proper permissions for security:

```bash
# Via SSH (if available)
chmod 644 /path/to/api/*.php
chmod 644 /path/to/api/.htaccess
```

Or via FTP client:
- PHP files: 644 (rw-r--r--)
- .htaccess: 644 (rw-r--r--)

### Step 3: Verify Database Connection

1. Open your browser and navigate to:
   ```
   https://yourdomain.com/api/index.php
   ```

2. You should see a JSON response with:
   ```json
   {
     "success": true,
     "api_name": "Kilwinning - Sistema Gestione Tornate API",
     "version": "1.0.0",
     "status": "operational",
     "database": {
       "status": "connected",
       ...
     }
   }
   ```

3. If you see an error, check:
   - Database credentials in `config.php`
   - Database server is accessible
   - PHP PDO extension is enabled

### Step 4: Test Endpoints

Test each endpoint to ensure they work:

**Test 1: Get all books**
```bash
curl https://yourdomain.com/api/libri.php
```

**Test 2: Get chat rooms**
```bash
curl https://yourdomain.com/api/chat.php?rooms=1
```

**Test 3: Health check**
```bash
curl https://yourdomain.com/api/index.php
```

### Step 5: Configure SSL/HTTPS (Recommended)

1. In Netsons control panel, enable SSL certificate
2. Force HTTPS by adding to `.htaccess`:
   ```apache
   RewriteEngine On
   RewriteCond %{HTTPS} off
   RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
   ```

## 🗄️ Database Schema

Your MySQL database should have these tables. If not, create them:

### Table: `audio_discussioni`
```sql
CREATE TABLE `audio_discussioni` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_tornata` int(11) NOT NULL,
  `fratello_intervento` varchar(255) DEFAULT NULL,
  `titolo_intervento` varchar(255) NOT NULL,
  `durata` varchar(20) DEFAULT NULL,
  `audio_url` text DEFAULT NULL,
  `data_upload` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `id_tornata` (`id_tornata`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `libri`
```sql
CREATE TABLE `libri` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `titolo` varchar(255) NOT NULL,
  `autore` varchar(255) DEFAULT NULL,
  `anno` int(11) DEFAULT NULL,
  `categoria` varchar(100) DEFAULT NULL,
  `codice_archivio` varchar(50) DEFAULT NULL,
  `stato` enum('Disponibile','In prestito','Non disponibile') DEFAULT 'Disponibile',
  `copertina_url` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `prestiti`
```sql
CREATE TABLE `prestiti` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_libro` int(11) NOT NULL,
  `id_fratello` int(11) NOT NULL,
  `data_prestito` datetime DEFAULT CURRENT_TIMESTAMP,
  `data_restituzione` datetime DEFAULT NULL,
  `data_scadenza` date DEFAULT NULL,
  `stato_prestito` enum('Attivo','Restituito','Scaduto') DEFAULT 'Attivo',
  PRIMARY KEY (`id`),
  KEY `id_libro` (`id_libro`),
  KEY `id_fratello` (`id_fratello`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `chat_rooms`
```sql
CREATE TABLE `chat_rooms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome_chat` varchar(255) NOT NULL,
  `descrizione` text DEFAULT NULL,
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `chat_messages`
```sql
CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_chat` int(11) NOT NULL,
  `id_mittente` int(11) NOT NULL,
  `testo` text NOT NULL,
  `data_invio` datetime DEFAULT CURRENT_TIMESTAMP,
  `letto` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `id_chat` (`id_chat`),
  KEY `id_mittente` (`id_mittente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `notifiche`
```sql
CREATE TABLE `notifiche` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_fratello` int(11) NOT NULL,
  `tipo` enum('tornata','audio','tavola','libro','chat','sistema') NOT NULL,
  `titolo` varchar(255) NOT NULL,
  `messaggio` text DEFAULT NULL,
  `data_creazione` datetime DEFAULT CURRENT_TIMESTAMP,
  `letta` tinyint(1) DEFAULT 0,
  `id_riferimento` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id_fratello` (`id_fratello`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `utenti`
```sql
CREATE TABLE `utenti` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `cognome` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL UNIQUE,
  `password` varchar(255) NOT NULL,
  `grado` varchar(50) DEFAULT NULL,
  `ruolo` enum('Fratello','Segretario','Maestro Venerabile','Amministratore') DEFAULT 'Fratello',
  `data_iniziazione` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Table: `tornate`
```sql
CREATE TABLE `tornate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_tornata` date NOT NULL,
  `ora_tornata` time DEFAULT NULL,
  `tipo` enum('Ordinaria','Straordinaria','Cerimonia') DEFAULT 'Ordinaria',
  `luogo` varchar(255) DEFAULT NULL,
  `ordine_del_giorno` text DEFAULT NULL,
  `stato` enum('Programmata','Completata','Annullata') DEFAULT 'Programmata',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## 🔧 Troubleshooting

### Error: "Database connection failed"

**Solution:**
1. Verify database credentials in `config.php`
2. Check if database server allows remote connections
3. Ensure database user has proper permissions
4. Try connecting to database using phpMyAdmin

### Error: "500 Internal Server Error"

**Solution:**
1. Check PHP error logs in Netsons control panel
2. Ensure PHP version is 8.0 or higher
3. Verify PDO extension is enabled
4. Check file permissions (should be 644)

### Error: "CORS policy blocked"

**Solution:**
1. Ensure `.htaccess` is uploaded
2. Verify Apache `mod_headers` is enabled
3. Check CORS headers in `config.php`

### Error: "Table doesn't exist"

**Solution:**
1. Run the SQL CREATE TABLE statements above
2. Verify table names match exactly
3. Ensure charset is utf8mb4

## 🧪 Testing Checklist

After deployment, verify:

- [ ] Health check endpoint works (`/api/index.php`)
- [ ] Database connection successful
- [ ] All tables exist and are accessible
- [ ] GET endpoints return data
- [ ] POST endpoints create data
- [ ] DELETE endpoints remove data
- [ ] Error responses return proper JSON
- [ ] CORS headers allow SwiftUI app access
- [ ] HTTPS/SSL is working

## 🔐 Security Recommendations

### Priority 1: Protect Database Credentials

**Current Setup:** Database credentials are hardcoded in `config.php`

**Recommended Improvements:**

1. **Use Environment Variables** (Best Practice):
   - Create a `.env` file (outside web root if possible)
   - Use a library like `vlucas/phpdotenv` or PHP's `getenv()`
   - Add `.env` to `.gitignore`
   
   Example:
   ```php
   // In config.php
   $host = getenv('DB_HOST') ?: 'localhost';
   $db_name = getenv('DB_NAME') ?: 'jmvvznbb_tornate_db';
   $username = getenv('DB_USERNAME');
   $password = getenv('DB_PASSWORD');
   ```

2. **Move Config Outside Web Root**:
   - Place `config.php` one level above `public_html`
   - Update include paths: `require '../config.php';`

3. **File Permissions**:
   - Set `config.php` to 640 or 600
   - Only allow web server user to read it

### Priority 2: Restrict CORS Origins

**Current Setup:** CORS allows all origins (`Access-Control-Allow-Origin: *`)

**Recommended for Production:**

```php
// In config.php, replace * with specific domain
$allowed_origins = [
    'https://yourdomain.com',
    'https://app.yourdomain.com'
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origin, $allowed_origins)) {
    header("Access-Control-Allow-Origin: $origin");
}
```

### Priority 3: Add Authentication

Consider implementing JWT (JSON Web Tokens) or OAuth:

1. Add authentication middleware
2. Require tokens for all non-public endpoints
3. Validate user permissions before database operations

### Additional Security Measures

1. **Use HTTPS**: Always use SSL/HTTPS in production
2. **Restrict Database Access**: Use firewall rules to limit database connections
3. **Regular Backups**: Set up automated database backups
4. **Monitor Logs**: Regularly check error and access logs
5. **Update PHP**: Keep PHP version updated for security patches
6. **Input Validation**: Already implemented via PDO prepared statements
7. **Rate Limiting**: Consider adding rate limiting to prevent abuse
8. **Error Messages**: In production, disable detailed error messages

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Netsons hosting documentation
3. Verify database schema matches requirements
4. Contact the development team

---

**Good luck with your deployment! 🏛️**
