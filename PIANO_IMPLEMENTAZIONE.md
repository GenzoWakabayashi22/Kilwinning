# 📋 Piano di Implementazione - Raccomandazioni Analisi Kilwinning

**Basato su**: ANALISI_PROGETTO.md  
**Data**: 7 Novembre 2025  
**Versione**: 1.0

---

## ✅ Completato - Fase 1 (Critici)

### 1. ✅ .gitignore Aggiunto
- **File**: `.gitignore` root del progetto
- **Contenuto**: Esclude `.build/`, `.swiftpm/`, `node_modules/`, `.env`
- **Status**: ✅ Completato

### 2. ✅ Credenziali Database Migrate
- **File**: `api/config.php`
- **Modifica**: Usa `getenv('DB_PASSWORD')` invece di hardcoded
- **Nuovi File**: `api/load_env.php` per caricare `.env`
- **Status**: ✅ Completato
- **Azione Richiesta**: Vedere `SECURITY_SETUP.md` per configurazione finale

### 3. ✅ Componenti Duplicati Risolti
- **Nuovo File**: `KilwinningApp/Sources/KilwinningApp/Utilities/CommonViews.swift`
- **Componenti Estratti**:
  - `InfoRow` - Unificato con parametri opzionali
  - `EmptyStateView` - Unificato con parametri personalizzabili
  - `ActionButton` - Generico (ex PresenceButton in ProssimeTornateSection)
  - `PresenceButton` - Specifico per status di presenza
- **Files Aggiornati**:
  - `Views/InformazioniLoggiaSection.swift`
  - `Views/BibliotecaView.swift`
  - `Views/ProssimeTornateSection.swift`
  - `Views/TornataDetailView.swift`
- **Status**: ✅ Completato

---

## 📋 TODO - Fase 2 (Importanti) - Settimana 1

### 4. 📦 Installare Dipendenze Backend Node.js
**Priorità**: 🟡 Alta  
**Tempo Stimato**: 5 minuti  
**Gravità**: Sistema notifiche non funzionante

**Passi**:
```bash
cd backend
npm install
```

**Verifica**:
```bash
npm list
# Dovrebbe mostrare tutte le dipendenze installate senza errori
```

**Risultato Atteso**:
- ✅ `node_modules/` creato
- ✅ Tutte le dipendenze installate
- ✅ `npm start` funzionante

---

### 5. 🌐 Creare Endpoint API: tornate.php
**Priorità**: 🟡 Alta  
**Tempo Stimato**: 3 ore  
**Gravità**: Funzionalità core mancante

**File da Creare**: `api/tornate.php`

**Operazioni da Supportare**:
```php
GET  /api/tornate.php              // Lista tutte le tornate
GET  /api/tornate.php?id=XX        // Dettaglio tornata
GET  /api/tornate.php?anno=2025    // Filtra per anno
POST /api/tornate.php              // Crea nuova tornata
PUT  /api/tornate.php?id=XX        // Modifica tornata
DELETE /api/tornate.php?id=XX      // Elimina tornata
```

**Schema Database Richiesto**:
```sql
CREATE TABLE IF NOT EXISTS tornate (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    date DATETIME NOT NULL,
    type ENUM('ordinaria', 'straordinaria', 'cerimonia') NOT NULL,
    location VARCHAR(100) NOT NULL,
    introduced_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_date (date),
    INDEX idx_type (type)
);
```

**Template Implementazione**:
```php
<?php
require 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

try {
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get single tornata
                $stmt = $pdo->prepare("SELECT * FROM tornate WHERE id = ?");
                $stmt->execute([$_GET['id']]);
                $result = $stmt->fetch();
            } elseif (isset($_GET['anno'])) {
                // Filter by year
                $stmt = $pdo->prepare("SELECT * FROM tornate WHERE YEAR(date) = ? ORDER BY date DESC");
                $stmt->execute([$_GET['anno']]);
                $result = $stmt->fetchAll();
            } else {
                // Get all tornate
                $stmt = $pdo->query("SELECT * FROM tornate ORDER BY date DESC");
                $result = $stmt->fetchAll();
            }
            echo json_encode(['success' => true, 'data' => $result]);
            break;
            
        case 'POST':
            // Create tornata
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("INSERT INTO tornate (title, date, type, location, introduced_by) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['title'],
                $data['date'],
                $data['type'],
                $data['location'],
                $data['introduced_by'] ?? null
            ]);
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
            break;
            
        // ... PUT e DELETE
    }
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
?>
```

---

### 6. 🌐 Creare Endpoint API: presenze.php
**Priorità**: 🟡 Alta  
**Tempo Stimato**: 2 ore  
**Gravità**: Funzionalità core mancante

**File da Creare**: `api/presenze.php`

**Schema Database**:
```sql
CREATE TABLE IF NOT EXISTS presenze (
    id INT PRIMARY KEY AUTO_INCREMENT,
    id_fratello INT NOT NULL,
    id_tornata INT NOT NULL,
    status ENUM('presente', 'assente', 'nonConfermato') DEFAULT 'nonConfermato',
    confirmed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_tornata) REFERENCES tornate(id) ON DELETE CASCADE,
    UNIQUE KEY unique_presence (id_fratello, id_tornata),
    INDEX idx_fratello (id_fratello),
    INDEX idx_tornata (id_tornata)
);
```

---

### 7. 🔌 Implementare Chiamate HTTP nei Services Swift
**Priorità**: 🟡 Alta  
**Tempo Stimato**: 4 ore  
**Gravità**: App non funzionante in produzione

**Files da Modificare**:
- `Services/DataService.swift`
- `Services/AuthenticationService.swift`
- `Services/LibraryService.swift`
- `Services/ChatService.swift`
- `Services/AudioService.swift`
- `Services/NotificationService.swift`

**Esempio - DataService.swift**:
```swift
func fetchTornate() async throws -> [Tornata] {
    let url = URL(string: "https://api.kilwinning.it/tornate.php")!
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.invalidResponse
    }
    
    let apiResponse = try JSONDecoder().decode(APIResponse<[Tornata]>.self, from: data)
    
    if apiResponse.success {
        return apiResponse.data
    } else {
        throw NetworkError.serverError(apiResponse.error ?? "Unknown error")
    }
}
```

**Creare NetworkError enum**:
```swift
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URL non valido"
        case .invalidResponse: return "Risposta server non valida"
        case .serverError(let msg): return msg
        case .decodingError: return "Errore decodifica dati"
        }
    }
}
```

---

## 📋 TODO - Fase 3 (Architettura) - Settimana 2

### 8. 🏗️ Decidere Strategia Backend
**Priorità**: 🟡 Media  
**Tempo Stimato**: 1 ora (decisione) + implementazione

**Opzioni**:

**A. Usare Solo PHP** (✅ Consigliato):
- Pro: Backend già completo, solo mancano 2 endpoint
- Pro: Meno complessità architetturale
- Pro: Un solo stack da mantenere
- Azione: Rimuovere cartella `backend/`

**B. Specializzare Node.js**:
- Pro: Separazione responsabilità
- Uso: PHP = REST API, Node.js = WebSocket/Notifiche Real-time
- Azione: Implementare Socket.io per push notifications

**C. Migrare Tutto a Node.js**:
- Pro: Stack unificato JavaScript
- Contro: Riscrivere 6 endpoint già funzionanti
- Tempo: ~2 settimane
- Non consigliato al momento

**Raccomandazione**: **Opzione A** - Usare solo PHP

---

### 9. 🏗️ Creare NetworkService Centralizzato
**Priorità**: 🟢 Media  
**Tempo Stimato**: 2 ore

**File da Creare**: `Services/NetworkService.swift`

```swift
import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://api.kilwinning.it"
    private var authToken: String?
    
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .get,
        body: Encodable? = nil,
        requiresAuth: Bool = false
    ) async throws -> T {
        var urlComponents = URLComponents(string: baseURL + endpoint)!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(T.self, from: data)
    }
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
```

---

### 10. 🏗️ Ristrutturare Cartelle Views
**Priorità**: 🟢 Bassa  
**Tempo Stimato**: 1 ora (refactoring)

**Struttura Corrente**:
```
Views/
├── LoginView.swift
├── RegistrationView.swift
├── DashboardView.swift
├── TornateListView.swift
... (15 files in flat structure)
```

**Struttura Proposta**:
```
Views/
├── Authentication/
│   ├── LoginView.swift
│   ├── RegistrationView.swift
│   └── PasswordResetView.swift
├── Dashboard/
│   ├── DashboardView.swift
│   ├── HomeContentView.swift
│   └── InformazioniLoggiaSection.swift
├── Tornate/
│   ├── TornateListView.swift
│   ├── TornataDetailView.swift
│   ├── PresenzeView.swift
│   └── ProssimeTornateSection.swift
├── Library/
│   ├── BibliotecaView.swift
│   └── MieiPrestitiView.swift
├── Tavole/
│   └── TavoleView.swift
├── Chat/
│   └── ChatView.swift
├── Notifications/
│   └── NotificheView.swift
├── Admin/
│   └── AdministrationView.swift
├── Audio/
│   └── AudioPlayerView.swift
└── Common/
    └── PDFViewerView.swift
```

**Passi**:
1. Creare sottocartelle in `Views/`
2. Spostare file nelle rispettive cartelle
3. Aggiornare import se necessario (Swift gestisce automaticamente)

---

### 11. 🧪 Aggiungere Test per Services
**Priorità**: 🟢 Media  
**Tempo Stimato**: 3 ore

**Files da Creare**:
- `Tests/KilwinningAppTests/AuthenticationServiceTests.swift`
- `Tests/KilwinningAppTests/DataServiceTests.swift`
- `Tests/KilwinningAppTests/NetworkServiceTests.swift`

**Esempio - AuthenticationServiceTests.swift**:
```swift
import XCTest
@testable import KilwinningApp

final class AuthenticationServiceTests: XCTestCase {
    var service: AuthenticationService!
    
    override func setUp() {
        super.setUp()
        service = AuthenticationService()
    }
    
    func testLoginSuccess() async throws {
        // TODO: Mock URLSession per test
        try await service.login(email: "test@test.com", password: "password")
        XCTAssertTrue(service.isAuthenticated)
        XCTAssertNotNil(service.currentUser)
    }
    
    func testLoginFailure() async {
        do {
            try await service.login(email: "wrong@test.com", password: "wrong")
            XCTFail("Login should fail with wrong credentials")
        } catch {
            XCTAssertFalse(service.isAuthenticated)
        }
    }
    
    func testLogout() {
        service.logout()
        XCTAssertFalse(service.isAuthenticated)
        XCTAssertNil(service.currentUser)
    }
}
```

---

## 📋 TODO - Fase 4 (Rifinitura) - Settimana 3

### 12. 📚 Completare Documentazione API
**File da Espandere**: `api/README.md`

**Sezioni da Aggiungere**:
```markdown
## Database Schema

### Tornate Table
| Campo | Tipo | Null | Default | Descrizione |
|-------|------|------|---------|-------------|
| id | INT | NO | AUTO | Primary Key |
...

## Authentication

Tutti gli endpoint (tranne login/register) richiedono header:
`Authorization: Bearer {token}`

## Rate Limiting

- Max 100 richieste/minuto per IP
- Max 1000 richieste/ora per utente autenticato

## Error Codes

| Code | Message | Descrizione |
|------|---------|-------------|
| 400 | Bad Request | Parametri mancanti/invalidi |
| 401 | Unauthorized | Token mancante/invalido |
...
```

---

### 13. 🔒 Implementare Sicurezza Aggiuntiva

**JWT Authentication**:
```php
// Creare api/auth.php per login/register
// Generare JWT token
// Validare token in ogni endpoint

require 'vendor/autoload.php';
use Firebase\JWT\JWT;

function generateToken($userId) {
    $key = getenv('JWT_SECRET');
    $payload = [
        'user_id' => $userId,
        'exp' => time() + (60 * 60 * 24) // 24 ore
    ];
    return JWT::encode($payload, $key, 'HS256');
}
```

**Rate Limiting**:
```php
// Tracking in Redis o database
function checkRateLimit($ip) {
    // Implementare logica rate limiting
}
```

---

## 📊 Metriche di Completamento

### Fase 1 - Critici
- [x] 100% Completato (3/3 task)

### Fase 2 - Importanti
- [ ] 0% Completato (0/4 task)
- Tempo Stimato: 12 ore (~2 giorni)

### Fase 3 - Architettura
- [ ] 0% Completato (0/4 task)
- Tempo Stimato: 8 ore (~1 giorno)

### Fase 4 - Rifinitura
- [ ] 0% Completato (0/2 task)
- Tempo Stimato: 4 ore

**Totale Tempo Rimanente**: ~24 ore (~3 giorni lavorativi)

---

## 🎯 Priorità Immediate (Prossime 48h)

1. **URGENTE**: Completare `SECURITY_SETUP.md` (cambiare password DB)
2. **ALTA**: Installare dipendenze Node.js (`npm install`)
3. **ALTA**: Creare `api/tornate.php`
4. **ALTA**: Creare `api/presenze.php`
5. **MEDIA**: Implementare chiamate HTTP in DataService

---

**Documento Creato**: 7 Novembre 2025  
**Prossimo Update**: Dopo completamento Fase 2  
**Responsabile Implementazione**: Team Kilwinning
