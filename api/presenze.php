<?php
/* ===== FILE: presenze.php ===== */
/**
 * Kilwinning - Attendance (Presenze) Management
 * 
 * Handles attendance tracking for tornate.
 * 
 * Endpoints:
 * - GET  ?id_fratello=XX           : Get all presenze for a specific brother
 * - GET  ?id_tornata=XX            : Get all presenze for a specific tornata
 * - GET  ?id_fratello=XX&anno=YYYY : Get presenze statistics for a brother in a year
 * - POST (body JSON)                : Update or create presenza
 * 
 * Fields: id, id_fratello, id_tornata, stato, confermato_il
 * Stati possibili: Presente, Assente, Non Confermato
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id_fratello']) && isset($_GET['anno'])) {
                // Get presence statistics for a brother in a specific year
                $anno = intval($_GET['anno']);
                $id_fratello = intval($_GET['id_fratello']);
                
                // Get all tornate for the year
                $tornateStmt = $pdo->prepare("
                    SELECT id FROM tornate 
                    WHERE YEAR(data_tornata) = :anno
                ");
                $tornateStmt->bindParam(':anno', $anno, PDO::PARAM_INT);
                $tornateStmt->execute();
                $tornate = $tornateStmt->fetchAll(PDO::FETCH_COLUMN);
                
                // Get presences for the brother
                $presenzeStmt = $pdo->prepare("
                    SELECT stato, COUNT(*) as count
                    FROM presenze
                    WHERE id_fratello = :id_fratello
                    AND id_tornata IN (
                        SELECT id FROM tornate WHERE YEAR(data_tornata) = :anno
                    )
                    GROUP BY stato
                ");
                $presenzeStmt->bindParam(':id_fratello', $id_fratello, PDO::PARAM_INT);
                $presenzeStmt->bindParam(':anno', $anno, PDO::PARAM_INT);
                $presenzeStmt->execute();
                $presenze = $presenzeStmt->fetchAll(PDO::FETCH_KEY_PAIR);
                
                $stats = [
                    "totalTornate" => count($tornate),
                    "presences" => $presenze['Presente'] ?? 0,
                    "absences" => $presenze['Assente'] ?? 0,
                    "unconfirmed" => $presenze['Non Confermato'] ?? 0
                ];
                
                echo json_encode([
                    "success" => true,
                    "data" => $stats
                ]);
                
            } elseif (isset($_GET['id_fratello'])) {
                // Get all presenze for a specific brother
                $stmt = $pdo->prepare("
                    SELECT 
                        p.id,
                        p.id_fratello,
                        p.id_tornata,
                        p.stato,
                        p.confermato_il,
                        t.titolo AS tornata_titolo,
                        t.data_tornata AS tornata_data,
                        t.tipo AS tornata_tipo
                    FROM presenze p
                    LEFT JOIN tornate t ON p.id_tornata = t.id
                    WHERE p.id_fratello = :id_fratello
                    ORDER BY t.data_tornata DESC
                ");
                $stmt->bindParam(':id_fratello', $_GET['id_fratello'], PDO::PARAM_INT);
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
                
            } elseif (isset($_GET['id_tornata'])) {
                // Get all presenze for a specific tornata
                $stmt = $pdo->prepare("
                    SELECT 
                        p.id,
                        p.id_fratello,
                        p.id_tornata,
                        p.stato,
                        p.confermato_il,
                        u.nome AS fratello_nome,
                        u.cognome AS fratello_cognome,
                        u.grado AS fratello_grado
                    FROM presenze p
                    LEFT JOIN utenti u ON p.id_fratello = u.id
                    WHERE p.id_tornata = :id_tornata
                    ORDER BY u.cognome ASC
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
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter",
                    "hint" => "Use ?id_fratello=XX or ?id_tornata=XX"
                ]);
            }
            break;
            
        case 'POST':
            // Update or create presenza
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data || !isset($data['id_fratello']) || !isset($data['id_tornata']) || !isset($data['stato'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required fields",
                    "required" => ["id_fratello", "id_tornata", "stato"]
                ]);
                break;
            }
            
            // Validate stato
            $valid_stati = ['Presente', 'Assente', 'Non Confermato'];
            if (!in_array($data['stato'], $valid_stati)) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Invalid stato value",
                    "allowed_values" => $valid_stati
                ]);
                break;
            }
            
            // Check if presenza already exists
            $checkStmt = $pdo->prepare("
                SELECT id FROM presenze 
                WHERE id_fratello = :id_fratello AND id_tornata = :id_tornata
            ");
            $checkStmt->bindParam(':id_fratello', $data['id_fratello'], PDO::PARAM_INT);
            $checkStmt->bindParam(':id_tornata', $data['id_tornata'], PDO::PARAM_INT);
            $checkStmt->execute();
            $existing = $checkStmt->fetch();
            
            if ($existing) {
                // Update existing presenza
                $stmt = $pdo->prepare("
                    UPDATE presenze
                    SET stato = :stato,
                        confermato_il = NOW()
                    WHERE id = :id
                ");
                $stmt->bindParam(':stato', $data['stato'], PDO::PARAM_STR);
                $stmt->bindParam(':id', $existing['id'], PDO::PARAM_INT);
                $stmt->execute();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Presenza updated successfully",
                    "id" => $existing['id']
                ]);
            } else {
                // Create new presenza
                $stmt = $pdo->prepare("
                    INSERT INTO presenze 
                    (id_fratello, id_tornata, stato, confermato_il)
                    VALUES (:id_fratello, :id_tornata, :stato, NOW())
                ");
                $stmt->bindParam(':id_fratello', $data['id_fratello'], PDO::PARAM_INT);
                $stmt->bindParam(':id_tornata', $data['id_tornata'], PDO::PARAM_INT);
                $stmt->bindParam(':stato', $data['stato'], PDO::PARAM_STR);
                $stmt->execute();
                
                $insertId = $pdo->lastInsertId();
                
                echo json_encode([
                    "success" => true,
                    "message" => "Presenza created successfully",
                    "id" => $insertId
                ]);
            }
            break;
            
        default:
            http_response_code(405);
            echo json_encode([
                "error" => "Method not allowed",
                "allowed_methods" => ["GET", "POST"]
            ]);
            break;
    }
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Database error"
        // Note: In production, never expose internal error details
        // Enable detailed logging server-side instead
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "error" => "Server error"
    ]);
}
?>
