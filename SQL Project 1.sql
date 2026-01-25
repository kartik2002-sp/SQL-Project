---Tasks to be Performed:

--- 1.Insert a new record in your Orders table.
         INSERT INTO Orders ( OrderID,CustomerID,SalesmanID,Orderdate,Amount )
		       VALUES (5005,8351,111,'2024-09-2002',2000.00);
---2. Add Primary key constraint for SalesmanId column in Salesman table. Add default constraint for City column in Salesman table. Add Foreign key constraint for SalesmanId
        -- column in Customer table. Add not null constraint in Customer_name column for the
        -- Customer table.


		ALTER TABLE Salesman ADD CONSTRAINT PK_01 PRIMARY KEY(SalesmanID);

		ALTER TABLE Salesman ADD CONSTRAINT DF_01 DEFAULT(null) FOR City;

		ALTER TABLE Customer ADD CONSTRAINT FK_01 FOREIGN KEY(SalesmanID) REFERENCES Salesman(SalesmanID);

		ALTER TABLE Customer ALTER COLUMN CustomerName VARCHAR(255) NOT NULL;
		


 ---3.Fetch the data where the Customer’s name is ending with ‘N’ also get the purchase amount value greater than 500.

      SELECT 
	  *
	  FROM
	  Customer
	  where CustomerName like '%n' and PurchaseAmount > 500;


 ---4.Using SET operators, retrieve the first result with unique SalesmanId values from two tables, and the other result containing SalesmanId with duplicates from two tables.
      
	  select SalesmanId from Salesman
	  union
	  select SalesmanId from Customer
------------------------------------------------------
      select SalesmanId from Salesman
	  intersect
	  select SalesmanId from Customer;



 ---5.Display the below columns which has the matching data.
       ---Orderdate, Salesman Name, Customer Name, Commission, and City which has the range of Purchase Amount between 500 to 1500.

	   SELECT
	   Orderdate,
	   S.Name,
	   C.CustomerName,
	   S.Commission,
	   S.City
	   FROM
	   Orders AS O
	   JOIN Salesman AS S ON O.SalesmanId = S.SalesmanId
	   JOIN Customer AS C ON O.SalesmanId = C.SalesmanId
	   WHERE C.PurchaseAmount BETWEEN 500 AND 1500;


 ---6.Using right join fetch all the results from Salesman and Orders table.

 SELECT 
 *
 FROM
 Salesman AS S
 RIGHT JOIN Orders AS O ON S.SalesmanId = O.SalesmanId;










