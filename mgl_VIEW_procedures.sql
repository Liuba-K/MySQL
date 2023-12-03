USE medical_genetic_laboratory;

CREATE OR REPLACE VIEW lab1 AS 
	SELECT 
		m.id as material, m.type_material,DATE(m.created_at) as cr_m, DATE(m.updated_at) as up_m,
		o.id as orders, DATE(o.created_at) as date_order, g.name as genes,l1.laboratory_extract_id as extract_id,
	-- DATE (le.created_at) as cr_le, DATE(le.updated_at) as up_le, DATE (l1.created_at) as cr_l1, DATE(l1.updated_at) as up_l1
		gt.genotype
		FROM laboratory_1 l1
		LEFT JOIN laboratory_extract le ON l1.laboratory_extract_id =le.id
		LEFT JOIN orders o ON l1.orders_id = o.id  
		LEFT JOIN material m ON o.material_id=m.id
		LEFT JOIN orders_services os ON o.id =os.orders_id 
		LEFT JOIN services s ON s.id =os.services_id 
		LEFT JOIN genes g ON s.genes_id = g.id 
		LEFT JOIN genotypes gt ON gt.genes_id =l1.id

CREATE OR REPLACE VIEW staffs AS 
	SELECT 
		s.name_staff,s.name_lab, gt.genotype, g.name,DATE(l1.created_at),DATE(l1.updated_at),s1.id,le.status_extract,	
		DATE(o.created_at) as orders, rg.created_at,rg.updated_at 
		FROM staff s
		LEFT JOIN results_genes rg ON s.id =rg.staff_id 
		LEFT JOIN laboratory_1 l1 ON rg.staff_id  =l1.id 
		LEFT JOIN genotypes gt ON gt.genes_id =l1.id
		LEFT JOIN laboratory_extract le ON s.id = le.staff_id 		
		LEFT JOIN orders o ON l1.orders_id = o.id  		
		LEFT JOIN orders_services os ON o.id =os.orders_id 
		LEFT JOIN services s1 ON s1.id =os.services_id 
		LEFT JOIN genes g ON s1.genes_id = g.id 
		
-- тригерры
		
DELIMITER //
DROP TRIGGER IF EXISTS gtNullIns //
CREATE TRIGGER gtNullIns BEFORE INSERT ON genotypes 
FOR EACH ROW
BEGIN
	IF NEW.genotype IS NULL THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'genotype isn\'t NULL';
	END IF;
END//

DROP TRIGGER IF EXISTS gtNullUp //
CREATE TRIGGER gtNullUp BEFORE UPDATE ON genotypes
FOR EACH ROW
BEGIN 
	IF NEW.genotype IS NULL THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'genotype isn\'t NULL';
	END IF;
END//
DELIMITER ;


INSERT INTO genotypes (genotype,genes_id)
VALUES
	('bhjk','100');

INSERT INTO genotypes (genotype,genes_id)
VALUES
	(NULL,'100');

UPDATE genotypes
SET genotype=NULL
WHERE id=101;

UPDATE genotypes
SET genotype='ID'
WHERE id=101;

-- тригеры
DELIMITER //
DROP TRIGGER IF EXISTS discount_Ins //
CREATE TRIGGER discount_Ins BEFORE INSERT ON discount 
FOR EACH ROW
BEGIN
	IF NEW.finished_at < NEW.started_at THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You should change date finished_at';
	END IF;
END//

DROP TRIGGER IF EXISTS discount_Up //
CREATE TRIGGER discount_Up BEFORE UPDATE ON discount
FOR EACH ROW
BEGIN 
	IF NEW.finished_at < NEW.started_at THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You should change date finished_at';
	END IF;
END//
DELIMITER ;

INSERT INTO discount  (services_id, discount, finished_at,started_at)
VALUES
	('100','0.07', '2022-04-15 00:00:00', '2022-04-11 00:00:00'),
	('100','0.07', '2022-04-09', '2022-04-11');

update discount
SET discount = 0.08,
	finished_at = '2022-04-09',
	started_at ='2022-04-10'
WHERE services_id = '100';

-- select '2022-04-19'>='2022-04-15'
-- процедуры или функции
-- service_offer
DELIMITER //
DROP PROCEDURE IF EXISTS current_discount//
CREATE PROCEDURE current_discount()
BEGIN
	select discount, finished_at FROM discount
	WHERE DATE(finished_at)>DATE(now());
END//
DELIMITER ;

CALL current_discount();


DELIMITER //
DROP PROCEDURE IF EXISTS possible_relatives//
CREATE PROCEDURE possible_relatives()
BEGIN
	SELECT lastname, COUNT(1)  FROM clients
	GROUP BY lastname 
	HAVING COUNT(1)>1
	ORDER BY COUNT(1) DESC;
END//
DELIMITER ;

CALL possible_relatives();
