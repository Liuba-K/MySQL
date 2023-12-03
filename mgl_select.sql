/* 1.Список исследований (orders) выполненных в лаборатории (laboratory_1)  
за предыдущий год.*/
USE medical_genetic_laboratory;
SELECT l.created_at, cwg.name as complex, g.name as gene, l.orders_id, l.updated_at, o.created_at FROM laboratory_1 l
LEFT JOIN orders o ON o.id = l.orders_id 
LEFT JOIN orders_services os ON o.id = os.orders_id -- мы можем его убрать?
LEFT JOIN services s ON s.id = os.services_id -- мы можем его убрать?
LEFT JOIN complex_with_gene cwg ON s.complex_with_gene_id = cwg.id
LEFT JOIN genes g ON g.id = s.genes_id 
WHERE l.created_at >  CURDATE() - INTERVAL 1 YEAR
ORDER BY l.created_at DESC;

/*2.Запрошено заказов клиентами на сумму за пол года*/

SELECT SUM(s.price) FROM orders o
LEFT JOIN orders_services os ON o.id = os.orders_id 
LEFT JOIN services s ON os.services_id = s.id
WHERE o.created_at > CURDATE() - INTERVAL 6 MONTH;

/*3. выведи все результаты (генотипы) гена ut */

SELECT gt.genotype, gt.genes_id, o.id as orders, g.name  FROM orders o 
LEFT JOIN services s ON o.id = s.id -- соединяет таблица M-M 
LEFT JOIN genes g ON  g.id = s.genes_id -- соединяет таблица M-M
LEFT JOIN laboratory_1 l ON o.id=l.orders_id 
LEFT JOIN results_genes rg ON rg.laboratory_1_id = l.id 
LEFT JOIN genotypes gt ON rg.genotypes_id = gt.id 
WHERE g.name = 'ut';

/*4. вывести количество неоплаченных полностью заказов*/
SELECT COUNT(1), status, group_concat(clients_id)  FROM orders
WHERE status != 'paid'
GROUP BY status

/* 5. вывести информацию об неоплаченных полностью заказов*/
SELECT concat(c.lastname, ' ', c.firstname),c.patronymic,c.email,c.phone,  o.status, o.clients_id  FROM orders o
LEFT JOIN clients c ON o.clients_id = c.id -- таблицу материал необязательно добавлять?
WHERE status != 'paid';

/* 6.Вывести кто вносил результаты(изменения) за последний год?*/
SELECT s.name_staff, rg.staff_id,rg.created_at, rg.updated_at  FROM results_genes rg 
LEFT JOIN staff s ON rg.staff_id =s.id 
WHERE updated_at > NOW()- INTERVAL 1 YEAR

-- еще варианты задач
/*3.Найти наименее популярные анализы (service) */

/*4.вывести список заказов больше 10 дней.(??)
created_at(orders) created_at (laboratory_1)
created_at(lab


*/


-- нет соответств данных добавить
/*2.Выбрать первых трех сотрудников(name_staff) выполнивших наибольшее число заказов.

SELECT COUNT(o.id), group_concat(s.name_staff) FROM orders o 
LEFT JOIN laboratory_1 l ON o.id = l.orders_id 
LEFT JOIN laboratory_extract le ON o.id =le.orders_id 
-- UNION 
-- SELECT o.id,l.id,le.id FROM orders o 
-- RIGHT JOIN laboratory_1 l ON o.id = l.orders_id 
-- RIGHT JOIN laboratory_extract le ON o.id =le.orders_id
LEFT JOIN results_genes rg ON l.id = rg.laboratory_1_id
LEFT JOIN staff s ON rg.staff_id = s.id OR s.id = le.staff_id
GROUP BY COUNT (o.id)
ORDER BY COUNT (o.id) DESC
LIMIT 3;
*/