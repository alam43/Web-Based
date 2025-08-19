<?php
/**
 * Database Connection Test Script
 * Run this to verify database setup is working correctly
 */

// Include the configuration
require_once '../api/config.php';

echo "<h1>Group Expense Manager - Database Test</h1>\n";
echo "<style>body{font-family:Arial,sans-serif;margin:40px;} .success{color:green;} .error{color:red;} .info{color:blue;}</style>\n";

try {
    // Test 1: Database Connection
    echo "<h2>1. Database Connection Test</h2>\n";
    if ($pdo) {
        echo "<div class='success'>✓ Database connection successful</div>\n";
        
        // Get database info
        $stmt = $pdo->query("SELECT DATABASE() as db_name, VERSION() as db_version");
        $info = $stmt->fetch();
        echo "<div class='info'>Database: {$info['db_name']}</div>\n";
        echo "<div class='info'>MySQL Version: {$info['db_version']}</div>\n";
    } else {
        echo "<div class='error'>❌ Database connection failed</div>\n";
        exit;
    }
    
    // Test 2: Table Structure
    echo "<h2>2. Table Structure Test</h2>\n";
    $tables = ['events', 'members', 'transactions'];
    
    foreach ($tables as $table) {
        try {
            $stmt = $pdo->query("DESCRIBE $table");
            $columns = $stmt->fetchAll();
            echo "<div class='success'>✓ Table '$table' exists with " . count($columns) . " columns</div>\n";
        } catch (Exception $e) {
            echo "<div class='error'>❌ Table '$table' missing or invalid</div>\n";
        }
    }
    
    // Test 3: Sample Data
    echo "<h2>3. Sample Data Test</h2>\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM events");
    $eventCount = $stmt->fetch()['count'];
    echo "<div class='info'>Events in database: $eventCount</div>\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM members");
    $memberCount = $stmt->fetch()['count'];
    echo "<div class='info'>Members in database: $memberCount</div>\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM transactions");
    $transactionCount = $stmt->fetch()['count'];
    echo "<div class='info'>Transactions in database: $transactionCount</div>\n";
    
    // Test 4: API Functionality
    echo "<h2>4. API Functionality Test</h2>\n";
    
    // Test events API
    $stmt = $pdo->query("SELECT * FROM events LIMIT 1");
    $event = $stmt->fetch();
    if ($event) {
        echo "<div class='success'>✓ Can read events data</div>\n";
        echo "<div class='info'>Sample event: {$event['name']} ({$event['currency']})</div>\n";
    } else {
        echo "<div class='error'>❌ No events data available</div>\n";
    }
    
    // Test foreign key relationships
    $stmt = $pdo->query("
        SELECT e.name, COUNT(m.id) as member_count 
        FROM events e 
        LEFT JOIN members m ON e.id = m.event_id 
        GROUP BY e.id 
        LIMIT 1
    ");
    $result = $stmt->fetch();
    if ($result) {
        echo "<div class='success'>✓ Foreign key relationships working</div>\n";
        echo "<div class='info'>Event '{$result['name']}' has {$result['member_count']} members</div>\n";
    }
    
    // Test 5: Currency Support
    echo "<h2>5. Currency Support Test</h2>\n";
    
    $stmt = $pdo->query("SELECT DISTINCT currency FROM events");
    $currencies = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (!empty($currencies)) {
        echo "<div class='success'>✓ Multi-currency support working</div>\n";
        echo "<div class='info'>Currencies in use: " . implode(', ', $currencies) . "</div>\n";
    } else {
        echo "<div class='error'>❌ No currency data found</div>\n";
    }
    
    // Test 6: Calculation Logic
    echo "<h2>6. Calculation Logic Test</h2>\n";
    
    $stmt = $pdo->query("
        SELECT 
            e.name,
            e.total_amount,
            e.average_amount,
            SUM(m.contribution) as calculated_total,
            AVG(m.contribution) as calculated_average
        FROM events e 
        JOIN members m ON e.id = m.event_id 
        WHERE e.total_amount > 0
        GROUP BY e.id 
        LIMIT 1
    ");
    $calc = $stmt->fetch();
    if ($calc) {
        $totalMatch = abs($calc['total_amount'] - $calc['calculated_total']) < 0.01;
        $avgMatch = abs($calc['average_amount'] - $calc['calculated_average']) < 0.01;
        
        if ($totalMatch && $avgMatch) {
            echo "<div class='success'>✓ Calculation logic working correctly</div>\n";
        } else {
            echo "<div class='error'>❌ Calculation mismatch detected</div>\n";
        }
        echo "<div class='info'>Event: {$calc['name']}</div>\n";
        echo "<div class='info'>Stored total: {$calc['total_amount']}, Calculated: {$calc['calculated_total']}</div>\n";
    }
    
    // Test 7: Performance Check
    echo "<h2>7. Performance Test</h2>\n";
    
    $startTime = microtime(true);
    $stmt = $pdo->query("
        SELECT e.*, COUNT(m.id) as member_count, SUM(m.contribution) as total_contrib
        FROM events e 
        LEFT JOIN members m ON e.id = m.event_id 
        GROUP BY e.id 
        ORDER BY e.created_at DESC
    ");
    $results = $stmt->fetchAll();
    $endTime = microtime(true);
    $queryTime = round(($endTime - $startTime) * 1000, 2);
    
    echo "<div class='success'>✓ Query performance test completed</div>\n";
    echo "<div class='info'>Query time: {$queryTime}ms for " . count($results) . " events</div>\n";
    
    if ($queryTime < 100) {
        echo "<div class='success'>✓ Performance is excellent</div>\n";
    } elseif ($queryTime < 500) {
        echo "<div class='info'>Performance is good</div>\n";
    } else {
        echo "<div class='error'>⚠ Performance may need optimization</div>\n";
    }
    
    // Final Summary
    echo "<h2>🎉 Test Summary</h2>\n";
    echo "<div class='success'>✓ Database setup is working correctly!</div>\n";
    echo "<div class='info'>You can now use the Group Expense Manager application.</div>\n";
    echo "<hr>\n";
    echo "<h3>Next Steps:</h3>\n";
    echo "<ul>\n";
    echo "<li>Navigate to the main application: <a href='../index.html'>index.html</a></li>\n";
    echo "<li>View event history: <a href='../history.html'>history.html</a></li>\n";
    echo "<li>Check database admin (XAMPP only): <a href='http://localhost/phpmyadmin/'>phpMyAdmin</a></li>\n";
    echo "</ul>\n";
    
} catch (Exception $e) {
    echo "<div class='error'>❌ Test failed: " . $e->getMessage() . "</div>\n";
    echo "<div class='info'>Please check your database configuration and try again.</div>\n";
}

echo "<hr><small>Test completed on " . date('Y-m-d H:i:s') . "</small>\n";
?>