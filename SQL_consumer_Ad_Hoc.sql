/* Query the customer_code, market from dim_customer table with customer is Atliq Exclusive from region APAC*/

1. select customer_code, market from dim_customer
    where customer = "Atliq Exclusive" and region = "APAC";

/*using CTE function, Query unique products in 2020 and 2021*/

2.  with hari as 
     (
     SELECT count(distinct product_code) as unique_products_2020,
     (select count(distinct product_code) from fact_sales_monthly where fiscal_year ="2020") as unique_products_2021
     FROM fact_sales_monthly
     where fiscal_year = "2021"
     )
     select unique_products_2021, unique_products_2020, unique_products_2021/unique_products_2020 * 100 as percentage_chge
     from hari;

/*How many distinct_product, Query segment from dim_product table  */

3.  select segment, count(distinct product) as product_count from dim_product
     group by segment
     order by count(distinct product) desc;

/*using double CTE's function, How many unique products in 2020, 2021 and Query segment from fact_sales_monthly and dim_product*/

4.  WITH sharath AS 
        (
        select segment,count(distinct S.product_code) as unique_products_2020
        FROM fact_sales_monthly as S join dim_product as P on S.product_code = P.product_code
        where fiscal_year = 2020
        group by segment
        ),
        varun AS
        (
        select segment, count(distinct S.product_code) as unique_products_2021
        FROM fact_sales_monthly as S join dim_product as P on S.product_code = P.product_code
        where fiscal_year = 2021 
        group by segment)
        
        select sharath.segment, unique_products_2020, varun.unique_products_2021, unique_products_2020 - varun.unique_products_2021 as difference from sharath join varun on sharath.segment =             varun.segment
        group by sharath.segment;

/*Query product_code, union all(fn),sub_query, maximum and minimum value from manufacturing_cost*/

5.  SELECT P.product_code, product, manufacturing_cost FROM fact_manufacturing_cost as M JOIN dim_product as P on M.product_code = P.product_code
     WHERE manufacturing_cost in (SELECT Max(manufacturing_cost) FROM fact_manufacturing_cost)
     UNION ALL
     SELECT P.product_code, product, manufacturing_cost from fact_manufacturing_cost as M JOIN dim_product as P on M.product_code = P.product_code
     WHERE manufacturing_cost in (SELECT Min(manufacturing_cost) FROM fact_manufacturing_cost);

/*Query customer_code, customer, average(fn) with market is India and fiscal_year = 2021*/

6.   select C.customer_code, C.customer, Avg(P.pre_invoice_discount_pct)
      from dim_customer as C JOIN fact_pre_invoice_deductions as P ON C.customer_code = P.customer_code
      where fiscal_year = "2021" and market = "India"
      group by customer_code, customer
      order by Avg(P.pre_invoice_discount_pct)
      limit 5;

/*Query date_format(fn), month, sum(fn) with customer is Atliq Exclusive*/
7.   select date_format(S.date, "%b" "%y") as MONTH, Round(Sum(S.sold_quantity*G.gross_price)) as Gross_Sales_Monthly 
      from dim_customer as C JOIN fact_sales_monthly as S 
      on c.customer_code = S.customer_code JOIN fact_gross_price as G 
      on S.product_code = G.product_code
      where customer = "Atliq Exclusive" 
      group by S.date;

/*Query quarterr(date), sold_quantity with year = 2020*/
8.   select quarter(date) , sum(sold_quantity) from fact_sales_monthly
      where year(date) = '2020'
      group by quarter(date)
      order by sum(sold_quantity) desc;

/*Using CTE's function, Query channel,gross_sales, sum(fn), multiple_joins*/
9.    with value as
        (
        select C.channel, Round(sum(gross_price * sold_quantity)) as gross_sales from fact_gross_price as G join fact_sales_monthly as S on 
        G.product_code = S.product_code join dim_customer as C on S.customer_code = C.customer_code
        group by channel
        )
        select channel, gross_sales, gross_sales*100/(Select sum(gross_sales) from value) 
        from value; 

/*Using CTE's, partition_by rank(fn), with fiscal_year is 2021 */
10.   with cte as(
        select division, P.product_code as pc, product, sold_quantity,
        rank () over (partition by division order by sold_quantity desc) RN
        from dim_product as P join fact_sales_monthly as S on 
        P.product_code = S.product_code
        where fiscal_year = '2021'
        order by division, RN
        )
        select division, pc,  product, sold_quantity, RN from cte
        where RN<=3;
    