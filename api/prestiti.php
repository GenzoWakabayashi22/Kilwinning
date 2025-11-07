<?php
/* ===== FILE: prestiti.php ===== */
/**
 * Kilwinning - Library Loan Management
 * 
 * Handles library loan operations and automatically updates book availability.
 * 
 * Endpoints:
 * - GET  ?id_fratello=XX : Get all loans for a specific member
 * - POST (body JSON)      : Create new loan or close existing loan
 * 
 * Loan Creation:
 *   - Sets libro.stato = 'In prestito'
 *   - Records data_prestito
 * 
 * Loan Closure:
 *   - Sets libro.stato = 'Disponibile'
 *   - Records data_restituzione
 * 
 * Fields: id, id_libro, id_fratello, data_prestito, data_restituzione, 
 *         data_scadenza, stato_prestito
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id_fratello'])) {
                // Get all loans for a specific member
                $stmt = $pdo->prepare("
                    SELECT 
                        p.id,
                        p.id_libro,
                        p.id_fratello,
                        p.data_prestito,
                        p.data_restituzione,
                        p.data_scadenza,
                        p.stato_prestito,
                        l.titolo AS libro_titolo,
                        l.autore AS libro_autore,
                        l.copertina_url AS libro_copertina
                    FROM prestiti p
                    LEFT JOIN libri l ON p.id_libro = l.id
                    WHERE p.id_fratello = :id_fratello
                    ORDER BY p.data_prestito DESC
                ");
                $stmt->bindParam(':id_fratello', $_GET['id_fratello'], PDO::PARAM_INT);
                $stmt->execute();
                $results = $stmt->fetchAll();
                
                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
            } else {
                // Get all active loans
                $stmt = $pdo->query("
                    SELECT 
                        p.id,
                        p.id_libro,
                        p.id_fratello,
                        p.data_prestito,
                        p.data_restituzione,
                        p.data_scadenza,
                        p.stato_prestito,
                        l.titolo AS libro_titolo,
                        l.autore AS libro_autore,
                        u.nome AS fratello_nome
                    FROM prestiti p
                    LEFT JOIN libri l ON p.id_libro = l.id
                    LEFT JOIN utenti u ON p.id_fratello = u.id
                    WHERE p.stato_prestito = 'Attivo'
                    ORDER BY p.data_prestito DESC
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
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Invalid JSON data"
                ]);
                break;
            }
            
            // Check if closing an existing loan
            if (isset($data['id']) && isset($data['close_loan']) && $data['close_loan'] === true) {
                // Close loan and update book status
                $pdo->beginTransaction();
                
                try {
                    // Update loan record
                    $stmt = $pdo->prepare("
                        UPDATE prestiti
                        SET data_restituzione = NOW(),
                            stato_prestito = 'Restituito'
                        WHERE id = :id
                    ");
                    $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
                    $stmt->execute();
                    
                    // Get libro ID to update its status
                    $stmt = $pdo->prepare("SELECT id_libro FROM prestiti WHERE id = :id");
                    $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
                    $stmt->execute();
                    $prestito = $stmt->fetch();
                    
                    if ($prestito) {
                        // Update book status to available
                        $stmt = $pdo->prepare("
                            UPDATE libri
                            SET stato = 'Disponibile'
                            WHERE id = :id_libro
                        ");
                        $stmt->bindParam(':id_libro', $prestito['id_libro'], PDO::PARAM_INT);
                        $stmt->execute();
                    }
                    
                    $pdo->commit();
                    
                    echo json_encode([
                        "success" => true,
                        "message" => "Loan closed successfully, book is now available"
                    ]);
                } catch (Exception $e) {
                    $pdo->rollBack();
                    throw $e;
                }
                
            } else {
                // Create new loan
                if (!isset($data['id_libro']) || !isset($data['id_fratello'])) {
                    http_response_code(400);
                    echo json_encode([
                        "error" => "Missing required fields",
                        "required" => ["id_libro", "id_fratello"]
                    ]);
                    break;
                }
                
                $pdo->beginTransaction();
                
                try {
                    // Check if book is available
                    $stmt = $pdo->prepare("SELECT stato FROM libri WHERE id = :id_libro");
                    $stmt->bindParam(':id_libro', $data['id_libro'], PDO::PARAM_INT);
                    $stmt->execute();
                    $libro = $stmt->fetch();
                    
                    if (!$libro) {
                        http_response_code(404);
                        echo json_encode([
                            "error" => "Book not found"
                        ]);
                        $pdo->rollBack();
                        break;
                    }
                    
                    if ($libro['stato'] !== 'Disponibile') {
                        http_response_code(400);
                        echo json_encode([
                            "error" => "Book is not available for loan",
                            "current_status" => $libro['stato']
                        ]);
                        $pdo->rollBack();
                        break;
                    }
                    
                    // Calculate due date (default: 30 days from now)
                    $giorni_prestito = $data['giorni_prestito'] ?? 30;
                    
                    // Create loan record
                    $stmt = $pdo->prepare("
                        INSERT INTO prestiti 
                        (id_libro, id_fratello, data_prestito, data_scadenza, stato_prestito)
                        VALUES (:id_libro, :id_fratello, NOW(), DATE_ADD(NOW(), INTERVAL :giorni DAY), 'Attivo')
                    ");
                    $stmt->bindParam(':id_libro', $data['id_libro'], PDO::PARAM_INT);
                    $stmt->bindParam(':id_fratello', $data['id_fratello'], PDO::PARAM_INT);
                    $stmt->bindParam(':giorni', $giorni_prestito, PDO::PARAM_INT);
                    $stmt->execute();
                    
                    $insertId = $pdo->lastInsertId();
                    
                    // Update book status to on loan
                    $stmt = $pdo->prepare("
                        UPDATE libri
                        SET stato = 'In prestito'
                        WHERE id = :id_libro
                    ");
                    $stmt->bindParam(':id_libro', $data['id_libro'], PDO::PARAM_INT);
                    $stmt->execute();
                    
                    $pdo->commit();
                    
                    echo json_encode([
                        "success" => true,
                        "message" => "Loan created successfully, book status updated",
                        "id" => $insertId
                    ]);
                } catch (Exception $e) {
                    $pdo->rollBack();
                    throw $e;
                }
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
