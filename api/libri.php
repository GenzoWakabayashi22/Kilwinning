<?php
/* ===== FILE: libri.php ===== */
/**
 * Kilwinning - Library Catalog Management
 * 
 * Handles CRUD operations for the library catalog.
 * 
 * Endpoints:
 * - GET                  : Get all books
 * - GET  ?id=XX         : Get specific book by ID
 * - POST (body JSON)     : Create or update book
 * - DELETE ?id=XX        : Delete book by ID
 * 
 * Fields: id, titolo, autore, anno, categoria, codice_archivio, 
 *         stato, copertina_url
 */

require 'config.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get specific book by ID
                $stmt = $pdo->prepare("
                    SELECT id, titolo, autore, anno, categoria, codice_archivio, 
                           stato, copertina_url
                    FROM libri
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
                        "error" => "Book not found"
                    ]);
                }
            } else {
                // Get all books with optional filters
                $query = "
                    SELECT id, titolo, autore, anno, categoria, codice_archivio, 
                           stato, copertina_url
                    FROM libri
                ";
                
                $conditions = [];
                $params = [];
                
                // Filter by category
                if (isset($_GET['categoria'])) {
                    $conditions[] = "categoria = :categoria";
                    $params[':categoria'] = $_GET['categoria'];
                }
                
                // Filter by stato (availability)
                if (isset($_GET['stato'])) {
                    $conditions[] = "stato = :stato";
                    $params[':stato'] = $_GET['stato'];
                }
                
                // Search in title or author
                if (isset($_GET['search'])) {
                    $conditions[] = "(titolo LIKE :search OR autore LIKE :search)";
                    $params[':search'] = '%' . $_GET['search'] . '%';
                }
                
                if (!empty($conditions)) {
                    $query .= " WHERE " . implode(" AND ", $conditions);
                }
                
                $query .= " ORDER BY titolo ASC";
                
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
            // Create or update book
            $data = json_decode(file_get_contents("php://input"), true);
            
            if (!$data || !isset($data['titolo'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required field: titolo"
                ]);
                break;
            }
            
            if (isset($data['id']) && $data['id'] > 0) {
                // Update existing book
                $stmt = $pdo->prepare("
                    UPDATE libri
                    SET titolo = :titolo,
                        autore = :autore,
                        anno = :anno,
                        categoria = :categoria,
                        codice_archivio = :codice_archivio,
                        stato = :stato,
                        copertina_url = :copertina_url
                    WHERE id = :id
                ");
                $stmt->bindParam(':id', $data['id'], PDO::PARAM_INT);
            } else {
                // Create new book
                $stmt = $pdo->prepare("
                    INSERT INTO libri 
                    (titolo, autore, anno, categoria, codice_archivio, stato, copertina_url)
                    VALUES (:titolo, :autore, :anno, :categoria, :codice_archivio, :stato, :copertina_url)
                ");
            }
            
            $stmt->bindParam(':titolo', $data['titolo'], PDO::PARAM_STR);
            $stmt->bindParam(':autore', $data['autore'] ?? null, PDO::PARAM_STR);
            $stmt->bindParam(':anno', $data['anno'] ?? null, PDO::PARAM_INT);
            $stmt->bindParam(':categoria', $data['categoria'] ?? null, PDO::PARAM_STR);
            $stmt->bindParam(':codice_archivio', $data['codice_archivio'] ?? null, PDO::PARAM_STR);
            
            $stato = $data['stato'] ?? 'Disponibile';
            $stmt->bindParam(':stato', $stato, PDO::PARAM_STR);
            $stmt->bindParam(':copertina_url', $data['copertina_url'] ?? null, PDO::PARAM_STR);
            
            $stmt->execute();
            
            $id = isset($data['id']) && $data['id'] > 0 ? $data['id'] : $pdo->lastInsertId();
            
            echo json_encode([
                "success" => true,
                "message" => isset($data['id']) ? "Book updated successfully" : "Book created successfully",
                "id" => $id
            ]);
            break;
            
        case 'DELETE':
            // Delete book by ID
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode([
                    "error" => "Missing required parameter: id"
                ]);
                break;
            }
            
            // Check if book is currently on loan
            $checkStmt = $pdo->prepare("SELECT stato FROM libri WHERE id = :id");
            $checkStmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $checkStmt->execute();
            $book = $checkStmt->fetch();
            
            if (!$book) {
                http_response_code(404);
                echo json_encode([
                    "error" => "Book not found"
                ]);
                break;
            }
            
            if ($book['stato'] === 'In prestito') {
                http_response_code(400);
                echo json_encode([
                    "error" => "Cannot delete book that is currently on loan"
                ]);
                break;
            }
            
            $stmt = $pdo->prepare("DELETE FROM libri WHERE id = :id");
            $stmt->bindParam(':id', $_GET['id'], PDO::PARAM_INT);
            $stmt->execute();
            
            echo json_encode([
                "success" => true,
                "message" => "Book deleted successfully"
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
