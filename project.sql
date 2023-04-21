SELECT * FROM sales;

SELECT * FROM members;

SELECT * FROM menu;

--What is the total amount each customer spent at the restaurants?--
select customer_id, 
sum(price) as total_amount from menu
inner join sales on sales.product_id = menu.product_id
group by customer_id order by total_amount desc;

--How many days has each customer visited the restaurants?--
select customer_id, count(distinct(order_date)) as visitations
from sales group by customer_id;

-- What was the first item from the menu purchased by each customer?--
with First_item as (
  select customer_id, min(order_date) as min_date 
  from sales group by customer_id)
select distinct customer_id, product_name, min_date, product_id
  from sales
  inner join First_item as f 
  on f.customer_id = customer_id
  inner join menu
  on sales.product_id = menu.product_id
  order by sales.customer_id;
  
-- What is the most purchased item on the menu and how many times was it purchased bt all customers?--
select m.product_id, m.product_name, count(*) as number_of_orders
  from sales as s
  inner join menu as m
  on s.product_id = m.product_id
  group by m.product_id, m.product_name;

-- What item was the most popular for each customer?--
select customer_id, product_name
  from (select s.customer_Id, m.product_name, 
  count(*) as num_of_item,
  rank() over(partition by customer_Id order by count(*) desc) as most_num_of_item
  from sales as s inner join menu as m
  using(product_id)
  group by s.customer_Id, m.product_name) as pp
  where most_num_of_item = 1
  order by customer_Id;

-- Which item was purchased first by the customer after they became a member?--
select product_name, customer_Id
  from(select mn.product_name, s.customer_Id, count(*), s.order_date, m.join_date,
  row_number() over(partition by s.customer_Id order by s.order_date) as NN
  from members as m
  inner join sales as s
  on m.customer_Id = s.customer_Id
  and m.join_date < s.order_date
  inner join menu as mn
  on s.product_id = mn.product_id) as first_purchase
  where first_purchase.NN = 1
  order by customer_Id;
  
-- Which item was purchased just before the customer became a member?--
  select product_name, customer_Id
  from (select s.product_id, s.customer_Id, m.join_date, s.order_date, mn.product_name,
  rank() over(partition by s.customer_Id order by order_date desc) as LL
  from members as m
  inner join sales as s
  on m.customer_Id = s.customer_Id
  and m.join_date > s.order_date
  inner join menu as mn
  on s.product_id = mn.product_id) as purchased_before
  where purchased_before.LL = 1
  order by customer_Id;

-- What is the total items and amount spent for each member before they became a member?--
with amount_spent as (
  select mb.join_date, s.customer_Id, s.order_date, s.product_id, m.product_name, m.price
  from  members as mb
  inner join sales as s
  on mb.customer_Id = s.customer_Id
  and mb.join_date > s.order_date
  inner join menu as m
  on s.product_id = m.product_id) 
select customer_Id, sum(price) as amount, count(*) as total_items
from amount_spent
group by customer_Id
order by customer_Id


