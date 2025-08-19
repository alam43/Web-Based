-- Group Expense Manager Database Reset Script
-- Use this to completely reset the database and start fresh

-- Use the database
USE group_expense_manager;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Clear all data from tables
TRUNCATE TABLE transactions;
TRUNCATE TABLE members;
TRUNCATE TABLE events;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Reset auto-increment counters
ALTER TABLE events AUTO_INCREMENT = 1;
ALTER TABLE members AUTO_INCREMENT = 1;
ALTER TABLE transactions AUTO_INCREMENT = 1;

-- Display reset confirmation
SELECT 'Database reset completed!' as message,
       'All data has been cleared' as note,
       'Tables are ready for new data' as status;