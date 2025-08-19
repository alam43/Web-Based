<?php
require_once 'config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch($method) {
    case 'GET':
        if (isset($_GET['id'])) {
            getEvent($_GET['id']);
        } else {
            getAllEvents();
        }
        break;
    case 'POST':
        createEvent();
        break;
    case 'PUT':
        updateEvent();
        break;
    case 'DELETE':
        deleteEvent();
        break;
}

function getAllEvents() {
    global $pdo;
    
    $sql = "SELECT e.*, COUNT(m.id) as actual_member_count 
            FROM events e 
            LEFT JOIN members m ON e.id = m.event_id 
            GROUP BY e.id 
            ORDER BY e.created_at DESC";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
    $events = $stmt->fetchAll();
    
    echo json_encode(['success' => true, 'data' => $events]);
}

function getEvent($id) {
    global $pdo;
    
    $sql = "SELECT * FROM events WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$id]);
    $event = $stmt->fetch();
    
    if ($event) {
        // Get members for this event
        $sql = "SELECT * FROM members WHERE event_id = ? ORDER BY name";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$id]);
        $members = $stmt->fetchAll();
        
        $event['members'] = $members;
        echo json_encode(['success' => true, 'data' => $event]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Event not found']);
    }
}

function createEvent() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['name']) || !isset($data['currency'])) {
        echo json_encode(['success' => false, 'message' => 'Name and currency are required']);
        return;
    }
    
    $sql = "INSERT INTO events (name, currency) VALUES (?, ?)";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$data['name'], $data['currency']])) {
        $eventId = $pdo->lastInsertId();
        echo json_encode(['success' => true, 'event_id' => $eventId]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to create event']);
    }
}

function updateEvent() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        echo json_encode(['success' => false, 'message' => 'Event ID is required']);
        return;
    }
    
    $sql = "UPDATE events SET ";
    $params = [];
    $setParts = [];
    
    if (isset($data['name'])) {
        $setParts[] = "name = ?";
        $params[] = $data['name'];
    }
    
    if (isset($data['total_amount'])) {
        $setParts[] = "total_amount = ?";
        $params[] = $data['total_amount'];
    }
    
    if (isset($data['average_amount'])) {
        $setParts[] = "average_amount = ?";
        $params[] = $data['average_amount'];
    }
    
    if (isset($data['member_count'])) {
        $setParts[] = "member_count = ?";
        $params[] = $data['member_count'];
    }
    
    $sql .= implode(', ', $setParts) . " WHERE id = ?";
    $params[] = $data['id'];
    
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute($params)) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to update event']);
    }
}

function deleteEvent() {
    global $pdo;
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['id'])) {
        echo json_encode(['success' => false, 'message' => 'Event ID is required']);
        return;
    }
    
    $sql = "DELETE FROM events WHERE id = ?";
    $stmt = $pdo->prepare($sql);
    
    if ($stmt->execute([$data['id']])) {
        echo json_encode(['success' => true]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to delete event']);
    }
}
?>