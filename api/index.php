<?php
/* ===== FILE: index.php ===== */
/**
 * Kilwinning API - Health Check & Information
 * 
 * This endpoint provides API status and available endpoints information.
 */

require 'config.php';

try {
    // Test database connection
    $dbStatus = "connected";
    $dbVersion = $pdo->query("SELECT VERSION()")->fetchColumn();
    
    // Get table counts for diagnostics
    $tables = [
        'tornate',
        'utenti',
        'audio_discussioni',
        'libri',
        'prestiti',
        'chat_rooms',
        'chat_messages',
        'notifiche'
    ];
    
    $tableCounts = [];
    foreach ($tables as $table) {
        try {
            $stmt = $pdo->query("SELECT COUNT(*) FROM $table");
            $tableCounts[$table] = (int)$stmt->fetchColumn();
        } catch (PDOException $e) {
            $tableCounts[$table] = "table not found or inaccessible";
        }
    }
    
    echo json_encode([
        "success" => true,
        "api_name" => "Kilwinning - Sistema Gestione Tornate API",
        "version" => "1.0.0",
        "status" => "operational",
        "timestamp" => date('Y-m-d H:i:s'),
        "database" => [
            "status" => $dbStatus,
            "version" => $dbVersion,
            "name" => "jmvvznbb_tornate_db",
            "tables" => $tableCounts
        ],
        "endpoints" => [
            "audio_discussioni" => [
                "GET" => "/api/audio_discussioni.php?id_tornata=XX",
                "POST" => "/api/audio_discussioni.php",
                "DELETE" => "/api/audio_discussioni.php?id=XX"
            ],
            "libri" => [
                "GET" => "/api/libri.php or /api/libri.php?id=XX",
                "POST" => "/api/libri.php",
                "DELETE" => "/api/libri.php?id=XX"
            ],
            "prestiti" => [
                "GET" => "/api/prestiti.php?id_fratello=XX",
                "POST" => "/api/prestiti.php"
            ],
            "chat" => [
                "GET" => "/api/chat.php?rooms=1 or /api/chat.php?id_chat=XX",
                "POST" => "/api/chat.php",
                "PUT" => "/api/chat.php (mark as read)"
            ],
            "notifiche" => [
                "GET" => "/api/notifiche.php?id_fratello=XX",
                "POST" => "/api/notifiche.php or ?mark_read=XX",
                "DELETE" => "/api/notifiche.php?id=XX"
            ]
        ],
        "documentation" => "/api/README.md"
    ], JSON_PRETTY_PRINT);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error" => "Database connection failed",
        "details" => $e->getMessage(),
        "hint" => "Check config.php credentials"
    ], JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "error" => "Server error",
        "details" => $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
?>
