-- Creating Database
CREATE DATABASE collegeManagement;
USE collegeManagement;
Go

-- Creating and Inserting values into Table SubjectAllotments
CREATE TABLE SubjectAllotments(
	StudentId varchar(50),
	SubjectId varchar(50),
	Is_valid bit
);

Go

INSERT INTO SubjectAllotments VALUES
	('159103036', 'PO1491', 1),
	('159103036', 'PO1492', 0),
	('159103036', 'PO1493', 0),
	('159103036', 'PO1494', 0),
	('159103036', 'PO1495', 0);
Go

-- Creating and Inserting values into the table SubjectRequest
CREATE TABLE SubjectRequest(
	StudentId varchar(50),
	SubjectId varchar(50)
);
Go

INSERT INTO SubjectRequest VALUES
	('159103036', 'PO1496');
Go

-- Displaying the tables
SELECT * FROM SubjectAllotments;
SELECT * FROM SubjectRequest;
GO

-- Creating the stored procedure
CREATE PROCEDURE ProcessSubjectRequest
AS
BEGIN
    DECLARE @StudentID VARCHAR(50)
    DECLARE @RequestedSubjectID VARCHAR(50)
    DECLARE @CurrentSubjectID VARCHAR(50)

    DECLARE req CURSOR FOR
    SELECT StudentID, SubjectID FROM SubjectRequest

    OPEN req
    FETCH NEXT FROM req INTO @StudentID, @RequestedSubjectID

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @CurrentSubjectID = SubjectID
        FROM SubjectAllotments
        WHERE StudentID = @StudentID AND Is_valid = 1

        IF @CurrentSubjectID IS NULL OR @CurrentSubjectID <> @RequestedSubjectID
        BEGIN
            UPDATE SubjectAllotments
            SET Is_valid = 0
            WHERE StudentID = @StudentID AND Is_valid = 1

            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_valid)
            VALUES (@StudentID, @RequestedSubjectID, 1)
        END

        FETCH NEXT FROM req INTO @StudentID, @RequestedSubjectID
    END

    CLOSE req
    DEALLOCATE req

    TRUNCATE TABLE SubjectRequest
END
Go

-- To verify if a stored procedure is working properly
EXEC ProcessSubjectRequest;

SELECT * FROM SubjectAllotments;

SELECT * FROM SubjectRequest;
GO
