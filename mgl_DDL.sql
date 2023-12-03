/* темы курсового проекта: медико-генетическая лаборатория
Описание БД: 
1)Клиент приходит в лабораторию, сдает материал для своего заказа из услуг предоставляемых учреждением(лабораторией).
Сущности(таблицы):
clients - информация о клиенте, которая должна быть зашифрована. 
	-- Варианты усложнения БД (не осуществленно здесь). В жизни клиент может заполнять еще анкету перед заказам,если хочет чтобы использовали его материал в научных интересах и информированное согласие, а также анкету после заказа об удовлетворенности потребителя.
material - биологический материал сданный клиентом для дальнейшей работы. Один клиент может сдать несколько материалов(кровь, буккальный эпителий и т.д.).
	Нюанс: при выполнении заказа бывает материал закончился либо с ним проблемно работать, тогда клиент досдает материал (осуществила через type_material), 
		но номер образца должен быть прошлый и возможно с пометкой New (не смогла осущесвить, возможно нужна еще одна программа).
	-- Варианты усложнения БД (не осуществленно здесь). Иногда материал проверяют на качество для работы  в дальнейшем исследовании в отдельной лаборатории
orders - непосредственно сам заказ клиента (на этом этапе формируется договор) в который включается id клиента(кто?), id материала(с чем работать? я думаю, что это и будет номер образца), комплес(что делать?), цена(?) за комплекс услуг выбранный клиентом
	Нюанс: на этом этапе клиент оплачивает свой заказ и оплата может быть полной, частичной или через 5 дней согласно договору.
	!? так как связь М-М (между клиентами и услугами), то создает промежуточную таблицу и поэтому в orders нет полей комплекс и цена
orders-services -таблица для связи
	? Интересно промежуточная таблица может участвовать в других связях?
services - объединяет услуги из трех таблиц other_service, complex_with_gene, genes
	Нюанс: не совсем понятно где лучше указывать price? здесь должна подтягивать из других таблиц соответственно..
other_service - перечисление услуг с ответом на результат да/нет или обязательных в каждом комплексе(н-р оформление документации)
complex_with_gene - в один комплекс входит несколько генов (одни гены могут быть в разных комплексах). Таблица нужна для оптимизации работы при заказе, чтобы не выбирать каждый ген в ручную.
genes - список генов
2) После оформления заказа материал должен поступить в лабораторию на выделения. 
	Нюанс: лаборатория работает с материалом, но она выделяет только если это прописано в заказе (orders). Клиент может дозаказать услугу(тогда используется прошлый материал).
staff - список пользователей пользующих базой и вносящих изменения в нее(они могут работь в разных лабораториях)
	Нюанс (не осуществлен)- к сотруднику должны в идеале быть прикреплены обязательства (возможно необходимы еще таблицы?)
laboratory_extract - (с талицей работает несколько пользователей) поступает материал id и выделяется сотрудником (кто взял на исследование, я не осуществила).
	После выделения сотрудник(staff_id) вносит изменения об status_extract. 
	--пока сделанно, что если образец выделен, то сотрудник ищет материал и передает дальше (изменения не вносятся)
	(не осуществленно) В идеале автоматом подтягивается staff_id.
3) После выделения материала, образец идет в другие лаборатории для выполнения их сотрудников заказов. 
	!?В идеале номера должны быть одинаковыми material_id=laboratory_extract_id, но если образец не поступает на этот этап, что делать? А если нужно повторно выделить тот же материал?(пока что я сделала, что в таблицы материал можно указать повторный материал(type_material-repeated)
laboratory_1 - поступает выделенный образец (laboratory_extract_id). Сотрудники смотрят заказ и выполняют его. 
!?	После выполнения им необходимо внести результаты (оказалось самое трудное место).	
	Для внесения результатов созданна таблица:
genotypes - перечислены результаты(генотипа) вносимые сотрудником для каждой услуги id_genes
results_genes -дополнительная таблица для связи М-М,  необходимо объединить заказ (но только заказ genes) c возможным genotypes.
	Нужно указать кто выполнил эту часть заказа и внес изменения.
	
(не осуществленно) В реальности существует несколько лабораторий, которые выполняют заказ. После выполнения ими части все результаты должны попасть в результирующую таблицу и автоматом поставиться дата окончания исследования.
					После окончания исследования, где-то должен формироваться документ об заключении результатов.	

4) Учреждения может решить сделать скидку на определенные услуги (в реальности еще и скидка от какой-то суммы)
	discount -скидка на какую-нибудь услугу
? я думаю, что если оставляем цену в таблице service_id, то discount должна связываться именно с ней иначе с тремя таблицами об услугах
*/
DROP DATABASE IF EXISTS medical_genetic_laboratory;
CREATE DATABASE medical_genetic_laboratory;

USE medical_genetic_laboratory;

DROP TABLE IF EXISTS clients;
CREATE TABLE clients (
id SERIAL PRIMARY KEY,
lastname VARCHAR(50) COMMENT 'Фамилия',
firstname VARCHAR(50) COMMENT 'Имя',
patronymic VARCHAR(50) COMMENT 'Отчество',
email VARCHAR(120) UNIQUE,
phone BIGINT, 
gender ENUM ('f','m','NULL') DEFAULT NULL,-- необязательное поле, CHAR 1
INDEX users_lastname_idx(lastname)
) COMMENT 'Информация о клиенте'; -- это таблица должна шифроваться (анонимность)

DROP TABLE IF EXISTS material;
CREATE TABLE material(
id SERIAL PRIMARY KEY, -- текст номер (+ буква желательно, но не знаю как)
clients_id BIGINT UNSIGNED NOT NULL,
name VARCHAR(50), -- можно сделать варианты, кровь, букальный эпителий, парафиновые блоки
other_client ENUM ('YES','NO') DEFAULT 'NO',
notes TEXT COMMENT 'Примечание' DEFAULT NULL,-- lastname_firstname если материал ребенка
type_material SET ('initial','repeated') DEFAULT 'initial', -- или enum и еще одна таблица?(не знаю как лучше)
created_at DATETIME DEFAULT NOW(),
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- если повторный вариант
FOREIGN KEY (clients_id) REFERENCES clients(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS orders;
CREATE TABLE orders(
id SERIAL PRIMARY KEY,
clients_id BIGINT UNSIGNED NOT NULL,
material_id BIGINT UNSIGNED,
-- price_complex_type_id BIGINT UNSIGNED, лишнее поле здесь??
notes TEXT COMMENT 'Примечание при регистрации', -- можно подтягивать ФИО  ребенка, либо указывать просьбу о срочности клиента и т.д.
status ENUM ('paid','partially paid','unpaid') DEFAULT 'unpaid',
created_at DATETIME DEFAULT NOW(),
FOREIGN KEY (material_id) REFERENCES material(id) ON UPDATE CASCADE ON DELETE CASCADE
);
-- в одном заказе 1 материал и 1 клиент
-- у одного пользователя может быть много заказов
-- в одном заказе может быть несколько комплексов???стоит сделать отдельные заказы M-M
-- индекс? наверное не нужен 

DROP TABLE IF EXISTS genes;
CREATE TABLE genes(
id SERIAL PRIMARY KEY,
name VARCHAR(50),
describes_genotypes TEXT,
price DECIMAL (11,2) COMMENT 'Цена',
add_services SET ('No','Extract', 'Registration') DEFAULT 'No', 
INDEX genes_name_idx(name)
);

DROP TABLE IF EXISTS genotypes;
CREATE TABLE genotypes (
id SERIAL PRIMARY KEY,
genotype VARCHAR(50), -- у одного гена три генотипа или больше
genes_id BIGINT UNSIGNED NOT NULL,
describes_genotypes TEXT,
FOREIGN KEY (genes_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS complex_with_gene;
CREATE TABLE complex_with_gene(
id SERIAL PRIMARY KEY,
name VARCHAR(100), -- выделения, фрагментный анализ, ?? один id может содержать несколько генов
genes_id BIGINT UNSIGNED NOT NULL,
price DECIMAL (11,2) COMMENT 'Цена', -- лишнее поле
INDEX complex_name_idx(name),
FOREIGN KEY (genes_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS complex_gene;
CREATE TABLE complex_gene(
complex_with_gene_id BIGINT UNSIGNED NOT NULL,
genes_id BIGINT UNSIGNED NOT NULL,
PRIMARY KEY (complex_with_gene_id,genes_id),
FOREIGN KEY (complex_with_gene_id) REFERENCES complex_with_gene (id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (genes_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE
);


DROP TABLE IF EXISTS services;
CREATE TABLE services(
id SERIAL PRIMARY KEY,
genes_id BIGINT UNSIGNED DEFAULT NULL,
complex_with_gene_id BIGINT UNSIGNED,
price DECIMAL (11,2) COMMENT 'Цена', -- эта цена должна подтягиваться из трех таблиц взависимости какую описывает...
CONSTRAINT FK_complex_with_gene FOREIGN KEY (complex_with_gene_id) REFERENCES complex_with_gene (id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS service_gene;
CREATE TABLE service_gene(
service_id BIGINT UNSIGNED NOT NULL,
genes_id BIGINT UNSIGNED NOT NULL,
PRIMARY KEY (service_id,genes_id),
FOREIGN KEY (service_id) REFERENCES services (id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (genes_id) REFERENCES genes(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS orders_services;
CREATE TABLE orders_services(
services_id BIGINT UNSIGNED NOT NULL,
orders_id BIGINT UNSIGNED NOT NULL,
created_at DATETIME DEFAULT NOW(),
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (services_id, orders_id),
FOREIGN KEY (services_id) REFERENCES services(id) ON UPDATE CASCADE ON DELETE CASCADE,
FOREIGN KEY (orders_id) REFERENCES orders(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS staff;
CREATE TABLE staff(
id SERIAL PRIMARY KEY,
name_lab VARCHAR(80),
name_staff VARCHAR (50),
INDEX staff_name_idx (name_staff)
-- complex_type_id BIGINT UNSIGNED NOT NULL, -- к 1 лабе прикреплены несколько анализов
-- FOREIGN KEY (complex_type_id) REFERENCES complex_type(id) ON UPDATE CASCADE ON DELETE CASCADE
);

	
DROP TABLE IF EXISTS laboratory_extract;
CREATE TABLE laboratory_extract(
id SERIAL PRIMARY KEY,
material_id BIGINT UNSIGNED NOT NULL,
created_at DATETIME DEFAULT NOW(),
orders_id BIGINT UNSIGNED NOT NULL, -- лишний? равен complex_type_id
status_extract ENUM ('YES', 'NO') DEFAULT 'NO', -- если yes то поле employe NOT NULL
staff_id BIGINT UNSIGNED NOT NULL,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT FK_orders_id FOREIGN KEY (orders_id) REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS laboratory_1;
CREATE TABLE laboratory_1( -- если лаборатории выделила, то попадает сюда
id SERIAL PRIMARY KEY,
laboratory_extract_id BIGINT UNSIGNED NOT NULL,
created_at DATETIME DEFAULT NOW(),
orders_id BIGINT UNSIGNED NOT NULL, -- возможно поле разбить на несколько?
-- genotypes_id BIGINT UNSIGNED DEFAULT NULL, -- можем NULL
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
CONSTRAINT FK_laboratory_extract FOREIGN KEY (laboratory_extract_id) 
	REFERENCES laboratory_extract(id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fk2_orders_id FOREIGN KEY (orders_id) 
	REFERENCES orders(id) ON DELETE CASCADE ON UPDATE CASCADE
);


DROP TABLE IF EXISTS results_genes;
CREATE TABLE results_genes( -- надеюсь правильно связано
-- orders_id BIGINT UNSIGNED NOT NULL,
laboratory_1_id BIGINT UNSIGNED NOT NULL,
genotypes_id BIGINT UNSIGNED NOT NULL,
staff_id BIGINT UNSIGNED NOT NULL,
PRIMARY KEY (laboratory_1_id, genotypes_id),
created_at DATETIME DEFAULT NOW(),
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
-- FOREIGN KEY (services_id) REFERENCES orders_services(services_id) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (genotypes_id) REFERENCES genotypes(id) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (laboratory_1_id) REFERENCES laboratory_1 (id) ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE ON UPDATE CASCADE
-- FOREIGN KEY (orders_id) REFERENCES orders_services(id) ON DELETE CASCADE ON UPDATE CASCADE
);



DROP TABLE IF EXISTS discount;
CREATE TABLE discount(
id SERIAL PRIMARY KEY,
services_id BIGINT UNSIGNED NOT NULL, -- нужно выбрать id, где можно сделать скидку, за какое-то время
discount FLOAT UNSIGNED COMMENT 'Величина скидки от 0.0 до 1.0',
finished_at DATETIME,
started_at DATETIME,
created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'скидки'; -- интересно стоит ли добавлять price_id в сервис

ALTER TABLE discount ADD FOREIGN KEY (services_id) REFERENCES services (id) ON DELETE CASCADE ON UPDATE CASCADE;