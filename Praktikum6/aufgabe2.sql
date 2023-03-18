create view PassengerInfo as  

select distinct passenger.CustomerID, passenger.FirstName, passenger.LastName, booking.FlightID  

from passenger natural join booking order by passenger.CustomerID; 

select * from PassengerInfo; 

 

 

 