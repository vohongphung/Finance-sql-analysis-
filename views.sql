-- Tổng thu nhập và chi tiêu theo tháng
CREATE OR ALTER VIEW v_MonthlyIncomeExpense_ByCurrency AS
SELECT 
    FORMAT(t.TransactionDate, 'yyyy-MM') AS [Month],
    t.Currency,
    SUM(CASE WHEN c.CategoryType = N'Thu nhập' THEN t.Amount ELSE 0 END) AS Total_Income,
    SUM(CASE WHEN c.CategoryType = N'Chi trả' THEN t.Amount ELSE 0 END) AS Total_Expense,
    SUM(
        CASE 
            WHEN c.CategoryType = N'Thu nhập' THEN t.Amount
            WHEN c.CategoryType = N'Chi trả' THEN -t.Amount
            ELSE 0 
        END
    ) AS Net_Balance,
   
    CAST(FORMAT(MIN(t.TransactionDate), 'yyyyMM') AS INT) * 10 +
      CASE t.Currency 
           WHEN 'USD' THEN 1 
           WHEN 'VND' THEN 2 
           WHEN 'EUR' THEN 3 
           ELSE 9 
      END AS SortKey

FROM Transactions AS t
LEFT JOIN Categories AS c ON t.CategoryId = c.CategoryId
GROUP BY FORMAT(t.TransactionDate, 'yyyy-MM'), t.Currency;
go
-- Top loại chi tiêu hàng đầu
CREATE OR ALTER VIEW v_TopExpenseCategories_CurrencyPivot AS
SELECT 
    c.CategoryName,

    -- pivot by currency
    SUM(CASE WHEN t.Currency = 'USD' THEN t.Amount ELSE 0 END) AS USD_Spent,
    SUM(CASE WHEN t.Currency = 'VND' THEN t.Amount ELSE 0 END) AS VND_Spent,
    SUM(CASE WHEN t.Currency = 'EUR' THEN t.Amount ELSE 0 END) AS EUR_Spent
FROM Transactions AS t
JOIN Categories AS c ON t.CategoryId = c.CategoryId
WHERE c.CategoryType = N'Chi trả'
GROUP BY c.CategoryName;
go
-- Tổng loại chi tiêu theo tháng
CREATE OR ALTER VIEW v_MonthlyExpenseCategories_CurrencyPivot AS
SELECT 
    FORMAT(t.TransactionDate, 'yyyy-MM') AS [Month],
    c.CategoryName,

    -- pivot by currency
    SUM(CASE WHEN t.Currency = 'USD' THEN t.Amount ELSE 0 END) AS USD_Spent,
    SUM(CASE WHEN t.Currency = 'VND' THEN t.Amount ELSE 0 END) AS VND_Spent,
    SUM(CASE WHEN t.Currency = 'EUR' THEN t.Amount ELSE 0 END) AS EUR_Spent

FROM Transactions AS t
JOIN Categories AS c 
    ON t.CategoryId = c.CategoryId
WHERE c.CategoryType = N'Chi trả'
GROUP BY 
    FORMAT(t.TransactionDate, 'yyyy-MM'),
    c.CategoryName;
go
-- Xu hướng chi tiêu trung bình hàng tháng
CREATE OR ALTER VIEW v_AvgMonthlySpend_CurrencyPivot AS
SELECT 
    u.FullName,

    -- Average per currency (only months with data)
    AVG(monthly.USD_Total) AS USD_AvgMonthly,
    AVG(monthly.VND_Total) AS VND_AvgMonthly,
    AVG(monthly.EUR_Total) AS EUR_AvgMonthly

FROM Users AS u
JOIN (
    SELECT 
        a.UserId,
        FORMAT(t.TransactionDate, 'yyyy-MM') AS [Month],

        -- Pivot by currency
        SUM(CASE WHEN t.Currency = 'USD' THEN t.Amount ELSE 0 END) AS USD_Total,
        SUM(CASE WHEN t.Currency = 'VND' THEN t.Amount ELSE 0 END) AS VND_Total,
        SUM(CASE WHEN t.Currency = 'EUR' THEN t.Amount ELSE 0 END) AS EUR_Total
    FROM Transactions AS t
    JOIN Accounts AS a ON t.AccountId = a.AccountId
    GROUP BY a.UserId, FORMAT(t.TransactionDate, 'yyyy-MM')
) AS monthly ON u.UserId = monthly.UserId
GROUP BY u.FullName;
GO
--Xu hướng chi tiêu trung bình hàng năm
CREATE OR ALTER VIEW v_AvgYearlySpend_CurrencyPivot AS
SELECT 
    u.FullName,

    -- Average spend per active year (only years with data)
    AVG(yearly.USD_Total) AS USD_AvgYearly,
    AVG(yearly.VND_Total) AS VND_AvgYearly,
    AVG(yearly.EUR_Total) AS EUR_AvgYearly

FROM Users AS u
JOIN (
    SELECT 
        a.UserId,
        YEAR(t.TransactionDate) AS [Year],

        -- Pivot by currency
        SUM(CASE WHEN t.Currency = 'USD' THEN t.Amount ELSE 0 END) AS USD_Total,
        SUM(CASE WHEN t.Currency = 'VND' THEN t.Amount ELSE 0 END) AS VND_Total,
        SUM(CASE WHEN t.Currency = 'EUR' THEN t.Amount ELSE 0 END) AS EUR_Total

    FROM Transactions AS t
    JOIN Accounts AS a ON t.AccountId = a.AccountId
    GROUP BY a.UserId, YEAR(t.TransactionDate)
) AS yearly 
    ON u.UserId = yearly.UserId
GROUP BY u.FullName;
GO
--Chi tiêu của người dùng không có mix currency
CREATE OR ALTER VIEW v_UserSpendingSummary AS
SELECT
    u.FullName,
    t.Currency AS CurrencyType,
    SUM(CASE WHEN c.CategoryType = N'Chi trả' THEN ABS(t.Amount) ELSE 0 END) AS Total_Expense,
    SUM(CASE WHEN c.CategoryType = N'Thu nhập' THEN t.Amount ELSE 0 END) AS Total_Income,
    SUM(t.Amount) AS Net_Balance
FROM Users AS u
LEFT JOIN Accounts AS a ON u.UserId = a.UserId
LEFT JOIN Transactions AS t ON a.AccountId = t.AccountId
LEFT JOIN Categories AS c ON t.CategoryId = c.CategoryId
WHERE u.UserId NOT IN (
    SELECT a2.UserId
    FROM Accounts AS a2
    JOIN Transactions AS t2 ON a.AccountId = t2.AccountId
    WHERE t2.Currency IS NOT NULL
    GROUP BY a2.UserId
    HAVING COUNT(DISTINCT t2.Currency) > 1
)
GROUP BY u.FullName, t.Currency;
GO
--kiểm tra chi tiết Transactions của user có 2 currency trở lên theo Name (A->Z)
CREATE OR ALTER VIEW v_UserSpendingSummary_MixedCurrencyPivot AS
SELECT 
    u.UserId,
    u.FullName,

    -- USD totals
    SUM(CASE WHEN t.Currency = 'USD' AND c.CategoryType = N'Chi trả' THEN ABS(t.Amount) ELSE 0 END) AS USD_Total_Expense,
    SUM(CASE WHEN t.Currency = 'USD' AND c.CategoryType = N'Thu nhập' THEN t.Amount ELSE 0 END) AS USD_Total_Income,
    SUM(CASE WHEN t.Currency = 'USD' THEN t.Amount ELSE 0 END) AS USD_Net,

    -- VND totals
    SUM(CASE WHEN t.Currency = 'VND' AND c.CategoryType = N'Chi trả' THEN ABS(t.Amount) ELSE 0 END) AS VND_Total_Expense,
    SUM(CASE WHEN t.Currency = 'VND' AND c.CategoryType = N'Thu nhập' THEN t.Amount ELSE 0 END) AS VND_Total_Income,
    SUM(CASE WHEN t.Currency = 'VND' THEN t.Amount ELSE 0 END) AS VND_Net,

    -- EUR totals
    SUM(CASE WHEN t.Currency = 'EUR' AND c.CategoryType = N'Chi trả' THEN ABS(t.Amount) ELSE 0 END) AS EUR_Total_Expense,
    SUM(CASE WHEN t.Currency = 'EUR' AND c.CategoryType = N'Thu nhập' THEN t.Amount ELSE 0 END) AS EUR_Total_Income,
    SUM(CASE WHEN t.Currency = 'EUR' THEN t.Amount ELSE 0 END) AS EUR_Net,

    COUNT(t.TransactionId) AS TransactionCount

FROM Users AS u
JOIN Accounts AS a ON u.UserId = a.UserId
JOIN Transactions AS t ON a.AccountId = t.AccountId
LEFT JOIN Categories AS c ON t.CategoryId = c.CategoryId
GROUP BY u.UserId, u.FullName
HAVING COUNT(DISTINCT t.Currency) > 1;
GO