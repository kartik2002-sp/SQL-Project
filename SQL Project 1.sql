 ---Tasks to be performed:
 --1. Create a user-defined functions to stuff the Chicken into ‘Quick Bites’. Eg: ‘Quick
 --Chicken Bites’.

  create function function_01(@x varchar(20),@y varchar(20),@z varchar(20))
  returns varchar(20)
  as
  begin
       return (select(@x+@y+@z))
  end;

  begin transaction
  update Jomato
  set RestaurantType = dbo.function_01(substring(restauranttype,1,5),'chicken',substring(restauranttype,7,11))
  where RestaurantType = 'quick bites'
  rollback transaction;

  select * from Jomato



 --2. Use the function to display the restaurant name and cuisine type which has the
 --maximum number of rating.

 select top 1
 RestaurantName,
 CuisinesType,
 MAX(No_of_Rating) as [totals]
 from Jomato
 group by  RestaurantName,
 CuisinesType
 order by MAX(No_of_Rating) desc;

 --3. Create a Rating Status column to display the rating as ‘Excellent’ if it has more the 4
 --start rating, ‘Good’ if it has above 3.5 and below 4 star rating, ‘Average’ if it is above 3
 --and below 3.5 and ‘Bad’ if it is below 3 star rating and

 select
 *,
    case when Rating >= 4 then 'excellent'
	     when Rating < 4 and Rating >= 3.5 then 'good'
		 when Rating < 3.5 and Rating >= 3 then 'average'
		 else 'bad'
		 end [Rating Status]
 from
 Jomato;

 --4. Find the Ceil, floor and absolute values of the rating column and display the current
 --date and separately display the year, month_name and day.

select
Rating,
CEILING(rating) AS rating_ceiling,
FLOOR(rating) AS rating_floor,
ABS(rating) AS absolute_rating,
GETDATE() as currentDATE,
DATEPART(year,GETDATE()) as year,
DATENAME(MONTH,GETDATE()) as month_name,
DATENAME(DAY,GETDATE()) as day
from
Jomato;

 --5. Display the restaurant type and total average cost using rollup.

 select 
 RestaurantType,
 sum(AverageCost) as [total average cost ]
 from
 Jomato
 group by rollup(RestaurantType);


