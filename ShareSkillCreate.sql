USE master
GO

DROP DATABASE IF EXISTS ShareSkill
	
CREATE DATABASE ShareSkill
GO

USE ShareSkill
GO


-- USERS
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Bio NVARCHAR(MAX),
    Tokens INT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- SKILLS OFFERED
CREATE TABLE Skills (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    SkillName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    TokenPricePerHour INT NOT NULL DEFAULT 100, -- divisible in 15-minute blocks
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- SEEKING (what users want to learn)
CREATE TABLE Seekings (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    DesiredSkill NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- TOKEN PURCHASES (Fake transactions)
CREATE TABLE TokenPurchases (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    TokensPurchased INT NOT NULL,
    PurchaseDate DATETIME DEFAULT GETDATE(),
    FakeCardLast4 NVARCHAR(4),
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- SESSIONS / BOOKINGS
CREATE TABLE Sessions (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RequesterId INT NOT NULL,  -- learner
    ProviderId INT NOT NULL,   -- teacher
    SkillId INT NOT NULL,
    ScheduledAt DATETIME NOT NULL,
    DurationMinutes INT NOT NULL CHECK (DurationMinutes IN (15, 30, 45, 60)), -- enforce granularity
    Status NVARCHAR(20) DEFAULT 'pending',
    TokensSpent INT NOT NULL,
    FOREIGN KEY (RequesterId) REFERENCES Users(Id),
    FOREIGN KEY (ProviderId) REFERENCES Users(Id),
    FOREIGN KEY (SkillId) REFERENCES Skills(Id)
);

-- MESSAGES BETWEEN USERS
CREATE TABLE Messages (
    Id INT PRIMARY KEY IDENTITY(1,1),
    SenderId INT NOT NULL,
    ReceiverId INT NOT NULL,
    Content NVARCHAR(MAX) NOT NULL,
    SentAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (SenderId) REFERENCES Users(Id),
    FOREIGN KEY (ReceiverId) REFERENCES Users(Id)
);

-- REVIEWS
CREATE TABLE Reviews (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ReviewerId INT NOT NULL,
    RevieweeId INT NOT NULL,
    SessionId INT,
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(MAX),
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ReviewerId) REFERENCES Users(Id),
    FOREIGN KEY (RevieweeId) REFERENCES Users(Id),
    FOREIGN KEY (SessionId) REFERENCES Sessions(Id)
);

-- CATEGORIES (for filtering)
CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(50) NOT NULL
);

-- LINK TABLE: SKILLS <-> CATEGORIES (Many-to-Many)
CREATE TABLE SkillCategories (
    SkillId INT NOT NULL,
    CategoryId INT NOT NULL,
    PRIMARY KEY (SkillId, CategoryId),
    FOREIGN KEY (SkillId) REFERENCES Skills(Id),
    FOREIGN KEY (CategoryId) REFERENCES Categories(Id)
);
