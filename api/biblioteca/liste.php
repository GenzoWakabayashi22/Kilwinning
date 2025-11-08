<?php
require_once '../config.php';
header('Content-Type: application/json');

try {
    $method = $_SERVER['REQUEST_METHOD'];
    session_start();
    $fratello_id = $_SESSION['fratello_id'] ?? null;

    if (!$fratello_id) {
        http_response_code(401);
        echo json_encode(["success" => false, "error" => "Autenticazione richiesta"]);
        exit;
    }

    switch ($method) {
        case 'GET':
            $stmt = $pdo->prepare("
                SELECT l.*,
                       f.nome as nome_fratello,
                       COUNT(DISTINCT ll.libro_id) as numero_libri
                FROM liste_lettura l
                LEFT JOIN fratelli f ON l.fratello_id = f.id
                LEFT JOIN libri_liste ll ON l.id = ll.lista_id
                WHERE l.fratello_id = :fratello_id OR l.privacy = 'pubblica'
                GROUP BY l.id
                ORDER BY l.data_creazione DESC
            ");
            $stmt->execute([':fratello_id' => $fratello_id]);
            echo json_encode(["success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);

            if (isset($data['action']) && $data['action'] === 'add_book') {
                $stmt = $pdo->prepare("INSERT INTO libri_liste (lista_id, libro_id) VALUES (:lista_id, :libro_id)");
                $stmt->execute([':lista_id' => $data['lista_id'], ':libro_id' => $data['libro_id']]);
                echo json_encode(["success" => true]);
            } elseif (isset($data['action']) && $data['action'] === 'remove_book') {
                $stmt = $pdo->prepare("DELETE FROM libri_liste WHERE lista_id = :lista_id AND libro_id = :libro_id");
                $stmt->execute([':lista_id' => $data['lista_id'], ':libro_id' => $data['libro_id']]);
                echo json_encode(["success" => true]);
            } else {
                $stmt = $pdo->prepare("INSERT INTO liste_lettura (nome, descrizione, icona, colore, privacy, fratello_id) VALUES (:nome, :descrizione, :icona, :colore, :privacy, :fratello_id)");
                $stmt->execute([
                    ':nome' => $data['nome'],
                    ':descrizione' => $data['descrizione'] ?? null,
                    ':icona' => $data['icona'] ?? '📖',
                    ':colore' => $data['colore'] ?? '#4A90E2',
                    ':privacy' => $data['privacy'] ?? 'privata',
                    ':fratello_id' => $fratello_id
                ]);
                echo json_encode(["success" => true, "id" => $pdo->lastInsertId()]);
            }
            break;

        case 'DELETE':
            $stmt = $pdo->prepare("DELETE FROM liste_lettura WHERE id = :id AND fratello_id = :fratello_id");
            $stmt->execute([':id' => $_GET['id'], ':fratello_id' => $fratello_id]);
            echo json_encode(["success" => true]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
