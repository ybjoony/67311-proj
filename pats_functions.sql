-- FUNCTIONS AND TRIGGERS FOR PATS DATABASE
--
-- by Byungjoon Yoon & Leo Ying
--
--In terms of functions and triggers, the phase 1 solution indicates that we need triggers to automatically set the end_date of either procedure_costs or medicine_costs to the current date before a new record is added. We also need a trigger to automatically reduce the medicine stock levels after a new visit_medicine application is recorded in the system. Finally we need functions to calculate whether the overnight_stay flag in the visits table needs to be set to true as well as calculate the total costs for a particular visit. (See the functions template for an exact list of functions, triggers and the exact names each should be called.)
-- calculate_total_costs
-- (associated with two triggers: update_total_costs_for_medicines_changes & update_total_costs_for_treatments_changes)
CREATE OR REPLACE FUNCTION calculate_total_costs() RETURNS TRIGGER AS $$
    DECLARE
        visit  INTEGER;
        medicine INTEGER;
        med_cost INTEGER;
        procedure_cost INTEGER;
        total_cost INTEGER;
        med_discount FLOAT;
        procedure INTEGER;
        procedure_discount FLOAT;
        med_units INTEGER;
        row_data RECORD;
    BEGIN
        total_cost = 0;
        visit = NEW.visit_id;
        RAISE NOTICE 'Visit ID is %', visit;
        --- Medicine Costs ---
        FOR row_data IN (SELECT DISTINCT * FROM visit_medicines WHERE visit_id = visit)
        LOOP

            medicine = row_data.medicine_id;
            med_cost = (SELECT cost_per_unit 
                       FROM medicine_costs mc 
                       JOIN medicines m on mc.medicine_id = m.id 
                       WHERE mc.end_date IS NULL AND mc.medicine_id = medicine);
            
 
            med_discount = (SELECT discount FROM visit_medicines 
                            WHERE medicine_id = medicine AND id = row_data.id);

            med_units = (SELECT units_given from visit_medicines 
                            WHERE id = row_data.id);

            total_cost = total_cost + ((1-med_discount) * (med_units*med_cost));
            RAISE NOTICE 'Medicine units is %', med_units;
            RAISE NOTICE 'Medicine discount is %', med_discount;
            RAISE NOTICE 'Medicine cost is %', med_cost;
            RAISE NOTICE 'Total cost is %', total_cost;
        END LOOP;
 
        --- Procedure Costs ---
        FOR row_data IN (SELECT DISTINCT * FROM treatments WHERE visit_id = visit)
        LOOP
            procedure = row_data.procedure_id;
            procedure_cost = (SELECT DISTINCT cost 
                             FROM procedure_costs pc 
                             JOIN procedures p ON pc.procedure_id = p.id 
                             JOIN treatments t ON t.procedure_id = p.id
                             WHERE pc.end_date IS NULL AND pc.procedure_id = procedure);
 
            procedure_discount = (SELECT discount FROM treatments 
                                    WHERE procedure_id = procedure AND id = row_data.id);
 
            total_cost = total_cost + ((1-procedure_discount) * procedure_cost);
            RAISE NOTICE 'Procedure cost is %', procedure_cost;
            RAISE NOTICE 'Procedure discount is %', procedure_discount;
            RAISE NOTICE 'Total cost is %', total_cost;   
        END LOOP;
        UPDATE visits SET total_charge = total_cost WHERE id = visit;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;
 
--** TRIGGERS **--
CREATE TRIGGER update_total_costs_for_medicines_changes
AFTER INSERT OR UPDATE ON visit_medicines FOR EACH ROW
EXECUTE PROCEDURE calculate_total_costs();

CREATE TRIGGER update_total_costs_for_treatments_changes
AFTER INSERT OR UPDATE ON treatments FOR EACH ROW
EXECUTE PROCEDURE calculate_total_costs();

-- calculate_overnight_stay
-- (associated with a trigger: update_overnight_stay_flag)
CREATE OR REPLACE FUNCTION calculate_overnight_stay() RETURNS TRIGGER AS $$
	DECLARE
		time INTEGER;
		t INTEGER;
	BEGIN
		time = (SELECT SUM(length_of_time) FROM procedures WHERE id IN (SELECT procedure_id FROM treatments WHERE visit_id = NEW.visit_id));
			
	IF time >720 THEN UPDATE visits SET overnight_stay = true WHERE id = NEW.visit_id; END IF;
	  RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_overnight_stay_flag ON treatments;
CREATE TRIGGER update_overnight_stay_flag
AFTER INSERT ON treatments
FOR EACH ROW
EXECUTE PROCEDURE calculate_overnight_stay();



-- set_end_date_for_medicine_costs
-- (associated with a trigger: set_end_date_for_previous_medicine_cost)
CREATE OR REPLACE FUNCTION set_end_date_for_medicine_cost() RETURNS TRIGGER AS $$
	BEGIN

	UPDATE medicine_costs SET end_date = current_date WHERE medicine_id = NEW.medicine_id AND end_date IS  NULL;
	  RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS set_end_date_for_previous_medicine_cost ON medicine_costs;
CREATE TRIGGER set_end_date_for_previous_medicine_cost
BEFORE INSERT ON medicine_costs
FOR EACH ROW
EXECUTE PROCEDURE set_end_date_for_medicine_cost();




-- set_end_date_for_procedure_costs
-- (associated with a trigger: set_end_date_for_previous_procedure_cost)
CREATE OR REPLACE FUNCTION set_end_date_for_procedure_cost() RETURNS TRIGGER AS $$
	BEGIN

	UPDATE procedure_costs SET end_date = current_date WHERE procedure_id = NEW.procedure_id AND end_date IS NULL;
	  RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS set_end_date_for_previous_procedure_cost ON procedure_costs;
CREATE TRIGGER set_end_date_for_previous_procedure_cost
BEFORE INSERT ON procedure_costs
FOR EACH ROW
EXECUTE PROCEDURE set_end_date_for_procedure_cost();




-- decrease_stock_amount_after_dosage
-- (associated with a trigger: update_stock_amount_for_medicines)
CREATE OR REPLACE FUNCTION decrease_stock_amount_after_dosage() RETURNS TRIGGER AS $$
	BEGIN
	
	UPDATE medicines SET stock_amount = stock_amount - NEW.units_given WHERE id = NEW.medicine_id;
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_stock_amount_for_medicines ON visit_medicines;
CREATE TRIGGER update_stock_amount_for_medicines
AFTER INSERT ON visit_medicines
FOR EACH ROW
EXECUTE PROCEDURE decrease_stock_amount_after_dosage();




-- verify_that_medicine_requested_in_stock
-- (takes medicine_id and units_needed as arguments and returns a boolean)
CREATE OR REPLACE FUNCTION verify_that_medicine_requested_in_stock(medicine_id INTEGER,units_needed INTEGER) RETURNS boolean AS $$
	DECLARE
		result boolean;
	BEGIN
		IF (SELECT stock_amount FROM medicines WHERE id = medicine_id) >= units_needed 
		THEN result = true;
		ELSE result = false;
		END IF;
	RETURN result;
	END;
	$$ LANGUAGE plpgsql;


-- verify_that_medicine_is_appropriate_for_pet
-- (takes medicine_id and pet_id as arguments and returns a boolean)
CREATE OR REPLACE FUNCTION verify_that_medicine_is_appropriate_for_pet(medicine_id INTEGER,pet_id INTEGER) RETURNS boolean AS $$
	DECLARE
		result boolean;
		ani_id INTEGER;
		med_id INTEGER;
	BEGIN
		ani_id = (SELECT animal_id FROM pets WHERE id = pet_id);
		med_id = medicine_id;
		IF (SELECT animal_id FROM animal_medicines a WHERE a.medicine_id = med_id AND a.animal_id = ani_id ) IS NULL 
		THEN result = false;
		ELSE result = true;
		END IF;
	RETURN result;
	END;
	$$ LANGUAGE plpgsql;
