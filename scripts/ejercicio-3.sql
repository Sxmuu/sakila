use sakila;

WITH ventas AS (
    SELECT
        CONCAT(city, ',', country) AS tienda,
        staff_id,
        YEAR(payment_date) as anno,
        MONTH(payment_date) as mes,
        SUM(amount) as valor
    FROM country
        INNER JOIN city USING(country_id)
        INNER JOIN address USING(city_id)
        INNER JOIN store USING(address_id)
        INNER JOIN staff USING(store_id)
        INNER JOIN payment USING(staff_id)
        INNER JOIN customer USING(customer_id)
    GROUP BY tienda, staff_id, anno, mes
    ),
dta_alq as(
    SELECT
        staff_id,
        MONTH(rental_date) as mes,
        YEAR(rental_date) as anno,
        COUNT(*) as qty
    FROM rental
    GROUP BY staff_id, MONTH(rental_date), YEAR(rental_date)
    ),

pivote AS (
    SELECT
        tienda,
        SUM(
            CASE WHEN anno=2005 AND mes=5 THEN valor ELSE 0 END
        ) as mayo,
        SUM(
            CASE WHEN anno=2005 AND mes=6 THEN valor ELSE 0 END
        ) junio,
        SUM(
            CASE WHEN anno=2005 AND mes=7 THEN valor ELSE 0 END
        ) julio,
        COUNT(
            CASE WHEN anno=2005 AND mes=5 THEN qty ELSE 0 END
        ) mayo_qty,
        COUNT(
            CASE WHEN anno=2005 AND mes=6 THEN qty ELSE 0 END
        ) junio_qty,
        COUNT(
            CASE WHEN anno=2005 AND mes=7 THEN qty ELSE 0 END
        ) julio_qty
        FROM ventas INNER JOIN dta_alq USING(staff_id, anno, mes)
        GROUP BY tienda
    )
SELECT 
    tienda as 'Tienda',
    (mayo/mayo_qty) as 'Mayo 2005',
    (junio/junio_qty) as 'Junio 2005',
    ((junio/junio_qty)-(mayo/mayo_qty)) as 'Diferencia',
    (((junio/junio_qty)-(mayo/mayo_qty))/(mayo/mayo_qty)) as '%crecim',
    (julio/julio_qty) as 'Julio 2005',
    ((julio/julio_qty)-(junio/junio_qty)) as 'Diferencia',
    (((julio/julio_qty)-(junio/junio_qty))/(junio/junio_qty)) as '%crecim 2'
FROM pivote
LIMIT 5
;