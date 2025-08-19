# Group Expense Manager

A web-based application for managing group expenses with multi-currency support, contribution tracking, and visual analytics.

## Features

- **Event Management**: Create events with customizable names and currency selection
- **Group Management**: Add 2-30 members per event with easy member management
- **Multi-Currency Support**: Supports USD ($), BDT (৳), AED (د.إ), and GBP (£)
- **Expense Calculation**: Automatically calculates total expenses, averages, and individual balances
- **Visual Analytics**: Interactive pie charts and bar graphs using Chart.js
- **Event History**: View and manage all past events with detailed member information
- **Responsive Design**: Works seamlessly on desktop and mobile devices

## Technology Stack

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: PHP
- **Database**: MySQL
- **Charts**: Chart.js
- **Design**: Responsive CSS Grid and Flexbox

## Installation

### Prerequisites

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Web server (Apache/Nginx) or local development environment (XAMPP/WAMP)

### Setup Instructions

1. **Clone or download the project files**
   ```
   git clone [repository-url]
   cd Web-Based
   ```

2. **Database Setup**
   - Create a MySQL database named `group_expense_manager`
   - Import the database schema:
   ```sql
   mysql -u username -p group_expense_manager < database.sql
   ```

3. **Configure Database Connection**
   - Edit `api/config.php` and update the database credentials:
   ```php
   $servername = "localhost";
   $username = "your_username";
   $password = "your_password";
   $dbname = "group_expense_manager";
   ```

4. **Web Server Setup**
   - Place the project files in your web server's document root
   - Ensure PHP has proper permissions to access the files
   - Make sure mod_rewrite is enabled if using Apache

5. **Access the Application**
   - Open your browser and navigate to `http://localhost/Web-Based/`
   - Start creating events and managing group expenses!

## Usage

### Creating an Event

1. Enter an event name (e.g., "Dinner Party", "Movie Night")
2. Select the currency for the event
3. Click "Create Event"

### Managing Members

1. Add members one by one (minimum 2, maximum 30)
2. Remove members if needed
3. Proceed to contributions when you have at least 2 members

### Recording Contributions

1. Enter the amount each member contributed
2. Click "Calculate Expenses" to see the results
3. View who owes money and who should receive money

### Viewing Analytics

1. After calculation, choose between pie chart or bar graph
2. Charts show visual representation of member contributions
3. Save the event to preserve the data

### Event History

1. Navigate to the History page
2. View all past events with summary information
3. Click "View Details" to see complete event information
4. Delete events if no longer needed

## Database Schema

### Events Table
- `id`: Primary key
- `name`: Event name
- `currency`: Currency type (USD, BDT, AED, GBP)
- `total_amount`: Total contributions
- `average_amount`: Average per person
- `member_count`: Number of members
- `created_at`, `updated_at`: Timestamps

### Members Table
- `id`: Primary key
- `event_id`: Foreign key to events
- `name`: Member name
- `contribution`: Amount contributed
- `balance`: Calculated balance (positive = should receive, negative = should pay)
- `created_at`: Timestamp

### Transactions Table
- `id`: Primary key
- `event_id`, `member_id`: Foreign keys
- `amount`: Transaction amount
- `transaction_type`: Type of transaction
- `description`: Transaction description
- `created_at`: Timestamp

## API Endpoints

### Events
- `GET api/events.php` - Get all events
- `GET api/events.php?id={id}` - Get specific event
- `POST api/events.php` - Create new event
- `PUT api/events.php` - Update event
- `DELETE api/events.php` - Delete event

### Members
- `GET api/members.php?event_id={id}` - Get event members
- `POST api/members.php` - Add member
- `PUT api/members.php` - Update member
- `DELETE api/members.php` - Remove member

### Calculations
- `POST api/calculate.php` - Calculate expense distribution

## Currency Support

The application supports the following currencies:
- **USD** ($) - US Dollar
- **BDT** (৳) - Bangladeshi Taka
- **AED** (د.إ) - UAE Dirham
- **GBP** (£) - British Pound

## Security Features

- SQL injection prevention using prepared statements
- Input validation and sanitization
- CORS headers for API security
- Error handling and user feedback

## Browser Compatibility

- Chrome 60+
- Firefox 55+
- Safari 11+
- Edge 79+

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or feature requests, please create an issue in the project repository.