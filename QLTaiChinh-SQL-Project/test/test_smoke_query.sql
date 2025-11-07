-- 1) kiểm tra row counts
SELECT table_name, table_rows
FROM (
  SELECT 'users' as table_name, count(*) as table_rows FROM users
  UNION ALL
  SELECT 'accounts', count(*) FROM accounts
  UNION ALL
  SELECT 'transactions', count(*) FROM transactions
) t;

-- 2) kiểm tra FK
SELECT fk.name AS FK_Name, tp.name AS ParentTable, tr.name AS ReferencedTable
FROM sys.foreign_keys AS fk
JOIN sys.tables AS tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables AS tr ON fk.referenced_object_id = tr.object_id;

-- 3) Kiểm tra Nulls
SELECT COUNT(*) AS NullEmails FROM Users WHERE Email IS NULL;

-- 4) kiểm tra join relationships
SELECT TOP 10 
    u.UserId, u.Email, a.AccountId, t.TransactionId, t.Amount
FROM Users u
LEFT JOIN Accounts a ON u.UserId = a.UserId
LEFT JOIN Transactions t ON a.AccountId = t.AccountId;

-- 5) kiểm tra unique duplicates
SELECT Email, COUNT(*) AS CountEmail
FROM Users
GROUP BY Email
HAVING COUNT(*) > 1;

-- 6) kiểm tra Users không có transactions
SELECT u.UserId, u.Email, count(t.Amount) as Count_Transaction
FROM Users u
LEFT JOIN Accounts a ON u.UserId = a.UserId
LEFT JOIN Transactions t ON a.AccountId = t.AccountId
WHERE t.TransactionId IS NULL
Group by u.UserId, u.Email;