-----TASK TO BE PERFORMED-----------

		--- What is the total amount each customer spent at the restaurant?

		select 
		customer_id,
		count(s.product_id) as tp,
		sum(price) as ts
		from sales as s
		inner join menu as m
		on s.product_id = m.product_id
		group by customer_id;

		 ---How many days has each customer visited the restaurant?

		 select
		 customer_id,
		 count( distinct order_date) as td
		 from
		 sales
		 group by customer_id;

		 ---What was the first item from the menu purchased by each customer?

		WITH CTE AS(
		 select
		 customer_id,
		 order_date,
		 m.product_name,
		 ROW_NUMBER () over (partition by customer_id order by (order_date)) as rn
		 from sales as s
		 inner join  menu as m
		 on s.product_id = m.product_id
		)
		 select
		 customer_id,
		 product_name
		 from CTE
		 where rn = 1;


		 ---What is the most purchased item on the menu and how many times was it purchased by all customers?

		 select top 1
		 product_name,
		 count(s.product_id) as total_orders
		 from sales as s
		  inner join  menu as m
		 on s.product_id = m.product_id
		 group by product_name
		 order by total_orders desc;

		 ---Which item was the most popular for each customer?

		 WITH CTE AS(
		 select
		 customer_id,
		 product_name,
		 count(order_date) as total_orders,
		 ROW_NUMBER () over (partition by customer_id order by (count(order_date))desc) as rn
		 from sales as s
		 inner join  menu as m
		 on s.product_id = m.product_id
		 group by customer_id,
		 product_name
		 )
		select
		 customer_id,
		 product_name,
		 total_orders
		 from CTE
		 where rn = 1;

		 ---Which item was purchased first by the customer after they became a member?

		  WITH CTE AS(
		 select
		 s.customer_id,
		 product_name,
		 count(order_date) as total_orders,
		 ROW_NUMBER () over (partition by s.customer_id order by (count(order_date))) as rn
		 from sales as s
		 inner join  menu as m
		 on s.product_id = m.product_id
		 inner join members as mem 
		 on mem.customer_id = s.customer_id
		  where order_date>=join_date
		 group by s.customer_id,
		 product_name
		 )
		select
		 customer_id,
		 product_name
		 from CTE
		 where rn = 1;

		 ---Which item was purchased just before the customer became a member?

		   WITH CTE AS(
		 select
		 product_name,
		 order_date,
		 ROW_NUMBER () over (partition by product_name order by (order_date)desc) as rn
		 from sales as s
		 inner join  menu as m
		 on s.product_id = m.product_id
		 inner join members as mem 
		 on mem.customer_id = s.customer_id
		  where order_date<join_date
		 group by product_name,
		 order_date
		 )
		select
		 product_name
		 from CTE
		 where rn = 1;

		 ---What is the total items and amount spent for each member before they became a member?
		   select
		   s.customer_id,
		   COUNT(s.order_date) as total_orders,
		   SUM(price) as amount
		   from
		   sales as s
			join menu as m on s.product_id = m.product_id
			join members as mem on s.customer_id = mem.customer_id 
		   where order_date < join_date 
		   group by s.customer_id;


		 ---If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?


		select
		 customer_id,
		 sum(case when product_name = 'sushi' then price * 20
			 else price * 10
			 end) as points
		 from 
		 sales as s
		 inner join menu as m on s.product_id = m.product_id
		 group by  customer_id;


		 ---In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


		select
		s.customer_id,
		sum(CASE WHEN order_date between join_date and DATEADD(day,6,order_date) then price * 20
			 when product_name = 'sushi' then price * 20
			 else price * 10
			 end) as new_points
		from
		sales as s
		inner join menu as m on s.product_id = m.product_id
		inner join members as mem on s.customer_id = mem.customer_id
		where DATETRUNC(month,order_date) = '2021-01-01'
		group by s.customer_id;


											   ----Bonus Questions
											 -----Join All The Things


		  select
		  s.customer_id,
		  order_date,
		  m.product_name,
		  price,
		  case when order_date < join_date then 'N'
			   when join_date is null then 'N'
			   else  'Y' 
			   end  memb
		  from 
		  sales as s
		  inner join menu as m on s.product_id = m.product_id
		  left join members as mem on s.customer_id = mem.customer_id
		  order by price desc;

												---Rank All The Things
                                         
		WITH CTE AS (
		  SELECT 
			S.customer_id, 
			S.order_date, 
			product_name, 
			price, 
			CASE 
			  WHEN join_date IS NULL THEN 'N'
			  WHEN order_date < join_date THEN 'N'
			  ELSE 'Y' 
			END as member 
		  FROM 
			SALES as S 
			INNER JOIN MENU AS M ON S.product_id = M.product_id
			LEFT JOIN MEMBERS AS MEM ON MEM.customer_id = S.customer_id

		)
		SELECT 
		  *
		  ,CASE 
			WHEN member = 'N'  THEN NULL
			ELSE RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)  
		  END as rnk
		 FROM CTE
		  ORDER BY 
			customer_id, 
			order_date, 
			price DESC;
