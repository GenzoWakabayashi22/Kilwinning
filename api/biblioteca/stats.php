<?php
require_once '../config.php';
header('Content-Type: application/json');

try {
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if (isset($_GET['advanced'])) {
        // Admin stats
        $stats = [];

        // Top libri prestati
        $stmt = $pdo->query("
            SELECT l.id, l.titolo, l.autore, COUNT(p.id) as conteggio
            FROM libri l
            JOIN storico_prestiti p ON l.id = p.libro_id
            GROUP BY l.id
            ORDER BY conteggio DESC
            LIMIT 10
        ");
        $stats['top_libri_prestati'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Top libri recensiti
        $stmt = $pdo->query("
            SELECT l.id, l.titolo, l.autore, COUNT(r.id) as conteggio, AVG(r.voto) as voto_medio
            FROM libri l
            JOIN recensioni r ON l.id = r.libro_id
            GROUP BY l.id
            ORDER BY conteggio DESC
            LIMIT 10
        ");
        $stats['top_libri_recensiti'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Top fratelli attivi
        $stmt = $pdo->query("
            SELECT f.id, f.nome,
                   COUNT(DISTINCT p.id) as numero_prestiti,
                   COUNT(DISTINCT r.id) as numero_recensioni
            FROM fratelli f
            LEFT JOIN storico_prestiti p ON f.id = p.fratello_id
            LEFT JOIN recensioni r ON f.id = r.fratello_id
            GROUP BY f.id
            HAVING numero_prestiti > 0 OR numero_recensioni > 0
            ORDER BY (numero_prestiti + numero_recensioni) DESC
            LIMIT 10
        ");
        $stats['top_fratelli_attivi'] = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode(["success" => true, "data" => $stats]);
    } else {
        // Basic stats
        $stats = [];

        $stmt = $pdo->query("SELECT COUNT(*) as totale_libri FROM libri");
        $stats['totale_libri'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as libri_disponibili FROM libri WHERE stato = 'Disponibile'");
        $stats['libri_disponibili'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as libri_prestati FROM libri WHERE stato = 'In prestito'");
        $stats['libri_prestati'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as libri_prenotati FROM libri WHERE stato = 'Prenotato'");
        $stats['libri_prenotati'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as totale_prestiti FROM storico_prestiti");
        $stats['totale_prestiti'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as prestiti_attivi FROM storico_prestiti WHERE stato = 'Attivo'");
        $stats['prestiti_attivi'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT COUNT(*) as recensioni_totali FROM recensioni");
        $stats['recensioni_totali'] = $stmt->fetchColumn();

        $stmt = $pdo->query("SELECT AVG(voto) as voto_medio_globale FROM recensioni");
        $stats['voto_medio_globale'] = round($stmt->fetchColumn(), 2);

        echo json_encode(["success" => true, "data" => $stats]);
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "error" => $e->getMessage()]);
}
?>
