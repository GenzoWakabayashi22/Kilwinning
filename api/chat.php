<?php
/* ===== FILE: chat.php ===== */
/**
 * Kilwinning - Internal Messaging System
 * 
 * Handles chat rooms and messages for internal communications.
 * 
 * Endpoints:
 * - GET  ?rooms=1           : Get all chat rooms
 * - GET  ?id_chat=XX        : Get all messages for specific chat room
 * - POST (body JSON)         : Send new message
 * 
 * Chat Room Fields: id, nome_chat, descrizione, data_creazione
 * Message Fields: id, id_chat, id_mittente, testo, data_invio, letto
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['rooms']) && $_GET['rooms'] == '1') {
                // Get all chat rooms with last message info
                $stmt = $pdo->query("
                    SELECT 
                        cr.id,
                        cr.nome_chat,
                        cr.descrizione,
                        cr.data_creazione,
                        COUNT(cm.id) AS total_messages,
                        MAX(cm.data_invio) AS ultimo_messaggio
                    FROM chat_rooms cr
                    LEFT JOIN chat_messages cm ON cr.id = cm.id_chat
                    GROUP BY cr.id, cr.nome_chat, cr.descrizione, cr.data_creazione
                    ORDER BY ultimo_messaggio DESC
                ");
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
                
            } elseif (isset($_GET['id_chat'])) {
                // Get all messages for a specific chat room
                $stmt = $pdo->prepare("
                    SELECT 
                        cm.id,
                        cm.id_chat,
                        cm.id_mittente,
                        cm.testo,
                        cm.data_invio,
                        cm.letto,
                        u.nome AS mittente_nome,
                        u.cognome AS mittente_cognome
                    FROM chat_messages cm
                    LEFT JOIN utenti u ON cm.id_mittente = u.id
                    WHERE cm.id_chat = :id_chat
                    ORDER BY cm.data_invio ASC
                ");
                $stmt->bindParam(':id_chat', $_GET['id_chat'], PDO::PARAM_INT);
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
                
            } else {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter",
                    "hint" => "Use ?rooms=1 to get chat rooms or ?id_chat=XX to get messages"
                ]);
            }
            break;
            
        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Invalid JSON data"
                ]);
                break;
            }
            
            // Check if creating a new chat room
            if (isset($data['create_room']) && $data['create_room'] === true) {
                if (!isset($data['nome_chat'])) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Missing required field: nome_chat"
                    ]);
                    break;
                }
                
                $stmt = $pdo->prepare("
                    INSERT INTO chat_rooms 
                    (nome_chat, descrizione, data_creazione)
                    VALUES (:nome_chat, :descrizione, NOW())
                ");
                $stmt->bindParam(':nome_chat', $data['nome_chat'], PDO::PARAM_STR);
                $stmt->bindParam(':descrizione', $data['descrizione'] ?? null, PDO::PARAM_STR);
                $stmt->execute();
                
                $insertId = $pdo->lastInsertId();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Chat room created successfully",
                    "id" => $insertId
                ]);
                
            } else {
                // Send new message
                if (!isset($data['id_chat']) || !isset($data['id_mittente']) || !isset($data['testo'])) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Missing required fields",
                        "required" => ["id_chat", "id_mittente", "testo"]
                    ]);
                    break;
                }
                
                // Verify chat room exists
                $checkStmt = $pdo->prepare("SELECT id FROM chat_rooms WHERE id = :id_chat");
                $checkStmt->bindParam(':id_chat', $data['id_chat'], PDO::PARAM_INT);
                $checkStmt->execute();
                
                if (!$checkStmt->fetch()) {
                    http_response_code(404);
                    echo json_encode([
                        "error" => "Chat room not found"
                    ]);
                    break;
                }
                
                $stmt = $pdo->prepare("
                    INSERT INTO chat_messages 
                    (id_chat, id_mittente, testo, data_invio, letto)
                    VALUES (:id_chat, :id_mittente, :testo, NOW(), 0)
                ");
                $stmt->bindParam(':id_chat', $data['id_chat'], PDO::PARAM_INT);
                $stmt->bindParam(':id_mittente', $data['id_mittente'], PDO::PARAM_INT);
                $stmt->bindParam(':testo', $data['testo'], PDO::PARAM_STR);
                $stmt->execute();
                
                $insertId = $pdo->lastInsertId();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Message sent successfully",
                    "id" => $insertId
                ]);
            }
            break;
            
        case 'PUT':
            // Mark messages as read
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data || !isset($data['id'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required field: id"
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("
                UPDATE chat_messages
                SET letto = 1
                WHERE id = :id
            ");
            $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            echo json_encode([
                "success" => true,
                "message" => "Message marked as read"
            ]);
            break;
            
        default:
            http_response_code(405);
            echo json_encode([
                "error" => "Method not allowed",
                "allowed_methods" => ["GET", "POST", "PUT"]
            ]);
            break;
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Database error",
        "details" => $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Server error",
        "details" => $e->getMessage()
    ]);
}
?>
