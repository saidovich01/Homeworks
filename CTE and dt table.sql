CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    DepartmentID INT,
    Salary DECIMAL(10,2),
    HireDate DATE,
    ManagerID INT NULL
);

INSERT INTO Employees (EmployeeID, Name, DepartmentID, Salary, HireDate, ManagerID) VALUES
(1, 'Alice Johnson', 1, 75000, '2015-06-15', NULL),
(2, 'Bob Smith', 2, 60000, '2018-03-22', 1),
(3, 'Charlie Brown', 1, 80000, '2012-11-05', NULL),
(4, 'David Williams', 3, 50000, '2020-07-19', 2),
(5, 'Emily Davis', 1, 72000, '2016-09-10', 1),
(6, 'Frank Harris', 2, 59000, '2019-04-25', 2),
(7, 'Grace Lee', 3, 48000, '2021-01-12', 3);

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100),
    Location VARCHAR(100)
);

INSERT INTO Departments (DepartmentID, DepartmentName, Location) VALUES
(1, 'IT', 'New York'),
(2, 'HR', 'Chicago'),
(3, 'Finance', 'San Francisco');

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10,2)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(101, 1, '2023-01-15', 250.00),
(102, 2, '2023-02-10', 500.00),
(103, 1, '2023-03-05', 120.00),
(104, 3, '2023-04-20', 800.00),
(105, 2, '2023-05-11', 350.00),
(106, 4, '2023-06-22', 450.00);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);
select * from Employees
select * from Orders
select * from Departments



SELECT * FROM (SELECT TOP 5 * FROM Employees ORDER BY Salary DESC) AS Top5_Salary


SELECT e.*, d.AvgSalary
FROM Employees e JOIN (
					  SELECT DepartmentID, AVG(Salary) AS AvgSalary FROM Employees GROUP BY DepartmentID) AS d
							ON e.DepartmentID = d.DepartmentID


SELECT * FROM Employees e
WHERE Salary > (SELECT AVG(Salary) FROM Employees)


SELECT c.CustomerName, maxOrders.MaxTotal
FROM (SELECT CustomerID, MAX(TotalAmount) AS MaxTotal FROM Orders GROUP BY CustomerID) AS maxOrders
JOIN Customers c ON maxOrders.CustomerID = c.CustomerID;

SELECT c.CustomerName, ordersCount.OrderCount
FROM (SELECT CustomerID, COUNT(*) AS OrderCount FROM Orders GROUP BY CustomerID) AS ordersCount
JOIN Customers c ON ordersCount.CustomerID = c.CustomerID;


SELECT e.* FROM Employees e
JOIN (SELECT DepartmentID, AVG(Salary) AS AvgSalary FROM Employees GROUP BY DepartmentID) AS d
ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > d.AvgSalary;



WITH AvgSalary AS (SELECT AVG(Salary) AS CompanyAvg FROM Employees)
SELECT * FROM Employees WHERE Salary > (SELECT CompanyAvg FROM AvgSalary);

WITH EmployeeHierarchy AS (
    SELECT EmployeeID, Name, ManagerID, 0 AS Level FROM Employees WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.EmployeeID, e.Name, e.ManagerID, eh.Level + 1 FROM Employees e
    JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT * FROM EmployeeHierarchy;

WITH RunningTotal AS (
    SELECT OrderID, CustomerID, OrderDate, TotalAmount,
           SUM(TotalAmount) OVER (PARTITION BY CustomerID ORDER BY OrderDate) AS RunningSum
    FROM Orders
)
SELECT * FROM RunningTotal;

WITH OrderCount AS (
    SELECT CustomerID, COUNT(OrderID) AS TotalOrders FROM Orders GROUP BY CustomerID
)
SELECT c.CustomerName, oc.TotalOrders FROM OrderCount oc
JOIN Customers c ON oc.CustomerID = c.CustomerID;

WITH EmployeeYears AS (
    SELECT *, DATEDIFF(YEAR, HireDate, GETDATE()) AS YearsWithCompany FROM Employees
)
SELECT * FROM EmployeeYears WHERE YearsWithCompany > 10;



SELECT DepartmentName FROM Departments WHERE DepartmentID = (
    SELECT TOP 1 DepartmentID FROM Employees GROUP BY DepartmentID ORDER BY SUM(Salary) DESC
);

SELECT * FROM Products WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Orders);

SELECT * FROM Employees WHERE EmployeeID NOT IN (SELECT DISTINCT ManagerID FROM Employees WHERE ManagerID IS NOT NULL);



SELECT * FROM Customers c WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID
);

SELECT * FROM Employees e WHERE EXISTS (
    SELECT 1 FROM Employees sub WHERE sub.ManagerID = e.EmployeeID
);

SELECT * FROM Products p WHERE EXISTS (
    SELECT 1 FROM OrderDetails od WHERE od.ProductID = p.ProductID AND od.Discount > 0
);

SELECT * FROM Customers c WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.CustomerID = c.CustomerID GROUP BY o.CustomerID HAVING COUNT(DISTINCT o.OrderID) > 5
);

SELECT * FROM Orders o WHERE EXISTS (
    SELECT 1 FROM OrderDetails od WHERE od.OrderID = o.OrderID AND od.UnitPrice > 500
);






