CREATE DATABASE QLTaiChinh2
GO
USE QLTaiChinh2
go
-- Users table
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL
);
go
-- Accounts table
CREATE TABLE Accounts (
    AccountId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    AccountName NVARCHAR(100) NOT NULL,
    AccountType NVARCHAR(50) NOT NULL,
    
    
    CONSTRAINT FK_Accounts_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
go
-- Categories table
CREATE TABLE Categories (
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryType NVARCHAR(20) NOT NULL CHECK (CategoryType IN (N'Chi trả', N'Thu nhập'))
);
go
-- Transactions table
CREATE TABLE Transactions (
    TransactionId BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL,
    CategoryId INT NULL,
    Currency VARCHAR(10) DEFAULT 'USD',
    Amount DECIMAL(10,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    [Description] NVARCHAR(255),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
	PaymentMethod NVARCHAR(20)
       
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);
go
ALTER TABLE Transactions
ADD CONSTRAINT CK_Transactions_AmountSign
CHECK (
    (CategoryId = 1 AND Amount >= 0) OR
    (CategoryId IN (2,3,4,5) AND Amount <= 0) OR
    (CategoryId IS NULL)
);
