 --Tasks to be performed:
 --1. Create a stored procedure to display the restaurant name, type and cuisine where the
      --table booking is not zero.
      create procedure proc_001
	  as
	  begin
			select RestaurantName,RestaurantType,
			CuisinesType
			from 
			Jomato
			where TableBooking not like '%no%'
	  end;
 --2. Create a transaction and update the cuisine type ‘Cafe’ to ‘Cafeteria’. Check the result
      --and rollback it.
	  begin transaction;

	   update Jomato set CuisinesType = replace(CuisinesType,'cafe','cafeteria')
	   where CuisinesType like '%cafe%';

      rollback transaction;

	  select * from jomato;
 --3. Generate a row number column and find the top 5 areas with the highest rating of
      --restaurants.
	  
	  with cte as(
	  select *,
	  ROW_NUMBER() over(partition by area order by Rating desc) as rn
	  from Jomato
	  )select top 5
	  Area,Rating
	  from cte
	  where rn = 1
	  order by rating desc;

 --4. Use the while loop to display the 1 to 50.

      
declare @Count INT = 1;
while @Count <= 50
begin
    
    PRINT @Count;
    SET @Count = @Count + 1;
end;

 --5. Write a query to Create a Top rating view to store the generated top 5 highest rating of
 --restaurants.
   
   create view top_rating
   as
   select top 5
    RestaurantName,
   Rating
   from jomato
   order by Rating desc;


   select * from dbo.TOP_RATING

 --6. Write a trigger that sends an email notification to the restaurant owner whenever a new
 --record is inserted.

CREATE TRIGGER SendEmailAfterInsert_001
ON jomato
AFTER INSERT
AS
BEGIN
    DECLARE @RestaurantName NVARCHAR(100);
    DECLARE @OwnerEmail NVARCHAR(100);
    
    SELECT @RestaurantName = INSERTED.RestaurantName
    FROM INSERTED;

    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'xyz123@gmail.com', 
        @recipients = @OwnerEmail,
        @body = 'A new record for has been inserted into the jomato table.',
        @subject = 'New Record Inserted';
END;
