<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        getMembers();
        break;
    case 'POST':
        addMember();
        break;
    case 'PUT':
        updateMember();
        break;
    case 'DELETE':
        deleteMember();
        break;
}

function getMembers() {
    global $pdo;
    
    if (!isset($_GET['event_id'])) {
        echo json_encode(['success' => false, 'message' => 'Event ID is required']);
        return;
    }
    
    $sql = "SELECT * FROM members WHERE event_id = ? ORDER BY name";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$_GET['event_id']]);
    $members = $stmt->fetchAll();
    
    echo json_encode(['success' => true, 'data' => $members]);
}

function addMember() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['event_id']) || !isset($data['name'])) {
        echo json_encode(['success' => false, 'message' => 'Event ID and name are required']);
        return;
    }
    
    // Check if member already exists in this event
    $checkSql = "SELECT COUNT(*) FROM members WHERE event_id = ? AND name = ?";
    $checkStmt = $pdo->prepare($checkSql);
    $checkStmt->execute([$data['event_id'], $data['name']]);
    
    if ($checkStmt->fetchColumn() > 0) {
        echo json_encode(['success' => false, 'message' => 'Member already exists in this event']);
        return;
    }
    
    // Check member count limit
    $countSql = "SELECT COUNT(*) FROM members WHERE event_id = ?";
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute([$data['event_id']]);
    $memberCount = $countStmt->fetchColumn();
    
    if ($memberCount >= 30) {
        echo json_encode(['success' => false, 'message' => 'Maximum 30 members allowed']);
        return;
    }
    
    $sql = "INSERT INTO members (event_id, name, contribution) VALUES (?, ?, ?)";
    $stmt = $pdo->prepare($sql);
    $contribution = isset($data['contribution']) ? $data['contribution'] : 0;
    
    if ($stmt->execute([$data['event_id'], $data['name'], $contribution])) {
        $memberId = $pdo->lastInsertId();
        echo json_encode(['success' => true, 'member_id' => $memberId]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to add member']);
    }
}

function updateMember() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        echo json_encode(['success' => false, 'message' => 'Member ID is required']);
        return;
    }
    
    $sql = "UPDATE members SET ";
    $params = [];
    $setParts = [];
    
    if (isset($data['name'])) {
        $setParts[] = "name = ?";
        $params[] = $data['name'];
    }
    
    if (isset($data['contribution'])) {
        $setParts[] = "contribution = ?";
        $params[] = $data['contribution'];
    }
    
    if (isset($data['balance'])) {
        $setParts[] = "balance = ?";
        $params[] = $data['balance'];
    }
    
    $sql .= implode(', ', $setParts) . " WHERE id = ?";
    $params[] = $data['id'];
    
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute($params)) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update member']);
    }
}

function deleteMember() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        echo json_encode(['success' => false, 'message' => 'Member ID is required']);
        return;
    }
    
    $sql = "DELETE FROM members WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$data['id']])) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete member']);
    }
}
?>