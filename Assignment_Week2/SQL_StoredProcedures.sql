--------------------------------------------------------------------------------------------
--------------------------------- STORED PROCEDURES ----------------------------------------
--------------------------------------------------------------------------------------------

------------------------Procedure 1: InsertOrderDetails-------------------------------------
IF OBJECT_ID('InsertOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE InsertOrderDetails;
GO

CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(18,2) = NULL,
    @Quantity INT,
    @Discount DECIMAL(4,2) = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @UnitPrice IS NULL
        SELECT @UnitPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;

    DECLARE @Stock INT;
    SELECT @Stock = Quantity FROM Production.ProductInventory WHERE ProductID = @ProductID;

    IF @Stock IS NULL OR @Stock < @Quantity
    BEGIN
        PRINT 'Not enough stock or product not found.';
        RETURN;
    END

    INSERT INTO Sales.SalesOrderDetail 
        (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
    VALUES 
        (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);

    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

END;
GO


----------------------------Procedure 2: UpdateOrderDetails---------------------------------
IF OBJECT_ID('UpdateOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE UpdateOrderDetails;
GO

CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(5,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQty INT;
    SELECT @OldQty = OrderQty FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQty IS NULL
    BEGIN
        PRINT 'Order not found.';
        RETURN;
    END

    UPDATE Sales.SalesOrderDetail
    SET 
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        OrderQty = ISNULL(@Quantity, OrderQty),
        UnitPriceDiscount = ISNULL(@Discount, UnitPriceDiscount)
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Updated successfully.';
END;
GO

-------------------------------Procedure 3: GetOrderDetails---------------------------------
IF OBJECT_ID('GetOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE GetOrderDetails;
GO

CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID)
    BEGIN
        PRINT 'OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist.';
        RETURN;
    END

    SELECT * FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;
GO

--------------------------Procedure 4: DeleteOrderDetails------------------------------------ 
IF OBJECT_ID('DeleteOrderDetails', 'P') IS NOT NULL
    DROP PROCEDURE DeleteOrderDetails;
GO

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID)
    BEGIN
        PRINT 'No such order/product found.';
        RETURN;
    END

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Deleted successfully.';
END;
GO
