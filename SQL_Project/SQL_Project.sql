-- /* QUERY 1 */

WITH family_category AS (
  SELECT f.title AS film_title, c.name AS category_name, f.rental_duration , NTILE(4) OVER (ORDER BY f.rental_duration) AS standard_quartile
  FROM film f
  JOIN film_category fc
  ON f.film_id = fc.film_id
  JOIN category c
  ON fc.category_id = c.category_id
  WHERE c.name IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music'))

SELECT category_name, standard_quartile, COUNT(rental_duration)
FROM family_category
GROUP BY 1, 2
ORDER BY 1, 2;

-- /* QUERY 2*/

WITH top_ten AS(
  SELECT p.customer_id, (c.first_name||' '||c.last_name) AS fullname, SUM(p.amount) AS pay_amount
  FROM payment p
  JOIN customer c
  ON p.customer_id = c.customer_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 10)

SELECT DATE_TRUNC('month', p.payment_date) pay_mon, tt.fullname AS name, COUNT(p.payment_date) AS pay_count_per_mon, SUM(p.amount) AS pay_amount
FROM payment p
JOIN top_ten tt
ON p.customer_id = tt.customer_id
GROUP BY 1,2
ORDER BY 2,1;

-- /* QUERY 3 */

SELECT cou.country, COUNT(cus.customer_id)
FROM customer cus
JOIN address a
ON cus.address_id = a.address_id
JOIN city cit
ON a.city_id = cit.city_id
JOIN country cou
ON cit.country_id = cou.country_id
GROUP BY 1
ORDER BY 2 DESC;

-- /* QUERY 4 */

WITH t1 AS (
  SELECT cou.country_id c_id, cou.country, COUNT(cus.customer_id)
  FROM customer cus
  JOIN address a
  ON cus.address_id = a.address_id
  JOIN city cit
  ON a.city_id = cit.city_id
  JOIN country cou
  ON cit.country_id = cou.country_id
  GROUP BY 1
  ORDER BY 3 DESC
  LIMIT 1),

india_cust AS (
  SELECT cus.customer_id
  FROM customer cus
  JOIN address a
  ON cus.address_id = a.address_id
  JOIN city c
  ON a.city_id = c.city_id
  JOIN t1
  ON c.country_id = t1.c_id
  WHERE c.country_id = t1.c_id)

SELECT f.title AS film_title, COUNT(r.rental_id) AS rent_count
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r. inventory_id
JOIN india_cust ic
ON ic.customer_id = r.customer_id
WHERE r.customer_id = ic.customer_id
GROUP BY 1
HAVING COUNT(r.rental_id) >= 5
ORDER BY 2 DESC;
