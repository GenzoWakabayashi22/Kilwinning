<?php
/* ===== FILE: audio_discussioni.php ===== */
/**
 * Kilwinning - Audio Discussions Management
 * 
 * Handles CRUD operations for audio discussions linked to tornate.
 * 
 * Endpoints:
 * - GET  ?id_tornata=XX  : Get all audio discussions for a specific tornata
 * - POST (body JSON)     : Create new audio discussion
 * - DELETE ?id=XX        : Delete audio discussion by ID
 * 
 * Fields: id, id_tornata, fratello_intervento, titolo_intervento, 
 *         durata, audio_url, data_upload
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            // Get audio discussions for a specific tornata
            if (isset($_GET['id_tornata'])) {
                $stmt = $pdo->prepare("
                    SELECT id, id_tornata, fratello_intervento, titolo_intervento, 
                           durata, audio_url, data_upload
                    FROM audio_discussioni
                    WHERE id_tornata = :id_tornata
                    ORDER BY data_upload DESC
                ");
                $stmt->bindParam(':id_tornata', $_GET['id_tornata'], PDO::PARAM_INT);
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
            } else {
                // Get all audio discussions
                $stmt = $pdo->query("
                    SELECT id, id_tornata, fratello_intervento, titolo_intervento, 
                           durata, audio_url, data_upload
                    FROM audio_discussioni
                    ORDER BY data_upload DESC
                ");
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
            }
            break;
            
        case 'POST':
            // Create new audio discussion
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data || !isset($data['id_tornata']) || !isset($data['titolo_intervento'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required fields",
                    "required" => ["id_tornata", "titolo_intervento"]
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("
                INSERT INTO audio_discussioni 
                (id_tornata, fratello_intervento, titolo_intervento, durata, audio_url, data_upload)
                VALUES (:id_tornata, :fratello_intervento, :titolo_intervento, :durata, :audio_url, NOW())
            ");
            
            $stmt->bindParam(':id_tornata', $data['id_tornata'], PDO::PARAM_INT);
            $stmt->bindParam(':fratello_intervento', $data['fratello_intervento'], PDO::PARAM_STR);
            $stmt->bindParam(':titolo_intervento', $data['titolo_intervento'], PDO::PARAM_STR);
            $stmt->bindParam(':durata', $data['durata'], PDO::PARAM_STR);
            $stmt->bindParam(':audio_url', $data['audio_url'], PDO::PARAM_STR);
            
            $stmt->execute();
            $insertId = $pdo->lastInsertId();
            
            echo json_encode([
                "success" => true,
                "message" => "Audio discussion created successfully",
                "id" => $insertId
            ]);
            break;
            
        case 'DELETE':
            // Delete audio discussion by ID
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter: id"
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("DELETE FROM audio_discussioni WHERE id = :id");
            $stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            $rowCount = $stmt->rowCount();
            
            if ($rowCount > 0) {
                echo json_encode([
                    "success" => true,
                    "message" => "Audio discussion deleted successfully"
                ]);
            } else {
                http_response_code(404);
                echo json_encode([
                    "error" => "Audio discussion not found"
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
