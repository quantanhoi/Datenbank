DROP FUNCTION getfreeseats(character varying,date);  

  

create or replace function getFreeSeats(flight_id varchar, flight_datum date) returns integer as $$   
declare    
seats integer;    
booked integer;    
free_seats integer;    
begin    
select plane.seats into seats from plane    
join departure on plane.planeid = departure.planeid     
where flight_id = departure.flightid and flight_datum = departure.datum;    
select count(*) into booked from booking    
join passenger on passenger.customerid = booking.customerid    
where flight_id = booking.flightid and flight_datum = booking.datum;    
free_seats := seats - booked;    
return free_seats;    
end;$$   
language plpgsql;    

  

  

CREATE FUNCTION check_seats() 
RETURNS TRIGGER 
AS $$ 
declare remaining_seats integer; 
BEGIN 
remaining_seats := getFreeSeats(NEW.flightid, NEW.date); 
IF remaining_seats < 1 THEN 
RAISE EXCEPTION 'No remaining seats for this flight'; 
END IF; 
RETURN NEW; 
END; 
$$ LANGUAGE plpgsql; 

  

  

CREATE TRIGGER check_seats 

BEFORE INSERT ON booking 

FOR EACH ROW 

EXECUTE FUNCTION check_seats(); 

 

 

 

 

 

 

  


 

 

 