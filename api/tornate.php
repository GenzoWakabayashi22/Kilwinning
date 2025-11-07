<?php
/* ===== FILE: tornate.php ===== */
/**
 * Kilwinning - Tornate (Lodge Meetings) Management
 * 
 * Handles CRUD operations for tornate (lodge meetings).
 * 
 * Endpoints:
 * - GET                  : Get all tornate
 * - GET  ?id=XX         : Get specific tornata by ID
 * - POST (body JSON)     : Create or update tornata
 * - DELETE ?id=XX        : Delete tornata by ID
 * 
 * Fields: id, titolo, data_tornata, tipo, luogo, presentato_da, 
 *         ha_agape, note, creato_il
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get specific tornata by ID
                $stmt = $pdo->prepare("
                    SELECT id, titolo, data_tornata, tipo, luogo, presentato_da, 
                           ha_agape, note, creato_il
                    FROM tornate
                    WHERE id = :id
                ");
                $stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
                $stmt->execute();
                $result = $stmt->fetch();
                
                if ($result) {
                    echo json_encode([
                        "success" => true,
                        "data" => $result
                    ]);
                } else {
                    http_response_code(404);
                    echo json_encode([
                        "error" => "Tornata not found"
                    ]);
                }
            } else {
                // Get all tornate with optional filters
                $query = "
                    SELECT id, titolo, data_tornata, tipo, luogo, presentato_da, 
                           ha_agape, note, creato_il
                    FROM tornate
                ";
                
                $conditions = [];
                $params = [];
                
                // Filter by type
                if (isset($_GET['tipo'])) {
                    $conditions[] = "tipo = :tipo";
                    $params[':tipo'] = $_GET['tipo'];
                }
                
                // Filter by location
                if (isset($_GET['luogo'])) {
                    $conditions[] = "luogo = :luogo";
                    $params[':luogo'] = $_GET['luogo'];
                }
                
                // Filter by date range
                if (isset($_GET['data_inizio']) && isset($_GET['data_fine'])) {
                    $conditions[] = "data_tornata BETWEEN :data_inizio AND :data_fine";
                    $params[':data_inizio'] = $_GET['data_inizio'];
                    $params[':data_fine'] = $_GET['data_fine'];
                }
                
                // Filter by year
                if (isset($_GET['anno'])) {
                    $conditions[] = "YEAR(data_tornata) = :anno";
                    $params[':anno'] = $_GET['anno'];
                }
                
                if (!empty($conditions)) {
                    $query .= " WHERE " . implode(" AND ", $conditions);
                }
                
                $query .= " ORDER BY data_tornata DESC";
                
                $stmt = $pdo->prepare($query);
                
                foreach ($params as $key => $value) {
                    $stmt->bindValue($key, $value);
                }
                
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
            }
            break;
            
        case 'POST':
            // Create or update tornata
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data || !isset($data['titolo']) || !isset($data['data_tornata'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required fields",
                    "required" => ["titolo", "data_tornata"]
                ]);
                break;
            }
            
            if (isset($data['id']) && $data['id'] > 0) {
                // Update existing tornata
                $stmt = $pdo->prepare("
                    UPDATE tornate
                    SET titolo = :titolo,
                        data_tornata = :data_tornata,
                        tipo = :tipo,
                        luogo = :luogo,
                        presentato_da = :presentato_da,
                        ha_agape = :ha_agape,
                        note = :note
                    WHERE id = :id
                ");
                $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            } else {
                // Create new tornata
                $stmt = $pdo->prepare("
                    INSERT INTO tornate 
                    (titolo, data_tornata, tipo, luogo, presentato_da, ha_agape, note, creato_il)
                    VALUES (:titolo, :data_tornata, :tipo, :luogo, :presentato_da, :ha_agape, :note, NOW())
                ");
            }
            
            $stmt->bindParam(':titolo', $data['titolo'], PDO::PARAM_STR);
            $stmt->bindParam(':data_tornata', $data['data_tornata'], PDO::PARAM_STR);
            
            $tipo = $data['tipo'] ?? 'Ordinaria';
            $stmt->bindParam(':tipo', $tipo, PDO::PARAM_STR);
            
            $luogo = $data['luogo'] ?? 'Nostra Loggia - Tolfa';
            $stmt->bindParam(':luogo', $luogo, PDO::PARAM_STR);
            
            $stmt->bindParam(':presentato_da', $data['presentato_da'] ?? null, PDO::PARAM_STR);
            
            $ha_agape = isset($data['ha_agape']) ? ($data['ha_agape'] ? 1 : 0) : 0;
            $stmt->bindParam(':ha_agape', $ha_agape, PDO::PARAM_INT);
            
            $stmt->bindParam(':note', $data['note'] ?? null, PDO::PARAM_STR);
            
            $stmt->execute();
            
            $id = isset($data['id']) && $data['id'] > 0 ? $data['id'] : $pdo->lastInsertId();
            
            echo json_encode([
                "success" => true,
                "message" => isset($data['id']) ? "Tornata updated successfully" : "Tornata created successfully",
                "id" => $id
            ]);
            break;
            
        case 'DELETE':
            // Delete tornata by ID
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter: id"
                ]);
                break;
            }
            
            // Check if tornata exists
            $checkStmt = $pdo->prepare("SELECT id FROM tornate WHERE id = :id");
            $checkStmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $checkStmt->execute();
            
            if (!$checkStmt->fetch()) {
                http_response_code(404);
                echo json_encode([
                    "error" => "Tornata not found"
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("DELETE FROM tornate WHERE id = :id");
            $stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            echo json_encode([
                "success" => true,
                "message" => "Tornata deleted successfully"
            ]);
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
