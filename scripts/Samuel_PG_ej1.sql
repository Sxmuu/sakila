#Ejercicio 1 - Samuel Peña

USE sakila;

WITH prestamos AS (
    SELECT
        CONCAT(a.district, ',', c.city, ',', co.country) AS tienda,
        CONCAT(s.first_name,' ', s.last_name) AS vendedor,
        MONTH(r.rental_date) as mes,
        YEAR(r.rental_date) as anno,
        COUNT(r.rental_id) AS cantidad_prestamos
    FROM country co
        INNER JOIN city c ON co.country_id = c.country_id
        INNER JOIN address a ON c.city_id = a.city_id
        INNER JOIN store st ON a.address_id = st.address_id
        INNER JOIN staff s ON st.store_id = s.store_id
        INNER JOIN rental r ON s.staff_id = r.staff_id
    WHERE YEAR(r.rental_date) = 2005 AND (MONTH(r.rental_date) = 5 OR MONTH(r.rental_date) = 6)
    GROUP BY tienda, vendedor, anno, mes
),
pivote AS (
    SELECT
        tienda,
        vendedor,
        COALESCE(SUM(CASE WHEN mes=5 THEN cantidad_prestamos ELSE 0 END), 0) as prestamos_mayo,
        COALESCE(SUM(CASE WHEN mes=6 THEN cantidad_prestamos ELSE 0 END), 0) as prestamos_junio
    FROM prestamos
    GROUP BY tienda, vendedor
)
SELECT
    tienda,
    vendedor,
    prestamos_mayo,
    prestamos_junio,
    (prestamos_junio - prestamos_mayo) AS diferencia,
    CASE 
        WHEN prestamos_mayo = 0 THEN 100
        ELSE ((prestamos_junio - prestamos_mayo) / prestamos_mayo) * 100
    END AS porcentaje_crecimiento
FROM pivote
ORDER BY tienda, vendedor;
