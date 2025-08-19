// Currency symbols
const currencySymbols = {
    'USD': '$',
    'BDT': '৳',
    'AED': 'د.إ',
    'GBP': '£'
};

// Load events when page loads
document.addEventListener('DOMContentLoaded', loadEvents);

async function loadEvents() {
    try {
        const response = await fetch('api/events.php');
        const result = await response.json();
        
        if (result.success) {
            displayEvents(result.data);
        } else {
            document.getElementById('eventsList').innerHTML = '<div class="error">Failed to load events</div>';
        }
    } catch (error) {
        document.getElementById('eventsList').innerHTML = '<div class="error">Error loading events: ' + error.message + '</div>';
    }
}

function displayEvents(events) {
    const eventsList = document.getElementById('eventsList');
    
    if (events.length === 0) {
        eventsList.innerHTML = '<div class="no-events">No events found</div>';
        return;
    }
    
    eventsList.innerHTML = '';
    
    events.forEach(event => {
        const eventDiv = document.createElement('div');
        eventDiv.className = 'event-card';
        
        const symbol = currencySymbols[event.currency];
        const createdDate = new Date(event.created_at).toLocaleDateString();
        
        eventDiv.innerHTML = `
            <div class="event-header">
                <h3>${event.name}</h3>
                <span class="event-date">${createdDate}</span>
            </div>
            <div class="event-details">
                <div class="detail-item">
                    <span class="label">Currency:</span>
                    <span class="value">${event.currency}</span>
                </div>
                <div class="detail-item">
                    <span class="label">Total Amount:</span>
                    <span class="value">${symbol}${parseFloat(event.total_amount || 0).toFixed(2)}</span>
                </div>
                <div class="detail-item">
                    <span class="label">Members:</span>
                    <span class="value">${event.actual_member_count || 0}</span>
                </div>
                <div class="detail-item">
                    <span class="label">Average:</span>
                    <span class="value">${symbol}${parseFloat(event.average_amount || 0).toFixed(2)}</span>
                </div>
            </div>
            <div class="event-actions">
                <button onclick="viewEventDetails(${event.id})" class="view-btn">View Details</button>
                <button onclick="deleteEvent(${event.id})" class="delete-btn">Delete</button>
            </div>
        `;
        
        eventsList.appendChild(eventDiv);
    });
}

async function viewEventDetails(eventId) {
    try {
        const response = await fetch(`api/events.php?id=${eventId}`);
        const result = await response.json();
        
        if (result.success) {
            showEventModal(result.data);
        } else {
            alert('Failed to load event details');
        }
    } catch (error) {
        alert('Error loading event details: ' + error.message);
    }
}

function showEventModal(event) {
    const modal = document.getElementById('eventModal');
    const modalContent = document.getElementById('modalContent');
    
    const symbol = currencySymbols[event.currency];
    const createdDate = new Date(event.created_at).toLocaleDateString();
    
    let membersHtml = '';
    if (event.members && event.members.length > 0) {
        membersHtml = `
            <div class="members-section">
                <h4>Members and Contributions:</h4>
                <table class="members-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Contribution</th>
                            <th>Balance</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
        `;
        
        event.members.forEach(member => {
            const balance = parseFloat(member.balance || 0);
            const status = balance > 0 ? 'Should Receive' : balance < 0 ? 'Should Pay' : 'Even';
            const statusClass = balance > 0 ? 'positive' : balance < 0 ? 'negative' : 'neutral';
            
            membersHtml += `
                <tr>
                    <td>${member.name}</td>
                    <td>${symbol}${parseFloat(member.contribution || 0).toFixed(2)}</td>
                    <td class="${statusClass}">${symbol}${Math.abs(balance).toFixed(2)}</td>
                    <td class="${statusClass}">${status}</td>
                </tr>
            `;
        });
        
        membersHtml += `
                    </tbody>
                </table>
            </div>
        `;
    }
    
    modalContent.innerHTML = `
        <h2>${event.name}</h2>
        <div class="event-summary">
            <div class="summary-item">
                <span class="label">Created:</span>
                <span class="value">${createdDate}</span>
            </div>
            <div class="summary-item">
                <span class="label">Currency:</span>
                <span class="value">${event.currency}</span>
            </div>
            <div class="summary-item">
                <span class="label">Total Amount:</span>
                <span class="value">${symbol}${parseFloat(event.total_amount || 0).toFixed(2)}</span>
            </div>
            <div class="summary-item">
                <span class="label">Average per Person:</span>
                <span class="value">${symbol}${parseFloat(event.average_amount || 0).toFixed(2)}</span>
            </div>
        </div>
        ${membersHtml}
    `;
    
    modal.style.display = 'block';
}

function closeModal() {
    document.getElementById('eventModal').style.display = 'none';
}

async function deleteEvent(eventId) {
    if (!confirm('Are you sure you want to delete this event? This action cannot be undone.')) {
        return;
    }
    
    try {
        const response = await fetch('api/events.php', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                id: eventId
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            alert('Event deleted successfully');
            loadEvents(); // Reload the events list
        } else {
            alert('Failed to delete event: ' + result.message);
        }
    } catch (error) {
        alert('Error deleting event: ' + error.message);
    }
}

function filterEvents() {
    const currencyFilter = document.getElementById('currencyFilter').value;
    const dateFilter = document.getElementById('dateFilter').value;
    
    // You can implement filtering logic here
    // For now, we'll just reload all events
    loadEvents();
}

function clearFilters() {
    document.getElementById('currencyFilter').value = '';
    document.getElementById('dateFilter').value = '';
    loadEvents();
}

// Close modal when clicking outside of it
window.onclick = function(event) {
    const modal = document.getElementById('eventModal');
    if (event.target === modal) {
        closeModal();
    }
}