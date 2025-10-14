CREATE DATABASE QLTaiChinh
GO
USE QLTaiChinh
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
    Currency VARCHAR(10) DEFAULT 'USD',
    
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
    UserId INT NOT NULL,
    AccountId INT NOT NULL,
    CategoryId INT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    Description NVARCHAR(255),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    
    CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_Transactions_Accounts FOREIGN KEY (AccountId) REFERENCES Accounts(AccountId),
    CONSTRAINT FK_Transactions_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);
