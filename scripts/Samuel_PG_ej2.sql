#Ejercicio 2 - Samuel Peña

USE sakila;

WITH prestamos AS (
    SELECT
        f.title AS pelicula,
        CONCAT(a.district, ',', c.city, ',', co.country) AS tienda,
        MONTH(r.rental_date) as mes,
        YEAR(r.rental_date) as anno,
        COUNT(r.rental_id) AS cantidad_prestamos
    FROM country co
        INNER JOIN city c ON co.country_id = c.country_id
        INNER JOIN address a ON c.city_id = a.city_id
        INNER JOIN store st ON a.address_id = st.address_id
        INNER JOIN inventory i ON st.store_id = i.store_id
        INNER JOIN film f ON i.film_id = f.film_id
        INNER JOIN rental r ON i.inventory_id = r.inventory_id
    WHERE YEAR(r.rental_date) = 2005 AND (MONTH(r.rental_date) = 5 OR MONTH(r.rental_date) = 6)
    GROUP BY pelicula, tienda, anno, mes
),
pivote AS (
    SELECT
        pelicula,
        tienda,
        COALESCE(SUM(CASE WHEN mes=5 THEN cantidad_prestamos ELSE 0 END), 0) as prestamos_mayo,
        COALESCE(SUM(CASE WHEN mes=6 THEN cantidad_prestamos ELSE 0 END), 0) as prestamos_junio
    FROM prestamos
    GROUP BY pelicula, tienda
)
SELECT
    pelicula,
    tienda,
    prestamos_mayo,
    prestamos_junio,
    (prestamos_junio - prestamos_mayo) AS diferencia,
    CASE 
        WHEN prestamos_mayo = 0 THEN 100
        ELSE ((prestamos_junio - prestamos_mayo) / prestamos_mayo) * 100
    END AS porcentaje_crecimiento
FROM pivote
ORDER BY pelicula, tienda
LIMIT 30;