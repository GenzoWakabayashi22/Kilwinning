<?php
/**
 * Simple .env file loader for PHP
 * Loads environment variables from .env file into $_ENV and getenv()
 * 
 * Usage: require_once 'load_env.php';
 */

function loadEnv($path = __DIR__ . '/.env') {
    // Security: Validate path to prevent directory traversal
    $realPath = realpath($path);
    $baseDir = realpath(__DIR__);
    
    // Ensure the file is within the api directory
    if ($realPath === false || strpos($realPath, $baseDir) !== 0) {
        error_log("Security: Attempted to load .env from unauthorized path: $path");
        return false;
    }
    
    if (!file_exists($realPath)) {
        return false;
    }
    
    $lines = file($realPath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    
    foreach ($lines as $line) {
        // Skip comments
        if (strpos(trim($line), '#') === 0) {
            continue;
        }
        
        // Parse KEY=VALUE
        if (strpos($line, '=') !== false) {
            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            
            // Validate key format (alphanumeric + underscore only)
            if (!preg_match('/^[A-Z_][A-Z0-9_]*$/', $key)) {
                error_log("Invalid environment variable key format: $key");
                continue;
            }
            
            // Handle quoted values (single or double quotes)
            if ((substr($value, 0, 1) === '"' && substr($value, -1) === '"') ||
                (substr($value, 0, 1) === "'" && substr($value, -1) === "'")) {
                $value = substr($value, 1, -1);
            }
            
            // Set in environment
            putenv("$key=$value");
            $_ENV[$key] = $value;
            $_SERVER[$key] = $value;
        }
    }
    
    return true;
}

// Auto-load .env if this file is included
loadEnv();
?>
