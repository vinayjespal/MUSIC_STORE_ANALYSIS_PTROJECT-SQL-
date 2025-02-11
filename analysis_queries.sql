-- SET 1

-- Q1: Who is the senior most employee based on job title?
select title, first_name, last_name, levels from employee
order by levels desc
limit 1;

-- Q2: Which top 5 countries have the most Invoices?
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc
limit 5;

-- Q3: What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3;

-- Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city as city, sum(total) as total from invoice
group by billing_city 
order by total desc
limit 1;

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.
select * from customer;
select * from invoice;
select c.customer_id as ID, c.first_name as first_name, c.last_name as last_name, sum(i.total) as Total_Spent
from customer as c 
join invoice as i
on c.customer_id= i.customer_id
group by ID
order by Total_Spent desc
limit 1;

-- SET 2

-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A

select distinct email as Email, first_name as First_name, last_name as Last_name, genre.name as name 
from customer 
join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice.invoice_id= invoice_line.invoice_id
join  track on invoice_line.track_id= track.﻿track_id
join genre on track.genre_id= genre.genre_id
where genre.name like 'Rock'
order by Email asc;

-- Q2: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name, Count(artist.artist_id) as number_of_songs
from track 
join album on album.album_id= track.album_id
Join artist on artist.artist_id= album.artist_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;

-- Q3: Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
select name, milliseconds from track
where milliseconds> (select avg(milliseconds) from track)
order by milliseconds desc;

-- SET 3 

-- Q1: Find how much amount spent by each customer on top artist? Write a query to return customer name, artist name and total spent

with best_selling_artist as (
			select artist.artist_id as artist_id, artist.name as artist_name,
            sum(invoice_line.unit_price*invoice_line.quantity) as Total_sale
            from invoice_line
            Join track on invoice_line.track_id= track.track_id
            Join album on album.album_id= track.album_id
            Join artist on artist.artist_id= album.artist_id
            group by 1
            order by 3 desc
            limit 1
)
select c.customer_id as customer_id, c.first_name as first_name, c.last_name as last_name, bsa.artist_name, 
sum(il.unit_price*il.quantity) as Total_sale
from customer as c
Join invoice as i on i.customer_id= c.customer_id
Join invoice_line as il on il.invoice_id= i.invoice_id
Join track as t  on t.track_id= il.track_id
Join album as a on a.album_id= t.album_id
Join best_selling_artist as bsa on bsa.artist_id= a.artist_id
group by 1,2,3,4
order by 5 desc;

-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.

with popular_genre as (
		SELECT COUNT(invoice_line.quantity) as purchases, customer.country as country, genre.name as name, genre.genre_id as genre_id,
        row_number() over (partition by customer.country order by COUNT(invoice_line.quantity) desc) as row_no
        from invoice_line 
        JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
		JOIN customer ON customer.customer_id = invoice.customer_id
		JOIN track ON track.track_id = invoice_line.track_id
		JOIN genre ON genre.genre_id = track.genre_id
        group by 2,3,4
        order by 2 asc, 1 desc
)
select * from popular_genre where row_no <=1;

-- Q3: Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount

with Top_customer as (
		SELECT customer.customer_id as C_ID, customer.first_name as First_name, customer.last_name as last_name, invoice.billing_country as country,
        Sum(invoice.total) as total_spending,
        row_number() over (partition by invoice.billing_country order by Sum(invoice.total) desc) as row_no
        from invoice 
		JOIN customer ON customer.customer_id = invoice.customer_id
        group by 1,2,3,4
        order by 4 asc, 5 desc
)
select * from Top_customer where row_no <=1;
