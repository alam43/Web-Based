// Global variables
let currentEvent = null;
let members = [];
let chart = null;

// Currency symbols
const currencySymbols = {
    'USD': '$',
    'BDT': '৳',
    'AED': 'د.إ',
    'GBP': '£'
};

// DOM elements
const eventForm = document.getElementById('eventForm');
const groupSection = document.getElementById('groupSection');
const contributionsSection = document.getElementById('contributionsSection');
const resultsSection = document.getElementById('resultsSection');

// Event listeners
eventForm.addEventListener('submit', createEvent);

async function createEvent(e) {
    e.preventDefault();
    
    const eventName = document.getElementById('eventName').value;
    const currency = document.getElementById('currency').value;
    
    try {
        const response = await fetch('api/events.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                name: eventName,
                currency: currency
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            currentEvent = {
                id: result.event_id,
                name: eventName,
                currency: currency
            };
            
            groupSection.style.display = 'block';
            eventForm.style.display = 'none';
            members = [];
            updateMembersList();
        } else {
            alert('Error creating event: ' + result.message);
        }
    } catch (error) {
        alert('Error creating event: ' + error.message);
    }
}

async function addMember() {
    const memberNameInput = document.getElementById('memberName');
    const memberName = memberNameInput.value.trim();
    
    if (!memberName) {
        alert('Please enter a member name');
        return;
    }
    
    if (members.length >= 30) {
        alert('Maximum 30 members allowed');
        return;
    }
    
    if (members.some(member => member.name === memberName)) {
        alert('Member already exists');
        return;
    }
    
    try {
        const response = await fetch('api/members.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                event_id: currentEvent.id,
                name: memberName
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            members.push({
                id: result.member_id,
                name: memberName,
                contribution: 0
            });
            
            memberNameInput.value = '';
            updateMembersList();
            
            if (members.length >= 2) {
                showContributionsSection();
            }
        } else {
            alert('Error adding member: ' + result.message);
        }
    } catch (error) {
        alert('Error adding member: ' + error.message);
    }
}

function updateMembersList() {
    const membersList = document.getElementById('membersUL');
    const memberCount = document.getElementById('memberCount');
    
    membersList.innerHTML = '';
    
    members.forEach((member, index) => {
        const li = document.createElement('li');
        li.innerHTML = `
            ${member.name}
            <button onclick="removeMember(${index})" class="remove-btn">Remove</button>
        `;
        membersList.appendChild(li);
    });
    
    memberCount.textContent = members.length;
}

async function removeMember(index) {
    const member = members[index];
    
    try {
        const response = await fetch('api/members.php', {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                id: member.id
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            members.splice(index, 1);
            updateMembersList();
            
            if (members.length < 2) {
                contributionsSection.style.display = 'none';
                resultsSection.style.display = 'none';
            } else {
                showContributionsSection();
            }
        } else {
            alert('Error removing member: ' + result.message);
        }
    } catch (error) {
        alert('Error removing member: ' + error.message);
    }
}

function showContributionsSection() {
    const contributionsForm = document.getElementById('contributionsForm');
    const symbol = currencySymbols[currentEvent.currency];
    
    contributionsForm.innerHTML = '';
    
    members.forEach((member, index) => {
        const div = document.createElement('div');
        div.className = 'contribution-input';
        div.innerHTML = `
            <label for="contribution-${index}">${member.name}:</label>
            <input type="number" 
                   id="contribution-${index}" 
                   step="0.01" 
                   min="0" 
                   value="${member.contribution}"
                   placeholder="0.00">
            <span class="currency-symbol">${symbol}</span>
        `;
        contributionsForm.appendChild(div);
    });
    
    contributionsSection.style.display = 'block';
    document.getElementById('calculateBtn').style.display = 'block';
}

async function calculateExpenses() {
    // Get contributions from form
    members.forEach((member, index) => {
        const contributionInput = document.getElementById(`contribution-${index}`);
        member.contribution = parseFloat(contributionInput.value) || 0;
    });
    
    // Update member contributions in database
    for (const member of members) {
        try {
            await fetch('api/members.php', {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    id: member.id,
                    contribution: member.contribution
                })
            });
        } catch (error) {
            console.error('Error updating member contribution:', error);
        }
    }
    
    // Calculate expenses
    try {
        const response = await fetch('api/calculate.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                event_id: currentEvent.id
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            displayResults(result.data);
        } else {
            alert('Error calculating expenses: ' + result.message);
        }
    } catch (error) {
        alert('Error calculating expenses: ' + error.message);
    }
}

function displayResults(data) {
    const symbol = currencySymbols[currentEvent.currency];
    
    document.getElementById('totalAmount').textContent = `${symbol}${data.total_amount.toFixed(2)}`;
    document.getElementById('averageAmount').textContent = `${symbol}${data.average_amount.toFixed(2)}`;
    
    const payersList = document.getElementById('payersList');
    const receiversList = document.getElementById('receiversList');
    
    payersList.innerHTML = '';
    receiversList.innerHTML = '';
    
    data.members.forEach(member => {
        if (member.should_pay > 0) {
            const li = document.createElement('li');
            li.textContent = `${member.name}: ${symbol}${member.should_pay.toFixed(2)}`;
            payersList.appendChild(li);
        } else if (member.should_receive > 0) {
            const li = document.createElement('li');
            li.textContent = `${member.name}: ${symbol}${member.should_receive.toFixed(2)}`;
            receiversList.appendChild(li);
        }
    });
    
    // Store data for chart
    window.expenseData = data;
    
    resultsSection.style.display = 'block';
}

function showChart(type) {
    const ctx = document.getElementById('expenseChart').getContext('2d');
    const data = window.expenseData;
    
    if (chart) {
        chart.destroy();
    }
    
    const labels = data.members.map(member => member.name);
    const contributions = data.members.map(member => member.contribution);
    
    const colors = [
        '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0',
        '#9966FF', '#FF9F40', '#FF6384', '#C9CBCF',
        '#4BC0C0', '#FF6384', '#36A2EB', '#FFCE56'
    ];
    
    if (type === 'pie') {
        chart = new Chart(ctx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: contributions,
                    backgroundColor: colors,
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Member Contributions'
                    },
                    legend: {
                        position: 'bottom'
                    }
                }
            }
        });
    } else if (type === 'bar') {
        chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: `Contributions (${currencySymbols[currentEvent.currency]})`,
                    data: contributions,
                    backgroundColor: colors,
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Member Contributions'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });
    }
}

async function saveEvent() {
    try {
        // Event is already saved, just show confirmation
        alert('Event saved successfully!');
        
        // Reset form for new event
        resetForm();
    } catch (error) {
        alert('Error saving event: ' + error.message);
    }
}

function resetForm() {
    currentEvent = null;
    members = [];
    
    eventForm.style.display = 'block';
    groupSection.style.display = 'none';
    contributionsSection.style.display = 'none';
    resultsSection.style.display = 'none';
    
    document.getElementById('eventName').value = '';
    document.getElementById('currency').value = 'USD';
    
    if (chart) {
        chart.destroy();
        chart = null;
    }
}