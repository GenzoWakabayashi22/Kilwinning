<?php
/* ===== FILE: config.php ===== */
/**
 * Kilwinning - Sistema Gestione Tornate
 * Database Configuration and Global Headers
 * 
 * This file establishes the database connection using PDO
 * and sets up CORS headers for REST API access.
 */

// Load environment variables from .env file
require_once __DIR__ . '/load_env.php';

// Set JSON response headers
header("Content-Type: application/json; charset=UTF-8");

// CORS headers for cross-origin requests
// Note: In production, replace * with specific domain for better security
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Database credentials - SECURITY: Use environment variables
// Load from .env file or server environment
// NEVER commit the actual .env file to version control
$host = getenv('DB_HOST') ?: 'localhost';
$db_name = getenv('DB_NAME') ?: 'jmvvznbb_tornate_db';
$username = getenv('DB_USERNAME') ?: 'jmvvznbb_tornate_user';
$password = getenv('DB_PASSWORD') ?: '';

// Fallback warning in development
if (empty($password)) {
    error_log("WARNING: DB_PASSWORD not set in environment. Please configure .env file.");
}

try {
    // Create PDO connection with UTF-8 charset
    $pdo = new PDO("mysql:host=$host;dbname=$db_name;charset=utf8mb4", $username, $password);
    
    // Set error mode to exceptions for better error handling
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Use native prepared statements
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
    
    // Set default fetch mode to associative array
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
} catch (PDOException $e) {
    // Return error as JSON and exit
    http_response_code(500);
    echo json_encode([
        "error" => "Database connection failed",
        "details" => $e->getMessage()
    ]);
    exit;
}
?>
