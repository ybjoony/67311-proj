-- TRANSACTION EXAMPLE FOR PATS DATABASE
--
-- by Byungjoon Yoon & Leo Ying
--
--
BEGIN;
INSERT INTO visits (pet_id, date, weight)
VALUES (173, CURRENT_DATE,39);
INSERT INTO treatments(visit_id, procedure_id, successful, discount)
VALUES((select id from visits order by id desc limit 1),(select id from procedures where name ilike 'examination'),true,0);
INSERT INTO visit_medicines (visit_id, medicine_id, units_given, discount)
VALUES((select id from visits order by id desc limit 1),3,500,0);
INSERT INTO visit_medicines (visit_id, medicine_id, units_given, discount)
VALUES((select id from visits order by id desc limit 1),2,200,0);
COMMIT;
