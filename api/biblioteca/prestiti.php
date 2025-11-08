<?php
/**
 * Biblioteca - Endpoint Prestiti Completo
 */

require_once '../config.php';

header('Content-Type: application/json');

try {
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            if (isset($_GET['all'])) {
                // Admin: get all prestiti
                $stmt = $pdo->query("
                    SELECT p.*, l.titolo as titolo_libro, l.autore as autore_libro,
                           f.nome as nome_fratello
                    FROM storico_prestiti p
                    LEFT JOIN libri l ON p.libro_id = l.id
                    LEFT JOIN fratelli f ON p.fratello_id = f.id
                    ORDER BY p.data_inizio DESC
                ");
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } elseif (isset($_GET['scaduti'])) {
                // Admin: get expired loans
                $stmt = $pdo->query("
                    SELECT p.*, l.titolo as titolo_libro, l.autore as autore_libro,
                           f.nome as nome_fratello
                    FROM storico_prestiti p
                    LEFT JOIN libri l ON p.libro_id = l.id
                    LEFT JOIN fratelli f ON p.fratello_id = f.id
                    WHERE p.stato = 'Attivo' AND p.data_scadenza < NOW()
                    ORDER BY p.data_scadenza ASC
                ");
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } elseif (isset($_GET['id_fratello'])) {
                // Get prestiti for specific fratello
                $stmt = $pdo->prepare("
                    SELECT p.*, l.titolo as titolo_libro, l.autore as autore_libro
                    FROM storico_prestiti p
                    LEFT JOIN libri l ON p.libro_id = l.id
                    WHERE p.fratello_id = :fratello_id
                    ORDER BY p.data_inizio DESC
                ");
                $stmt->execute([':fratello_id' => $_GET['id_fratello']]);
                $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
            } else {
                http_response_code(400);
                echo json_encode(["success" => false, "error" => "Parametri mancanti"]);
                exit;
            }

            echo json_encode(["success" => true, "data" => $results]);
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);

            if (isset($data['libro_id'])) {
                // Request new loan (stato: Richiesto)
                session_start();
                $fratello_id = $_SESSION['fratello_id'] ?? ($data['fratello_id'] ?? null);

                if (!$fratello_id) {
                    http_response_code(401);
                    echo json_encode(["success" => false, "error" => "Autenticazione richiesta"]);
                    exit;
                }

                // Check if book is available
                $stmt = $pdo->prepare("SELECT stato FROM libri WHERE id = :id");
                $stmt->execute([':id' => $data['libro_id']]);
                $libro = $stmt->fetch(PDO::FETCH_ASSOC);

                if (!$libro || $libro['stato'] !== 'Disponibile') {
                    http_response_code(400);
                    echo json_encode(["success" => false, "error" => "Libro non disponibile"]);
                    exit;
                }

                // Create loan request
                $stmt = $pdo->prepare("
                    INSERT INTO storico_prestiti (libro_id, fratello_id, stato)
                    VALUES (:libro_id, :fratello_id, 'Richiesto')
                ");
                $stmt->execute([
                    ':libro_id' => $data['libro_id'],
                    ':fratello_id' => $fratello_id
                ]);

                echo json_encode(["success" => true, "message" => "Richiesta prestito inviata"]);

            } elseif (isset($data['prestito_id']) && isset($data['action'])) {
                // Admin actions
                if ($data['action'] === 'approva') {
                    $giorni = $data['giorni_durata'] ?? 30;

                    $pdo->beginTransaction();

                    $stmt = $pdo->prepare("
                        UPDATE storico_prestiti
                        SET stato = 'Attivo',
                            data_inizio = NOW(),
                            data_scadenza = DATE_ADD(NOW(), INTERVAL :giorni DAY)
                        WHERE id = :id
                    ");
                    $stmt->execute([':id' => $data['prestito_id'], ':giorni' => $giorni]);

                    // Get libro_id and update libro status
                    $stmt = $pdo->prepare("SELECT libro_id FROM storico_prestiti WHERE id = :id");
                    $stmt->execute([':id' => $data['prestito_id']]);
                    $libroId = $stmt->fetchColumn();

                    $stmt = $pdo->prepare("UPDATE libri SET stato = 'In prestito' WHERE id = :id");
                    $stmt->execute([':id' => $libroId]);

                    $pdo->commit();

                    echo json_encode(["success" => true, "message" => "Prestito approvato"]);

                } elseif ($data['action'] === 'restituzione') {
                    $pdo->beginTransaction();

                    $stmt = $pdo->prepare("
                        UPDATE storico_prestiti
                        SET stato = 'Concluso', data_fine = NOW()
                        WHERE id = :id
                    ");
                    $stmt->execute([':id' => $data['prestito_id']]);

                    // Get libro_id and update libro status
                    $stmt = $pdo->prepare("SELECT libro_id FROM storico_prestiti WHERE id = :id");
                    $stmt->execute([':id' => $data['prestito_id']]);
                    $libroId = $stmt->fetchColumn();

                    $stmt = $pdo->prepare("UPDATE libri SET stato = 'Disponibile' WHERE id = :id");
                    $stmt->execute([':id' => $libroId]);

                    $pdo->commit();

                    echo json_encode(["success" => true, "message" => "Libro restituito"]);
                }
            }
            break;

        default:
            http_response_code(405);
            echo json_encode(["success" => false, "error" => "Metodo non consentito"]);
    }

} catch (Exception $e) {
    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
