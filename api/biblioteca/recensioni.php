<?php
require_once '../config.php';
header('Content-Type: application/json');

try {
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            $stmt = $pdo->prepare("
                SELECT r.*, f.nome as nome_fratello
                FROM recensioni r
                LEFT JOIN fratelli f ON r.fratello_id = f.id
                WHERE r.libro_id = :libro_id
                ORDER BY r.data_creazione DESC
            ");
            $stmt->execute([':libro_id' => $_GET['libro_id']]);
            echo json_encode(["success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            session_start();
            $fratello_id = $_SESSION['fratello_id'] ?? null;

            if (!$fratello_id) {
                http_response_code(401);
                echo json_encode(["success" => false, "error" => "Autenticazione richiesta"]);
                exit;
            }

            if (isset($data['id'])) {
                $stmt = $pdo->prepare("UPDATE recensioni SET voto = :voto, testo = :testo, data_modifica = NOW() WHERE id = :id AND fratello_id = :fratello_id");
                $stmt->execute([':id' => $data['id'], ':voto' => $data['voto'], ':testo' => $data['testo'] ?? null, ':fratello_id' => $fratello_id]);
                echo json_encode(["success" => true, "message" => "Recensione aggiornata"]);
            } else {
                $stmt = $pdo->prepare("INSERT INTO recensioni (libro_id, fratello_id, voto, testo) VALUES (:libro_id, :fratello_id, :voto, :testo)");
                $stmt->execute([':libro_id' => $data['libro_id'], ':fratello_id' => $fratello_id, ':voto' => $data['voto'], ':testo' => $data['testo'] ?? null]);
                echo json_encode(["success" => true, "message" => "Recensione creata", "id" => $pdo->lastInsertId()]);
            }
            break;

        case 'DELETE':
            $stmt = $pdo->prepare("DELETE FROM recensioni WHERE id = :id");
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode(["success" => true]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
