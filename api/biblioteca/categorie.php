<?php
require_once '../config.php';
header('Content-Type: application/json');

try {
    $method = $_SERVER['REQUEST_METHOD'];

    switch ($method) {
        case 'GET':
            $stmt = $pdo->query("SELECT * FROM categorie_libri ORDER BY ordinamento ASC");
            echo json_encode(["success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);
            $stmt = $pdo->prepare("INSERT INTO categorie_libri (nome, icona, colore, ordinamento) VALUES (:nome, :icona, :colore, :ordinamento)");
            $stmt->execute([
                ':nome' => $data['nome'],
                ':icona' => $data['icona'] ?? '📚',
                ':colore' => $data['colore'] ?? null,
                ':ordinamento' => $data['ordinamento'] ?? 0
            ]);
            echo json_encode(["success" => true, "id" => $pdo->lastInsertId()]);
            break;

        case 'DELETE':
            $stmt = $pdo->prepare("DELETE FROM categorie_libri WHERE id = :id");
            $stmt->execute([':id' => $_GET['id']]);
            echo json_encode(["success" => true]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
