let groups = {};
let activeGroupId = null;
let expenseChart = null;

// Load groups and theme from localStorage on startup
document.addEventListener('DOMContentLoaded', () => {
    loadGroupsFromLocalStorage();
    loadThemeFromLocalStorage();
    renderGroupSelector();
    selectGroup();
});

const themeToggle = document.getElementById('theme-toggle');
themeToggle.addEventListener('click', () => {
    document.body.classList.toggle('dark-mode');
    saveThemeToLocalStorage();
});

function saveThemeToLocalStorage() {
    if (document.body.classList.contains('dark-mode')) {
        localStorage.setItem('theme', 'dark');
    } else {
        localStorage.setItem('theme', 'light');
    }
}

function loadThemeFromLocalStorage() {
    const theme = localStorage.getItem('theme');
    if (theme === 'dark') {
        document.body.classList.add('dark-mode');
    }
}

function createGroup() {
    const groupNameInput = document.getElementById('groupName');
    const groupName = groupNameInput.value.trim();

    if (!groupName) {
        alert('Please enter a group name!');
        return;
    }

    const groupId = Date.now().toString();
    groups[groupId] = {
        id: groupId,
        name: groupName,
        expenses: [],
        people: [],
        currency: '৳'
    };

    activeGroupId = groupId;
    saveGroupsToLocalStorage();
    renderGroupSelector();
    selectGroup();

    groupNameInput.value = '';
}

function selectGroup() {
    const groupSelector = document.getElementById('groupSelector');
    activeGroupId = groupSelector.value;

    const groupContent = document.getElementById('group-content');
    if (activeGroupId) {
        groupContent.classList.remove('hidden');
        renderExpenses();
        calculateTotal();
        renderChart();
    } else {
        groupContent.classList.add('hidden');
    }
}

function renderGroupSelector() {
    const groupSelector = document.getElementById('groupSelector');
    groupSelector.innerHTML = '';

    for (const groupId in groups) {
        const group = groups[groupId];
        const option = document.createElement('option');
        option.value = group.id;
        option.textContent = group.name;
        groupSelector.appendChild(option);
    }

    groupSelector.value = activeGroupId;
}

function updateCurrency() {
    if (!activeGroupId) return;
    groups[activeGroupId].currency = document.getElementById('currency').value;
    saveGroupsToLocalStorage();
    renderExpenses();
    calculateTotal();
}

function setupNames() {
    if (!activeGroupId) return;

    const numPersons = document.getElementById('numPersons').value;
    if (numPersons < 2) {
        alert('You need at least 2 people to split expenses.');
        return;
    }

    const namesContainer = document.getElementById('namesContainer');
    namesContainer.innerHTML = '';
    for (let i = 0; i < numPersons; i++) {
        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = `Person ${i + 1} Name`;
        input.id = `person${i}`;
        namesContainer.appendChild(input);
    }

    document.getElementById('namesSection').classList.remove('hidden');
}

function proceedToExpenses() {
    if (!activeGroupId) return;

    const numPersons = document.getElementById('numPersons').value;
    const people = [];
    for (let i = 0; i < numPersons; i++) {
        const name = document.getElementById(`person${i}`).value.trim();
        if (!name) {
            alert('Please enter all names.');
            return;
        }
        people.push({ name, expenses: [] });
    }

    groups[activeGroupId].people = people;
    saveGroupsToLocalStorage();

    renderPeopleSection();
    document.getElementById('namesSection').classList.add('hidden');
    document.getElementById('peopleSection').classList.remove('hidden');
}

function renderPeopleSection() {
    if (!activeGroupId) return;

    const peopleContainer = document.getElementById('peopleContainer');
    peopleContainer.innerHTML = '';

    const group = groups[activeGroupId];
    group.people.forEach((person, index) => {
        const personCard = document.createElement('div');
        personCard.className = 'person-card';
        personCard.innerHTML = `
            <h3>${person.name}</h3>
            <div class="expense-input">
                <input type="text" id="expense-name-${index}" placeholder="Expense description">
                <input type="number" id="expense-amount-${index}" placeholder="Amount">
                <button class="btn" onclick="addExpense(${index})">Add</button>
            </div>
            <div class="expense-list" id="expense-list-${index}"></div>
        `;
        peopleContainer.appendChild(personCard);
        renderPersonExpenses(index);
    });
}

function addExpense(personIndex) {
    if (!activeGroupId) return;

    const expenseNameInput = document.getElementById(`expense-name-${personIndex}`);
    const expenseAmountInput = document.getElementById(`expense-amount-${personIndex}`);

    const name = expenseNameInput.value.trim();
    const amount = parseFloat(expenseAmountInput.value);

    if (!name || isNaN(amount) || amount <= 0) {
        alert('Please enter a valid expense name and amount.');
        return;
    }

    const group = groups[activeGroupId];
    group.people[personIndex].expenses.push({ name, amount });
    group.expenses.push({ name, amount }); // Also add to group expenses for chart
    saveGroupsToLocalStorage();

    renderPersonExpenses(personIndex);
    calculateTotal();
    renderChart();

    expenseNameInput.value = '';
    expenseAmountInput.value = '';
}

function renderPersonExpenses(personIndex) {
    if (!activeGroupId) return;

    const group = groups[activeGroupId];
    const expenseList = document.getElementById(`expense-list-${personIndex}`);
    expenseList.innerHTML = '';

    group.people[personIndex].expenses.forEach(expense => {
        const expenseItem = document.createElement('div');
        expenseItem.className = 'expense-item';
        expenseItem.textContent = `${expense.name}: ${group.currency}${expense.amount}`;
        expenseList.appendChild(expenseItem);
    });
}

function calculateSplit() {
    if (!activeGroupId) return;

    const group = groups[activeGroupId];
    const numPeople = group.people.length;
    if (numPeople === 0) return;

    const totalExpenses = group.expenses.reduce((sum, exp) => sum + exp.amount, 0);
    const averageExpense = totalExpenses / numPeople;

    const balances = group.people.map(person => {
        const personTotal = person.expenses.reduce((sum, exp) => sum + exp.amount, 0);
        return personTotal - averageExpense;
    });

    const summaryDiv = document.getElementById('summary');
    summaryDiv.innerHTML = `
        <div class="summary-item">Total Expenses: ${group.currency}${totalExpenses.toFixed(2)}</div>
        <div class="summary-item">Average per Person: ${group.currency}${averageExpense.toFixed(2)}</div>
    `;

    const settlementsDiv = document.getElementById('settlements');
    settlementsDiv.innerHTML = '';

    const payers = [];
    const receivers = [];

    balances.forEach((balance, i) => {
        if (balance > 0) {
            receivers.push({ name: group.people[i].name, amount: balance });
        } else if (balance < 0) {
            payers.push({ name: group.people[i].name, amount: -balance });
        }
    });

    let i = 0;
    let j = 0;

    while (i < payers.length && j < receivers.length) {
        const payer = payers[i];
        const receiver = receivers[j];
        const amount = Math.min(payer.amount, receiver.amount);

        if (amount > 0.005) { // Avoid tiny settlements
            const settlementItem = document.createElement('div');
            settlementItem.className = 'settlement-item';
            settlementItem.innerHTML = `<span class="owes">${payer.name}</span> owes <span class="gets-back">${receiver.name}</span> ${group.currency}${amount.toFixed(2)}`;
            settlementsDiv.appendChild(settlementItem);
        }

        payer.amount -= amount;
        receiver.amount -= amount;

        if (payer.amount < 0.005) {
            i++;
        }
        if (receiver.amount < 0.005) {
            j++;
        }
    }

    document.getElementById('resultsSection').classList.remove('hidden');
}

function reset() {
    if (!activeGroupId || !confirm('Are you sure you want to reset all data for this group?')) return;

    groups[activeGroupId].expenses = [];
    groups[activeGroupId].people = [];
    saveGroupsToLocalStorage();

    document.getElementById('peopleSection').classList.add('hidden');
    document.getElementById('namesSection').classList.add('hidden');
    document.getElementById('resultsSection').classList.add('hidden');
    document.getElementById('numPersons').value = '';
}

function calculateTotal() {
  if (!activeGroupId) return;

  const group = groups[activeGroupId];
  const total = group.expenses.reduce((sum, expense) => sum + expense.amount, 0);
  // This element does not exist anymore, we can remove this line or re-add the element
  // document.getElementById("totalAmount").textContent = `${group.currency}${total.toFixed(2)}`;
}

function renderChart() {
    if (!activeGroupId) return;

    const group = groups[activeGroupId];
    const ctx = document.getElementById('expenseChart').getContext('2d');

    if (expenseChart) {
        expenseChart.destroy();
    }

    expenseChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: group.expenses.map(e => e.name),
            datasets: [{
                label: 'Expenses',
                data: group.expenses.map(e => e.amount),
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(255, 206, 86, 0.2)',
                    'rgba(75, 192, 192, 0.2)',
                    'rgba(153, 102, 255, 0.2)',
                    'rgba(255, 159, 64, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)',
                    'rgba(153, 102, 255, 1)',
                    'rgba(255, 159, 64, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

function saveGroupsToLocalStorage() {
    localStorage.setItem('groups', JSON.stringify(groups));
    localStorage.setItem('activeGroupId', activeGroupId);
}

function loadGroupsFromLocalStorage() {
    const storedGroups = localStorage.getItem('groups');
    if (storedGroups) {
        groups = JSON.parse(storedGroups);
        activeGroupId = localStorage.getItem('activeGroupId');
    }
}

function exportToCSV() {
    if (!activeGroupId) return;

    const group = groups[activeGroupId];
    let csvContent = "data:text/csv;charset=utf-8,";
    csvContent += "Expense Name,Amount\n";

    group.expenses.forEach(expense => {
        csvContent += `${expense.name},${expense.amount}\n`;
    });

    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", `${group.name}_expenses.csv`);
    document.body.appendChild(link); 
    link.click();
}

function exportToPDF() {
    if (!activeGroupId) return;

    const group = groups[activeGroupId];
    const { jsPDF } = window.jspdf;
    const doc = new jsPDF();

    doc.autoTable({
        head: [['Expense Name', 'Amount']],
        body: group.expenses.map(e => [e.name, e.amount]),
    });

    doc.save(`${group.name}_expenses.pdf`);
}

function settlementSuggestions() {
    alert("Settlement suggestions with QR/UPI is coming soon!");
}
