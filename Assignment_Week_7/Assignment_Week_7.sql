CREATE DATABASE Patients;
USE Patients;
Go

-- Source Table
CREATE TABLE SourcePatient (
    PatientID INT,
    PatientName VARCHAR(100),
    Illness VARCHAR(100),
    Phone VARCHAR(15)
);

-- Target Dimension Table
CREATE TABLE DimPatient (
    PatientID INT,
    PatientName VARCHAR(100),
    Illness VARCHAR(100),
    PreviousIllness VARCHAR(100),
    Phone VARCHAR(15),
    EffectiveDate DATETIME,
    EndDate DATETIME,
    IsCurrent BIT
);

-- Sample Data for SourcePatient (10 rows)
INSERT INTO SourcePatient VALUES
(201, 'Ananya Das', 'Flu', '9991112233'),
(202, 'Rohit Mehta', 'Diabetes', '8882223344'),
(203, 'Sneha Roy', 'Fracture', '7773334455'),
(204, 'Karan Singh', 'Asthma', '6664445566'),
(205, 'Pooja Nair', 'Migraine', '5555556666');

-- Sample Data for DimPatient (with mismatches)
INSERT INTO DimPatient VALUES
(201, 'Ananya Das', 'Cough', NULL, '9991112233', '2024-01-01', NULL, 1),
(202, 'Rohit Mehta', 'Diabetes', NULL, '8882223344', '2024-01-01', NULL, 1),
(203, 'Sneha Roy', 'Sprain', NULL, '7773334455', '2024-01-01', NULL, 1),
(204, 'Karan Singh', 'Asthma', NULL, '6664445566', '2024-01-01', NULL, 1),
(205, 'Pooja Nair', 'Migraine', NULL, '5555556666', '2024-01-01', NULL, 1);
GO

SELECT * FROM SourcePatient;
SELECT * FROM DimPatient;

-- Stored Procedure
-- SCD Type 1
CREATE PROCEDURE sp_SCD1_Patient
AS
BEGIN
    UPDATE d
    SET 
        PatientName = s.PatientName,
        Illness = s.Illness,
        Phone = s.Phone
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID;
END;
GO

-- SCD Type 2
CREATE PROCEDURE sp_SCD2_Patient
AS
BEGIN
    DECLARE @Now DATETIME = GETDATE();

    UPDATE d
    SET EndDate = @Now, IsCurrent = 0
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID
    WHERE d.IsCurrent = 1 AND (
        d.PatientName <> s.PatientName OR
        d.Illness <> s.Illness OR
        d.Phone <> s.Phone
    );

    INSERT INTO DimPatient
    (PatientID, PatientName, Illness, PreviousIllness, Phone, EffectiveDate, EndDate, IsCurrent)
    SELECT s.PatientID, s.PatientName, s.Illness, NULL, s.Phone, @Now, NULL, 1
    FROM SourcePatient s
    WHERE EXISTS (
        SELECT 1
        FROM DimPatient d
        WHERE d.PatientID = s.PatientID AND d.IsCurrent = 1 AND (
            d.PatientName <> s.PatientName OR
            d.Illness <> s.Illness OR
            d.Phone <> s.Phone
        )
    );
END;
GO

-- SCD Type 3
CREATE PROCEDURE sp_SCD3_Patient
AS
BEGIN
    UPDATE d
    SET 
        PreviousIllness = d.Illness,
        Illness = s.Illness
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID
    WHERE d.Illness <> s.Illness;
END;
GO

-- SCD Type 4 (with history table)
CREATE TABLE Patient_History (
    PatientID INT,
    PatientName VARCHAR(100),
    Illness VARCHAR(100),
    Phone VARCHAR(15),
    ChangeDate DATETIME
);
GO

CREATE PROCEDURE sp_SCD4_Patient
AS
BEGIN
    DECLARE @Now DATETIME = GETDATE();

    INSERT INTO Patient_History
    SELECT d.PatientID, d.PatientName, d.Illness, d.Phone, @Now
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID
    WHERE d.PatientName <> s.PatientName OR
          d.Illness <> s.Illness OR
          d.Phone <> s.Phone;

    UPDATE d
    SET 
        PatientName = s.PatientName,
        Illness = s.Illness,
        Phone = s.Phone
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID;
END;
GO

-- SCD Type 6
CREATE PROCEDURE sp_SCD6_Patient
AS
BEGIN
    DECLARE @Now DATETIME = GETDATE();

    UPDATE d
    SET EndDate = @Now, IsCurrent = 0
    FROM DimPatient d
    JOIN SourcePatient s ON d.PatientID = s.PatientID
    WHERE d.IsCurrent = 1 AND (
        d.PatientName <> s.PatientName OR
        d.Illness <> s.Illness OR
        d.Phone <> s.Phone
    );

    INSERT INTO DimPatient
    (PatientID, PatientName, Illness, PreviousIllness, Phone, EffectiveDate, EndDate, IsCurrent)
    SELECT 
        s.PatientID, 
        s.PatientName, 
        s.Illness, 
        d.Illness, 
        s.Phone, 
        @Now, 
        NULL, 
        1
    FROM SourcePatient s
    JOIN DimPatient d ON s.PatientID = d.PatientID AND d.IsCurrent = 0
    WHERE d.PatientName <> s.PatientName OR
          d.Illness <> s.Illness OR
          d.Phone <> s.Phone;
END;
GO

EXEC sp_SCD1_Patient;
EXEC sp_SCD2_Patient;
EXEC sp_SCD3_Patient;
EXEC sp_SCD4_Patient;
EXEC sp_SCD6_Patient;

SELECT * FROM DimPatient;
SELECT * FROM Patient_History;
