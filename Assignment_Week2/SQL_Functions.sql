--------------------------------------------------------------------------------------------
--------------------------------------- FUNCTIONS ------------------------------------------
--------------------------------------------------------------------------------------------

---------------------Function 1: Returns date in MM/DD/YYYY format--------------------------
IF OBJECT_ID('dbo.FormatDate', 'FN') IS NOT NULL
    DROP FUNCTION dbo.FormatDate;
GO

CREATE FUNCTION dbo.FormatDate (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @InputDate, 101); -- MM/DD/YYYY
END;
GO

---------------------Function 2: Returns date in YYYYMMDD format---------------------------
IF OBJECT_ID('dbo.FormatDateYYYYMMDD', 'FN') IS NOT NULL
    DROP FUNCTION dbo.FormatDateYYYYMMDD;
GO

CREATE FUNCTION dbo.FormatDateYYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CONVERT(VARCHAR(8), @InputDate, 112); -- YYYYMMDD
END;
GO