--------------------------------------------------------------------------------------------
---------------------------------------- TRIGGER -------------------------------------------
--------------------------------------------------------------------------------------------

---------------------Trigger 1: Delete Order and Related OrderDetails-----------------------
IF OBJECT_ID('trgInsteadOfDeleteOrder', 'TR') IS NOT NULL
    DROP TRIGGER trgInsteadOfDeleteOrder;
GO

CREATE TRIGGER trgInsteadOfDeleteOrder
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM OrderDetails
    WHERE OrderID IN (SELECT OrderID FROM deleted);

    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted);

END;
GO

----------------------Trigger 2: Check stock before placing order-------------------------
IF OBJECT_ID('trgCheckStockBeforeInsert', 'TR') IS NOT NULL
DROP TRIGGER trgCheckStockBeforeInsert;
GO

CREATE TRIGGER trgCheckStockBeforeInsert
ON OrderDetails
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity)
    SELECT i.OrderDetailID, i.OrderID, i.ProductID, i.Quantity
    FROM inserted i
    JOIN Products p ON i.ProductID = p.ProductID
    WHERE p.UnitsInStock >= i.Quantity;

    UPDATE p
    SET p.UnitsInStock = p.UnitsInStock - i.Quantity
    FROM Products p
    JOIN inserted i ON p.ProductID = i.ProductID
    WHERE p.UnitsInStock >= i.Quantity;
END;
GO