-- Create Table Time Dimension
CREATE TABLE TimeDimension (
    Date DATE PRIMARY KEY,
    SKDate INT,
    CalendarDay INT,
    CalendarMonth INT,
    CalendarQuarter INT,
    CalendarYear INT,
    DayNameLong VARCHAR(20),
    DayNameShort VARCHAR(10),
    DayNumberOfWeek INT,
    DayNumberOfYear INT,
    DaySuffix VARCHAR(5),
    FiscalWeek INT,
    FiscalPeriod INT,
    FiscalQuarter INT,
    FiscalYear INT,
    FiscalYearPeriod VARCHAR(10)
);
Go

-- Create Stored Procedure 
CREATE PROCEDURE GenerateTimeDimension
    @InputDate DATE
AS
BEGIN
    DECLARE @StartDate DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
    DECLARE @EndDate DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);
    
    ;WITH DateSequence AS (
        SELECT @StartDate AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateSequence
        WHERE DateValue < @EndDate
    )
    INSERT INTO TimeDimension (
        Date, SKDate, CalendarDay, CalendarMonth, CalendarQuarter, CalendarYear,
        DayNameLong, DayNameShort, DayNumberOfWeek, DayNumberOfYear, DaySuffix,
        FiscalWeek, FiscalPeriod, FiscalQuarter, FiscalYear, FiscalYearPeriod
    )
    SELECT
        DateValue,
        CONVERT(INT, FORMAT(DateValue, 'yyyyMMdd')) AS SKDate,
        DAY(DateValue) AS CalendarDay,
        MONTH(DateValue) AS CalendarMonth,
        DATEPART(QUARTER, DateValue) AS CalendarQuarter,
        YEAR(DateValue) AS CalendarYear,
        DATENAME(WEEKDAY, DateValue) AS DayNameLong,
        LEFT(DATENAME(WEEKDAY, DateValue), 3) AS DayNameShort,
        DATEPART(WEEKDAY, DateValue) AS DayNumberOfWeek,
        DATEPART(DAYOFYEAR, DateValue) AS DayNumberOfYear,
        -- Day Suffix logic
        CASE 
            WHEN DAY(DateValue) IN (11, 12, 13) THEN CAST(DAY(DateValue) AS VARCHAR) + 'th'
            WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '1' THEN CAST(DAY(DateValue) AS VARCHAR) + 'st'
            WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '2' THEN CAST(DAY(DateValue) AS VARCHAR) + 'nd'
            WHEN RIGHT(CAST(DAY(DateValue) AS VARCHAR),1) = '3' THEN CAST(DAY(DateValue) AS VARCHAR) + 'rd'
            ELSE CAST(DAY(DateValue) AS VARCHAR) + 'th'
        END AS DaySuffix,
        DATEPART(WEEK, DATEADD(MONTH, -3, DateValue)) AS FiscalWeek, -- Adjusted for Fiscal Year starting in April
        ((MONTH(DateValue) + 9) % 12) + 1 AS FiscalPeriod,            -- April = 1, March = 12
        ((MONTH(DateValue) + 9) / 3 % 4) + 1 AS FiscalQuarter,        -- Fiscal Quarter
        CASE 
            WHEN MONTH(DateValue) >= 4 THEN YEAR(DateValue)
            ELSE YEAR(DateValue) - 1
        END AS FiscalYear,
        CAST(
            CASE 
                WHEN MONTH(DateValue) >= 4 THEN YEAR(DateValue)
                ELSE YEAR(DateValue) - 1
            END AS VARCHAR(4)) + 
            RIGHT('0' + CAST(((MONTH(DateValue) + 9) % 12) + 1 AS VARCHAR), 2)
        AS FiscalYearPeriod
    FROM DateSequence
    OPTION (MAXRECURSION 366);
END;

-- Execute the procedure
EXEC GenerateTimeDimension '2020-07-14';

SELECT * FROM TimeDimension ORDER BY Date;
SELECT COUNT(*) FROM TimeDimension;
