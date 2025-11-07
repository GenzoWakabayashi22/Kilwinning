<?php
/* ===== FILE: notifiche.php ===== */
/**
 * Kilwinning - In-App Notifications
 * 
 * Handles notifications for tornate, audio, tavole, libri, and chat.
 * 
 * Endpoints:
 * - GET  ?id_fratello=XX         : Get all notifications for a member
 * - POST (body JSON)              : Create new notification
 * - POST ?mark_read=XX            : Mark notification as read
 * 
 * Fields: id, id_fratello, tipo, titolo, messaggio, 
 *         data_creazione, letta, id_riferimento
 * 
 * Notification Types:
 * - tornata: New tornata scheduled
 * - audio: New audio discussion uploaded
 * - tavola: New tavola architettonica published
 * - libro: Book loan reminder or available
 * - chat: New chat message
 * - sistema: System notifications
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id_fratello'])) {
                // Get all notifications for a specific member
                $query = "
                    SELECT 
                        id,
                        id_fratello,
                        tipo,
                        titolo,
                        messaggio,
                        data_creazione,
                        letta,
                        id_riferimento
                    FROM notifiche
                    WHERE id_fratello = :id_fratello
                ";
                
                // Filter by read/unread status
                if (isset($_GET['letta'])) {
                    $query .= " AND letta = :letta";
                }
                
                // Filter by notification type
                if (isset($_GET['tipo'])) {
                    $query .= " AND tipo = :tipo";
                }
                
                $query .= " ORDER BY data_creazione DESC";
                
                // Limit results if specified
                if (isset($_GET['limit'])) {
                    $query .= " LIMIT :limit";
                }
                
                $stmt = $pdo->prepare($query);
                $stmt->bindParam(':id_fratello', $_GET['id_fratello'], PDO::PARAM_INT);
                
                if (isset($_GET['letta'])) {
                    $letta = $_GET['letta'] === '1' ? 1 : 0;
                    $stmt->bindParam(':letta', $letta, PDO::PARAM_INT);
                }
                
                if (isset($_GET['tipo'])) {
                    $stmt->bindParam(':tipo', $_GET['tipo'], PDO::PARAM_STR);
                }
                
                if (isset($_GET['limit'])) {
                    $stmt->bindValue(':limit', (int)$_GET['limit'], PDO::PARAM_INT);
                }
                
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                // Count unread notifications
                $countStmt = $pdo->prepare("
                    SELECT COUNT(*) as unread_count
                    FROM notifiche
                    WHERE id_fratello = :id_fratello AND letta = 0
                ");
                $countStmt->bindParam(':id_fratello', $_GET['id_fratello'], PDO::PARAM_INT);
                $countStmt->execute();
                $countResult = $countStmt->fetch();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results),
                    "unread_count" => $countResult['unread_count']
                ]);
                
            } else {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter: id_fratello"
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
            
            // Check if marking notification as read
            if (isset($_GET['mark_read'])) {
                $id = $_GET['mark_read'];
                
                $stmt = $pdo->prepare("
                    UPDATE notifiche
                    SET letta = 1
                    WHERE id = :id
                ");
                $stmt->bindParam(':id', $id, PDO::PARAM_INT);
                $stmt->execute();
                
                $rowCount = $stmt->rowCount();
                
                if ($rowCount > 0) {
                    echo json_encode([
                        "success" => true,
                        "message" => "Notification marked as read"
                    ]);
                } else {
                    http_response_code(404);
                    echo json_encode([
                        "error" => "Notification not found"
                    ]);
                }
                
            } elseif (isset($_GET['mark_all_read'])) {
                // Mark all notifications as read for a user
                if (!isset($data['id_fratello'])) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Missing required field: id_fratello"
                    ]);
                    break;
                }
                
                $stmt = $pdo->prepare("
                    UPDATE notifiche
                    SET letta = 1
                    WHERE id_fratello = :id_fratello AND letta = 0
                ");
                $stmt->bindParam(':id_fratello', $data['id_fratello'], PDO::PARAM_INT);
                $stmt->execute();
                
                $rowCount = $stmt->rowCount();
                
                echo json_encode([
                    "success" => true,
                    "message" => "All notifications marked as read",
                    "updated_count" => $rowCount
                ]);
                
            } else {
                // Create new notification
                if (!isset($data['id_fratello']) || !isset($data['tipo']) || !isset($data['titolo'])) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Missing required fields",
                        "required" => ["id_fratello", "tipo", "titolo"]
                    ]);
                    break;
                }
                
                // Validate notification type
                $valid_types = ['tornata', 'audio', 'tavola', 'libro', 'chat', 'sistema'];
                if (!in_array($data['tipo'], $valid_types)) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Invalid notification type",
                        "valid_types" => $valid_types
                    ]);
                    break;
                }
                
                $stmt = $pdo->prepare("
                    INSERT INTO notifiche 
                    (id_fratello, tipo, titolo, messaggio, data_creazione, letta, id_riferimento)
                    VALUES (:id_fratello, :tipo, :titolo, :messaggio, NOW(), 0, :id_riferimento)
                ");
                
                $stmt->bindParam(':id_fratello', $data['id_fratello'], PDO::PARAM_INT);
                $stmt->bindParam(':tipo', $data['tipo'], PDO::PARAM_STR);
                $stmt->bindParam(':titolo', $data['titolo'], PDO::PARAM_STR);
                $stmt->bindParam(':messaggio', $data['messaggio'] ?? null, PDO::PARAM_STR);
                $stmt->bindParam(':id_riferimento', $data['id_riferimento'] ?? null, PDO::PARAM_INT);
                
                $stmt->execute();
                $insertId = $pdo->lastInsertId();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Notification created successfully",
                    "id" => $insertId
                ]);
            }
            break;
            
        case 'DELETE':
            // Delete notification by ID
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter: id"
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("DELETE FROM notifiche WHERE id = :id");
            $stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                echo json_encode([
                    "success" => true,
                    "message" => "Notification deleted successfully"
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    "error" => "Notification not found"
                ]);
            }
            break;
            
        default:
            http_response_code(405);
            echo json_encode([
                "error" => "Method not allowed",
                "allowed_methods" => ["GET", "POST", "DELETE"]
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
