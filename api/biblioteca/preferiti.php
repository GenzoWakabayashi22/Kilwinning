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
            $stmt = $pdo->prepare("SELECT * FROM preferiti WHERE fratello_id = :fratello_id");
            $stmt->execute([':fratello_id' => $fratello_id]);
            echo json_encode(["success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
            break;

        case 'POST':
            $data = json_decode(file_get_contents("php://input"), true);

            // Check if already exists
            $stmt = $pdo->prepare("SELECT id FROM preferiti WHERE fratello_id = :fratello_id AND libro_id = :libro_id");
            $stmt->execute([':fratello_id' => $fratello_id, ':libro_id' => $data['libro_id']]);

            if ($stmt->fetch()) {
                // Remove
                $stmt = $pdo->prepare("DELETE FROM preferiti WHERE fratello_id = :fratello_id AND libro_id = :libro_id");
                $stmt->execute([':fratello_id' => $fratello_id, ':libro_id' => $data['libro_id']]);
                echo json_encode(["success" => true, "action" => "removed"]);
            } else {
                // Add
                $stmt = $pdo->prepare("INSERT INTO preferiti (fratello_id, libro_id) VALUES (:fratello_id, :libro_id)");
                $stmt->execute([':fratello_id' => $fratello_id, ':libro_id' => $data['libro_id']]);
                echo json_encode(["success" => true, "action" => "added", "id" => $pdo->lastInsertId()]);
            }
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
