<?php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST method allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!isset($data['event_id'])) {
    echo json_encode(['success' => false, 'message' => 'Event ID is required']);
    exit;
}

calculateExpenses($data['event_id']);

function calculateExpenses($eventId) {
    global $pdo;
    
    try {
        $pdo->beginTransaction();
        
        // Get all members and their contributions
        $sql = "SELECT * FROM members WHERE event_id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$eventId]);
        $members = $stmt->fetchAll();
        
        if (count($members) < 2) {
            echo json_encode(['success' => false, 'message' => 'Minimum 2 members required']);
            return;
        }
        
        // Calculate total and average
        $totalAmount = 0;
        foreach ($members as $member) {
            $totalAmount += $member['contribution'];
        }
        
        $averageAmount = $totalAmount / count($members);
        
        // Update event totals
        $updateEventSql = "UPDATE events SET total_amount = ?, average_amount = ?, member_count = ? WHERE id = ?";
        $updateEventStmt = $pdo->prepare($updateEventSql);
        $updateEventStmt->execute([$totalAmount, $averageAmount, count($members), $eventId]);
        
        // Calculate balances for each member
        $results = [];
        foreach ($members as $member) {
            $balance = $member['contribution'] - $averageAmount;
            
            // Update member balance
            $updateMemberSql = "UPDATE members SET balance = ? WHERE id = ?";
            $updateMemberStmt = $pdo->prepare($updateMemberSql);
            $updateMemberStmt->execute([$balance, $member['id']]);
            
            $results[] = [
                'id' => $member['id'],
                'name' => $member['name'],
                'contribution' => $member['contribution'],
                'balance' => $balance,
                'should_pay' => $balance < 0 ? abs($balance) : 0,
                'should_receive' => $balance > 0 ? $balance : 0
            ];
        }
        
        $pdo->commit();
        
        echo json_encode([
            'success' => true,
            'data' => [
                'total_amount' => $totalAmount,
                'average_amount' => $averageAmount,
                'member_count' => count($members),
                'members' => $results
            ]
        ]);
        
    } catch (Exception $e) {
        $pdo->rollback();
        echo json_encode(['success' => false, 'message' => 'Calculation failed: ' . $e->getMessage()]);
    }
}
?>