-- Schemas
-- Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(100) NOT NULL,
    FullName VARCHAR(100),
    Email VARCHAR(100)
);

-- Hotels Table
CREATE TABLE Hotels (
    HotelID INT PRIMARY KEY,
    HotelName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL
);

-- Rooms Table
CREATE TABLE Rooms (
    RoomID INT PRIMARY KEY,
    HotelID INT,
    RoomNumber VARCHAR(10),
    RoomType VARCHAR(50),
    Price DECIMAL(10,2),
    FOREIGN KEY (HotelID) REFERENCES Hotels(HotelID)
);

-- Reservations Table
CREATE TABLE Reservations (
    ReservationID INT PRIMARY KEY,
    UserID INT,
    RoomID INT,
    CheckInDate DATE,
    CheckOutDate DATE,
    Status VARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

-- Billing Table
CREATE TABLE Billing (
    BillID INT PRIMARY KEY,
    ReservationID INT,
    TotalAmount DECIMAL(10,2),
    PaymentStatus VARCHAR(50),
    FOREIGN KEY (ReservationID) REFERENCES Reservations(ReservationID)
);
Go

-- Stored Procedures
-- 1. User Login
CREATE PROCEDURE LoginUser
    @Username VARCHAR(50), 
    @Password VARCHAR(100)
AS
BEGIN
    SELECT UserID, Username, FullName, Email
    FROM Users
    WHERE Username = @Username AND Password = @Password;
END;
Go

-- 2. Check Room Availability
CREATE PROCEDURE CheckRoomAvailability
    @RoomID INT,
    @CheckIn DATE,
    @CheckOut DATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE RoomID = @RoomID
        AND Status = 'Confirmed'
        AND (CheckInDate < @CheckOut AND CheckOutDate > @CheckIn)
    )
        SELECT 'Not Available' AS Availability;
    ELSE
        SELECT 'Available' AS Availability;
END;
Go

-- 3. Generate Bill
CREATE PROCEDURE GenerateBill
    @ReservationID INT
AS
BEGIN
    DECLARE @Days INT;
    DECLARE @Price DECIMAL(10,2);

    SELECT @Days = GREATEST(DATEDIFF(DAY, CheckInDate, CheckOutDate), 1)
    FROM Reservations
    WHERE ReservationID = @ReservationID;

    SELECT @Price = r.Price
    FROM Rooms r
    JOIN Reservations res ON r.RoomID = res.RoomID
    WHERE res.ReservationID = @ReservationID;

    INSERT INTO Billing (ReservationID, TotalAmount, PaymentStatus)
    VALUES (@ReservationID, @Days * @Price, 'Pending');
END;
Go

-- 4. Check-In Process
CREATE PROCEDURE CheckIn
    @ReservationID INT
AS
BEGIN
    UPDATE Reservations 
    SET Status = 'Checked-In'
    WHERE ReservationID = @ReservationID AND Status = 'Confirmed';

    IF @@ROWCOUNT > 0
        SELECT 'Check-In Successful' AS Result;
    ELSE
        SELECT 'Check-In Failed or Not Allowed' AS Result;
END;
Go

-- 5. Check-Out Process
CREATE PROCEDURE CheckOut
    @ReservationID INT
AS
BEGIN
    BEGIN TRANSACTION;

    UPDATE Reservations 
    SET Status = 'Checked-Out'
    WHERE ReservationID = @ReservationID AND Status = 'Checked-In';

    IF @@ROWCOUNT > 0
    BEGIN
        UPDATE Billing 
        SET PaymentStatus = 'Paid'
        WHERE ReservationID = @ReservationID;
        COMMIT;
        SELECT 'Check-Out Successful' AS Result;
    END
    ELSE
    BEGIN
        ROLLBACK;
        SELECT 'Check-Out Failed or Not Allowed' AS Result;
    END
END;
Go

-- 6. Make a Reservation
CREATE PROCEDURE MakeReservation
    @UserID INT,
    @RoomID INT,
    @CheckIn DATE,
    @CheckOut DATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Reservations
        WHERE RoomID = @RoomID
        AND Status = 'Confirmed'
        AND (CheckInDate < @CheckOut AND CheckOutDate > @CheckIn)
    )
        SELECT 'Room Not Available' AS Result;
    ELSE
    BEGIN
        INSERT INTO Reservations (UserID, RoomID, CheckInDate, CheckOutDate, Status)
        VALUES (@UserID, @RoomID, @CheckIn, @CheckOut, 'Confirmed');
        SELECT 'Reservation Successful' AS Result;
    END
END;
Go

-- 7. Get Alternative Available Rooms
CREATE PROCEDURE GetAlternativeAvailableRooms
    @HotelID INT,
    @CheckIn DATE,
    @CheckOut DATE
AS
BEGIN
    SELECT r.RoomID, r.RoomNumber, r.RoomType, r.Price
    FROM Rooms r
    WHERE r.HotelID = @HotelID
    AND r.RoomID NOT IN (
        SELECT RoomID FROM Reservations
        WHERE Status = 'Confirmed'
        AND (CheckInDate < @CheckOut AND CheckOutDate > @CheckIn)
    );
END;
Go

ALTER TABLE Hotels ADD ContactNumber VARCHAR(20);
Go

-- 8. Register Hotel
CREATE PROCEDURE RegisterHotel
    @HotelName VARCHAR(100),
    @Location VARCHAR(100),
    @ContactNumber VARCHAR(20)
AS
BEGIN
    INSERT INTO Hotels (HotelName, Location, ContactNumber)
    VALUES (@HotelName, @Location, @ContactNumber);
END;
Go

-- 9. Register Room
CREATE PROCEDURE RegisterRoom
    @HotelID INT,
    @RoomNumber VARCHAR(20),
    @RoomType VARCHAR(50),
    @Price DECIMAL(10,2)
AS
BEGIN
    INSERT INTO Rooms (HotelID, RoomNumber, RoomType, Price)
    VALUES (@HotelID, @RoomNumber, @RoomType, @Price);
END;
Go