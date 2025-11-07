SELECT [Month], Currency, Total_Income, Total_Expense, Net_Balance
FROM v_MonthlyIncomeExpense_ByCurrency
ORDER BY SortKey;
go
select * from v_TopExpenseCategories_CurrencyPivot
go
select * from v_MonthlyExpenseCategories_CurrencyPivot
go
select * from v_AvgMonthlySpend_CurrencyPivot
go
select * from v_AvgYearlySpend_CurrencyPivot
go
select * from v_UserSpendingSummary
go
select * from v_UserSpendingSummary_MixedCurrencyPivot