EASY
--1 Who is the senior most employee based on jab title ?

SELECT * FROM employee

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1


--2 Which country have the most invoices ?

SELECT * FROM invoice

SELECT COUNT(*) AS c,billing_country FROM invoice
GROUP BY billing_country
ORDER BY c DESC
LIMIT 1


-- 3What are top 3 values of total invoice ?

SELECT * FROM  invoice

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3


--4  Which city has the best customers? We would like to throw a promotional Music Festival in the citu we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals.
-- Return both city name and sum of all invoice total ?

SELECT * FROM invoice

SELECT SUM(total) AS total_invoice ,billing_city FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1


--5 Who is the best customer ? The customer who has spent the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money ?

SELECT * FROM customer
SELECT * FROM invoice

SELECT customer.customer_id,customer.first_name,customer.last_name,SUM(invoice.total) AS total
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
LIMIT 1


MODERATE
--1 Write a query to return email,first name,last name & Gerne of all Rock Music Listeners.
-- Return your list ordered alphabetically by email starting with A ?

SELECT * FROM customer
SELECT * FROM invoice
SELECT * FROM invoice_line
SELECT * FROM track
SELECT * FROM genre

SELECT customer.email,customer.first_name,customer.last_name
FROM customer
JOIN invoice
ON customer.customer_id = invoice.customer_id
JOIN invoice_line
ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email



--2 Let's invite the artists who have written the most rock music in our dataset.
--Write a query that retuns the Artist name and total track count of the top 10 Rock band.
	
SELECT * FROM artist
SELECT * FROM album
SELECT * FROM track
SELECT * FROM genre


SELECT artist.artist_id,artist.name, COUNT(artist.artist_id) As number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'ROCK'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10



--3 Return all track names that have a song length longer than the average song length.
--Return the Name and Millisonds fror each track.Order by the song length with the longest songs listed first ?


SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track
)
ORDER BY milliseconds DESC


ADVANCE
--1 Find how much amount spent by each customer on artist ? Write a query to return customer name,artist_name and total spent ?

WITH best_selling_artist AS(
	SELECT artist.artist_id AS artist_id,artist.name AS artist_name,SUM(invoice_line.unit_price*invoice_line.quantity) AS bsa
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER  BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--2 We want to find out the most popular music Genre for each country.
-- We determine the most popular genre as the gerne with highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximun number of purchases is shared retun all Genre ?


WITH popular_genre AS
(
	SELECT COUNT(invoice_line.quantity) AS purchases,customer.country,genre.name,genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	FROM invoice_line
	     JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	     JOIN customer ON customer.customer_id = invoice.customer_id
	     JOIN track ON track.track_id = invoice_line.track_id
	     JOIN genre ON genre.genre_id = track.genre_id
	     GROUP BY 2,3,4
	     ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE Rowno <=1


--3 Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customers and how much they spent.
-- For countries where the top amount spent is shared,provide all customers who spent this amount.

WITH customer_with_country AS(
	SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country WHERE RowNo <=1 











