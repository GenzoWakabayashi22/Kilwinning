<?php
/**
 * Biblioteca - Endpoint Libri Completo
 * Gestisce catalogo libri con tutti i campi estesi
 */

require_once '../config.php';

header('Content-Type: application/json');

try {
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            if (isset($_GET['id'])) {
                // Get libro detail con recensioni
                $stmt = $pdo->prepare("
                    SELECT l.*,
                           COALESCE(AVG(r.voto), 0) as voto_medio,
                           COUNT(DISTINCT r.id) as numero_recensioni
                    FROM libri l
                    LEFT JOIN recensioni r ON l.id = r.libro_id
                    WHERE l.id = :id
                    GROUP BY l.id
                ");
                $stmt->execute([':id' => $_GET['id']]);
                $libro = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$libro) {
                    http_response_code(404);
                    echo json_encode(["success" => false, "error" => "Libro non trovato"]);
                    exit;
                }

                // Get recensioni
                $stmt = $pdo->prepare("
                    SELECT r.*, f.nome as nome_fratello
                    FROM recensioni r
                    LEFT JOIN fratelli f ON r.fratello_id = f.id
                    WHERE r.libro_id = :id
                    ORDER BY r.data_creazione DESC
                ");
                $stmt->execute([':id' => $_GET['id']]);
                $recensioni = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo json_encode([
                    "success" => true,
                    "data" => [
                        "libro" => $libro,
                        "recensioni" => $recensioni
                    ]
                ]);
            } else {
                // Get all books con filtri
                $query = "
                    SELECT l.*,
                           COALESCE(AVG(r.voto), 0) as voto_medio,
                           COUNT(DISTINCT r.id) as numero_recensioni
                    FROM libri l
                    LEFT JOIN recensioni r ON l.id = r.libro_id
                ";

                $conditions = [];
                $params = [];

                if (isset($_GET['categoria'])) {
                    $conditions[] = "l.categoria = :categoria";
                    $params[':categoria'] = $_GET['categoria'];
                }

                if (isset($_GET['stato'])) {
                    $conditions[] = "l.stato = :stato";
                    $params[':stato'] = $_GET['stato'];
                }

                if (isset($_GET['search'])) {
                    $conditions[] = "(l.titolo LIKE :search OR l.autore LIKE :search OR l.categoria LIKE :search)";
                    $params[':search'] = '%' . $_GET['search'] . '%';
                }

                if (!empty($conditions)) {
                    $query .= " WHERE " . implode(" AND ", $conditions);
                }

                $query .= " GROUP BY l.id ORDER BY l.titolo ASC";

                $stmt = $pdo->prepare($query);
                $stmt->execute($params);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

                echo json_encode([
                    "success" => true,
                    "data" => $results,
                    "count" => count($results)
                ]);
            }
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);

            if (!isset($data['titolo']) || !isset($data['autore'])) {
                http_response_code(400);
                echo json_encode(["success" => false, "error" => "Campi obbligatori mancanti"]);
                exit;
            }

            if (isset($data['id']) && $data['id'] > 0) {
                // Update
                $stmt = $pdo->prepare("
                    UPDATE libri SET
                        titolo = :titolo,
                        autore = :autore,
                        isbn = :isbn,
                        editore = :editore,
                        anno = :anno,
                        categoria = :categoria,
                        posizione = :posizione,
                        note = :note,
                        copertina_url = :copertina_url
                    WHERE id = :id
                ");
                $stmt->execute([
                    ':id' => $data['id'],
                    ':titolo' => $data['titolo'],
                    ':autore' => $data['autore'],
                    ':isbn' => $data['isbn'] ?? null,
                    ':editore' => $data['editore'] ?? null,
                    ':anno' => $data['anno'],
                    ':categoria' => $data['categoria'],
                    ':posizione' => $data['posizione'] ?? null,
                    ':note' => $data['note'] ?? null,
                    ':copertina_url' => $data['copertina_url'] ?? null
                ]);

                echo json_encode(["success" => true, "message" => "Libro aggiornato", "id" => $data['id']]);
            } else {
                // Insert with auto-generated codice_archivio
                $stmt = $pdo->query("SELECT MAX(CAST(SUBSTRING(codice_archivio, 4) AS UNSIGNED)) as max_code FROM libri WHERE codice_archivio LIKE 'BIB%'");
                $result = $stmt->fetch(PDO::FETCH_ASSOC);
                $nextNumber = ($result['max_code'] ?? 0) + 1;
                $codiceArchivio = 'BIB' . str_pad($nextNumber, 4, '0', STR_PAD_LEFT);

                $stmt = $pdo->prepare("
                    INSERT INTO libri (titolo, autore, isbn, editore, anno, categoria, codice_archivio, stato, posizione, note, copertina_url, data_aggiunta)
                    VALUES (:titolo, :autore, :isbn, :editore, :anno, :categoria, :codice, 'Disponibile', :posizione, :note, :copertina_url, NOW())
                ");
                $stmt->execute([
                    ':titolo' => $data['titolo'],
                    ':autore' => $data['autore'],
                    ':isbn' => $data['isbn'] ?? null,
                    ':editore' => $data['editore'] ?? null,
                    ':anno' => $data['anno'],
                    ':categoria' => $data['categoria'],
                    ':codice' => $codiceArchivio,
                    ':posizione' => $data['posizione'] ?? null,
                    ':note' => $data['note'] ?? null,
                    ':copertina_url' => $data['copertina_url'] ?? null
                ]);

                $id = $pdo->lastInsertId();
                echo json_encode(["success" => true, "message" => "Libro creato", "id" => $id]);
            }
            break;

        case 'DELETE':
            if (!isset($_GET['id'])) {
                http_response_code(400);
                echo json_encode(["success" => false, "error" => "ID mancante"]);
                exit;
            }

            // Check if book has active loans
            $stmt = $pdo->prepare("SELECT COUNT(*) as count FROM storico_prestiti WHERE libro_id = :id AND stato = 'Attivo'");
            $stmt->execute([':id' => $_GET['id']]);
            if ($stmt->fetch(PDO::FETCH_ASSOC)['count'] > 0) {
                http_response_code(400);
                echo json_encode(["success" => false, "error" => "Impossibile eliminare libro con prestiti attivi"]);
                exit;
            }

            $stmt = $pdo->prepare("DELETE FROM libri WHERE id = :id");
            $stmt->execute([':id' => $_GET['id']]);

            echo json_encode(["success" => true, "message" => "Libro eliminato"]);
            break;

        default:
            http_response_code(405);
            echo json_encode(["success" => false, "error" => "Metodo non consentito"]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
