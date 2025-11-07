# 🔐 Istruzioni di Sicurezza - Configurazione Database

## ⚠️ IMPORTANTE - Azione Immediata Richiesta

### Problema Critico Risolto
Le credenziali del database erano precedentemente hardcoded nel file `api/config.php` e sono state **esposte nel repository pubblico**. Questo rappresentava un rischio di sicurezza critico.

### ✅ Soluzione Implementata
Le credenziali sono state migrate a variabili d'ambiente. Ora è necessario completare la configurazione.

---

## 📋 Passi da Completare

### 1. **URGENTE: Cambiare Password Database** (Priorità Massima)
```bash
# Accedi al tuo pannello di hosting (Netsons)
# Vai a: Database → Gestione Utenti → jmvvznbb_tornate_user
# Cambia la password con una nuova password sicura
# Esempio: generare una password casuale di 20+ caratteri
```

**Password attuale compromessa**: `Puntorosso22`  
**Nuova password**: `[GENERA UNA PASSWORD SICURA]`

Usa un generatore di password come:
- https://passwordsgenerator.net/
- `openssl rand -base64 24` (da terminale)

---

### 2. **Creare File .env**
```bash
cd /percorso/al/progetto/api
cp .env.example .env
nano .env  # o usa il tuo editor preferito
```

---

### 3. **Configurare .env con Credenziali Aggiornate**
Modifica il file `.env` appena creato:

```env
# Database Configuration
DB_HOST=localhost
DB_NAME=jmvvznbb_tornate_db
DB_USERNAME=jmvvznbb_tornate_user
DB_PASSWORD=LA_TUA_NUOVA_PASSWORD_SICURA

# CORS Configuration (opzionale - per produzione)
ALLOWED_ORIGINS=https://tuodominio.com

# API Configuration
API_VERSION=1.0.0
DEBUG_MODE=false
```

---

### 4. **Verificare .gitignore**
Assicurati che `.env` sia nel `.gitignore` (✅ già configurato):

```bash
cat .gitignore | grep .env
# Output atteso: .env
```

---

### 5. **Test di Connessione**
Dopo aver configurato `.env`, testa la connessione:

```bash
curl https://tuodominio.com/api/index.php
```

Dovresti vedere:
```json
{
  "success": true,
  "database": {
    "status": "connected"
  }
}
```

---

## 🔒 Best Practices Implementate

### ✅ Cosa è stato fatto:
1. **Rimosso password hardcoded** dal file `config.php`
2. **Creato sistema di environment variables** con `load_env.php`
3. **Aggiunto .env.example** come template
4. **Aggiunto .gitignore** per proteggere `.env`
5. **Logging di warning** se password non configurata

### ✅ Sicurezza Migliorata:
- ❌ **PRIMA**: `$password = "Puntorosso22";` (esposto)
- ✅ **ORA**: `$password = getenv('DB_PASSWORD');` (protetto)

---

## 📝 File Modificati

### `api/config.php`
```php
// PRIMA (INSICURO)
$password = "Puntorosso22";

// ORA (SICURO)
require_once __DIR__ . '/load_env.php';
$password = getenv('DB_PASSWORD') ?: '';
```

### Nuovi File Creati:
- ✅ `api/load_env.php` - Carica variabili da .env
- ✅ `api/.env.example` - Template per configurazione
- ✅ `.gitignore` - Protegge file sensibili

---

## ⚙️ Deployment su Hosting (Netsons)

### Opzione A: File .env sul Server
```bash
# 1. Connettiti via FTP/SSH al server
# 2. Naviga alla cartella api/
# 3. Crea il file .env:
echo "DB_HOST=localhost" > .env
echo "DB_NAME=jmvvznbb_tornate_db" >> .env
echo "DB_USERNAME=jmvvznbb_tornate_user" >> .env
echo "DB_PASSWORD=nuova_password_sicura" >> .env

# 4. Proteggi il file
chmod 600 .env
```

### Opzione B: Variabili d'Ambiente del Server
Se Netsons supporta variabili d'ambiente:
```bash
# Nel pannello di controllo hosting, aggiungi:
DB_HOST=localhost
DB_NAME=jmvvznbb_tornate_db
DB_USERNAME=jmvvznbb_tornate_user
DB_PASSWORD=nuova_password_sicura
```

---

## 🧪 Testing

### Test Locale (con .env):
```bash
cd api
php -r "require 'load_env.php'; echo getenv('DB_PASSWORD');"
# Output: dovrebbe mostrare la password dal .env
```

### Test API:
```bash
# Test endpoint di health check
curl -X GET http://localhost/api/index.php

# Dovrebbe restituire JSON con status: "connected"
```

---

## 🚨 Checklist di Sicurezza

- [ ] Password database cambiata su hosting
- [ ] File `.env` creato in locale
- [ ] File `.env` creato sul server di produzione
- [ ] `.env` non committato in Git (verificato con `git status`)
- [ ] Test di connessione API superato
- [ ] Backup della nuova password in un password manager
- [ ] Documentazione password condivisa solo con amministratori autorizzati
- [ ] Vecchia password `Puntorosso22` non più valida

---

## 📞 Supporto

In caso di problemi:
1. Verifica che `load_env.php` esista in `api/`
2. Controlla i permessi del file `.env` (deve essere leggibile da PHP)
3. Verifica i log del server: `tail -f /var/log/apache2/error.log`
4. Controlla che la password sia corretta nel pannello hosting

---

## 🎯 Prossimi Passi

Dopo aver completato questa configurazione:
1. ✅ Sicurezza database: **RISOLTO**
2. Prossimo: Implementare autenticazione JWT per le API
3. Prossimo: Aggiungere rate limiting
4. Prossimo: Configurare HTTPS obbligatorio

---

**Ultima Modifica**: 7 Novembre 2025  
**Stato**: ⚠️ AZIONE RICHIESTA - Cambiare password e configurare .env  
**Priorità**: 🔴 CRITICA - Da completare entro 24 ore
