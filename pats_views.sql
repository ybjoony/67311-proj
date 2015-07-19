-- VIEWS FOR PATS DATABASE
--
-- by Byungjoon Yoon & Leo Ying
--
create view owners_view as 
	select owners.id as "owner_id", first_name, last_name, street, city, zip, phone, email, owners.active as "active_owener", state,animals.name as "animal_name", pets.name as "pet_name", female, date_of_birth, pets.active as "active_pet", visits.id as "visit_id", date ,weight,overnight_stay, total_charge  
	from owners join pets on owners.id=pets.owner_id join animals on pets.animal_id=animals.id join visits on visits.pet_id= pets.id ;


create view  medicine_views as 
	select medicines.name as "medicine_name", description, stock_amount, method, unit, vaccine, animals.name as "animal", recommended_num_of_units,
cost_per_unit as "current_cost", start_date
	from medicines join animal_medicines on medicines.id= animal_medicines.medicine_id join animals on animal_medicines.animal_id=animals.id join medicine_costs on medicine_costs.medicine_id=medicines.id
	where end_date is null;
