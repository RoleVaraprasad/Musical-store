create database Musical_data;
use musical_data;

select * from album;
select * from artist;
select * from customer;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

-- ------------------------------------------------ Music Project ------------------------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------
-- 1Q Who is senior most employee based on job title?
select
concat(first_name," ",last_name) as Full_Name, title, levels
from musical_data.employee
order by levels desc
limit 1;

-- 2Q Which countries have done most billing?

select
billing_country, count(*) as Total_countries
from invoice
group by billing_country
order by total_countries desc
limit 5;

-- 3Q What are the top 3 values of total invoices?

select * from invoice
order by total desc
limit 3;

-- 4Q Which city has the best customers? write a query that returns one city that has the highest sum of total,
-- return both the city name & sum of all invoice totals?.

select
sum(total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc;

#5Q Who is the best customer? the customer who has spent most money will be declared the best customer
-- write a query that returns the person who has spent the most money?

select
concat(c.first_name," ",c.last_name) as Full_Name, sum(v.total) as Total_Investment
from customer c
Join invoice as v on v.customer_id = c.customer_id
group by Full_Name
order by total_investment desc
limit 1;

-- 6Q Write a query the email, first name, last name, & genre all rock music listener.
-- return you list ordered alphabetically by email starting with A

select distinct
c.email, c.first_name, c.last_name, g.name
from customer as c
join invoice as v using (customer_id)
join invoice_line as l using (invoice_id)
join track as t using (track_id)
join genre as g using (genre_id)
where g.name = "Rock"
order by c.email;

-- WE CAN GET THE SAME RESULT USING THE SUBQUERY METHOD --

select distinct
c.email, c.first_name, c.last_name
from customer as c
join invoice as v using (customer_id)
join invoice_line as l using (invoice_id)
WHERE TRACK_ID IN (
SELECT TRACK_ID FROM TRACK
JOIN GENRE AS G USING (GENRE_ID)
WHERE G.NAME LIKE 'ROCK'
ORDER BY C.EMAIL);

-- 7Q Let's invite the artist who have written the most rock music in our dataset.
-- Write a query that returns the artist name and total track count of the top 10 rock bands?

select
a.name, count(t.genre_id) as bands
from track as t
join album as ab using (album_id)
join artist as a using (artist_id)
where t.genre_id = 1
group by a.name
order by bands desc
limit 10;

-- 8Q Return all the track names that have a song length longer than the average song length.
-- and return the name of millisecond of each track. order by the song length with the longest songs listed first?

select
name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

-- 9Q Find how much amount spent by each customers on artists?
-- Write a query to return customer name, artist name and total spent?

select
concat(c.first_name," ",c.last_name) as Full_Name, a.name as Artist_Name, sum(ins.unit_price*ins.quantity) as total_spent
from invoice_line as ins
join invoice as ic using (invoice_id)
join customer as c using (customer_id)
join track as t using (track_id)
join album as ab using (album_id)
join artist as a using (artist_id)
group by Full_name, artist_name
order by total_spent desc;

-- SAME ANSWER USING CTE --
WITH best_selling_artist as (
select a.artist_id as artist_id, a.name as artist_name,
sum(ins.unit_price*ins.quantity) as total_sales
from invoice_line as ins
join track as t using (track_id)
join album as ab using (album_id)
join artist as a using (artist_id)
group by artist_id, artist_name
order by total_sales desc
)
select
c.customer_id, concat(c.first_name," ",c.last_name) as Full_Name,
bsa.artist_name, sum(ins.unit_price*ins.quantity) as amount_spent
from invoice as i
join customer as c using (customer_id)
join invoice_line as ins using (invoice_id)
join track as t using (track_id)
join album as ab using (album_id)
join best_selling_artist as bsa using (artist_id)
group by c.customer_id, Full_Name,bsa.artist_name
order by amount_spent desc;

-- 10Q Write a query that determine the customer that has spent the most on music for each country
--     Write a query that returns the country along with the top customer and how much they spent,
-- for countries where the top amount spent is shared, provide all customers who spent this amount?

with customer_with_country as (
select
c.customer_id, concat(c.first_name," ",c.last_name) as Full_Name, Billing_country,
sum(total) as total_spending,
row_number() over (partition by billing_country order by sum(total) desc) as rowno
from invoice
join customer as c using (customer_id)
group by 1,2,3
order by 3 asc, 4 desc)

select * from customer_with_country
where rowno <= 1;

-- ------------------------------------------------ END OF PROJECT ----------------------------------------------------------