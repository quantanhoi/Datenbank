import psycopg2
import sqlalchemy.exc
from sqlalchemy import *

hostn1ame = "postgres.fbi.h-da.de"
database = "sttrthie"
user = "test_user1"
pwd = "1234"
server = "141.100.70.93"

# Create an engine object with connection information to the database
# This uses python f-strings, see https://peps.python.org/pep-0498/
engine = create_engine(f"postgresql+psycopg2://{user}:{pwd}@{server}/{database}", echo=True)
connection = engine.connect()
metadata = MetaData()

airport = Table('airport', metadata, autoload_with=engine)
flight = Table('flight', metadata, autoload_with=engine)
departure = Table('departure', metadata, autoload_with=engine)
passenger = Table('passenger', metadata, autoload_with=engine)
booking = Table('booking', metadata, autoload_with=engine)


def get_all_airports():
    query = select(airport.columns.iata, airport.columns.name)
    result_proxy = connection.execute(query)
    return result_proxy.fetchall()
    pass


def login(vorname: str, nachname: str) -> int:
    """Logs in a user, creating them if necessary

    You have to implement this function.
    This function shall first query the database, if a user with the given parameters
    vorname, nachname exists. If it does, then return the Kundennummer of the user.

    If the user does not exists, determine the next unused Kundennummer, create the user
    in the database and return the new Kundennummer.
    Don't forget to commit the connection after the insert!
    """
    query = select(passenger.c.customerid).where(and_(passenger.c.firstname == vorname, passenger.c.lastname == nachname))
    print(query)
    result_proxy = connection.execute(query)
    passenger_id = result_proxy.fetchone()
    if passenger_id is not None:
        return passenger_id[0]

    query = select(func.max(passenger.columns.customerid))

    result_proxy = connection.execute(query)
    highest_passenger_number = result_proxy.fetchone()

    if highest_passenger_number is None:
        print("Can't get highest customerid")
        return -1

    new_passenger_number = highest_passenger_number[0] + 1

    query = insert(passenger).values(customerid=new_passenger_number, firstname=vorname, lastname=nachname)

    result_proxy = connection.execute(query)

    connection.commit()

    return new_passenger_number

    pass


def book_flight(current_user: int, home: str, flight=flight, airport=airport):
    """Book a flight for the currently logged in user, starting from the home airport

    You have to implement this function.
    Obviously, this function will only work is current_user and home are filled with
    correct data. This is already implemented in the menu, so you can assume that the
    values are corrent.
    First, present the user with a list of all flights starting at the home airport.
    The list shall contain (at least) the following information:
    - Flight number
    - Departure Date
    - **Name** of the destination airport

    The user then chooses which flight they would like to book and the booking is completed
    by inserting the correct values to the table. Assume that all flights are 99 Euros/Dollar.
    Don't forget to commit the connection after the insert!
    """
    """query = select(departure.columns.flightid, departure.columns.datum, airport.columns.name)
    query = query \
        .select_from(departure
                     .join(flight, departure.columns.flightid == flight.columns.flightid)
                     .join(airport, airport.columns.iata == flight.columns.dest_iata)) \
        .where(flight.columns.orig_iata == home)"""
    query = select(departure.columns.flightid, departure.columns.datum, airport.columns.name).select_from(
        departure.join(flight, flight.columns.flightid == departure.columns.flightid).join(airport,
                                                                                           airport.columns.iata == flight.columns.dest_iata)).where(flight.columns.orig_iata == home)

    result_proxy = connection.execute(query)
    flights = result_proxy.fetchall()

    if not flights:
        print("Keine Flüge gefunden")
        return

    for flight in enumerate(flights):
        print(flight[0], flight[1][0], flight[1][1], flight[1][2])

    inp = int(input("Welche Flugnummer? "))
    if inp < 0 or inp >= len(flights):
        print("Ungültige Nummer")
        return

    flight = flights[inp]
    flight_number = flight[0]
    date = flight[1]

    print("current user: ", current_user, " flightid: ", flight_number, " date: ", date)

    query = insert(booking).values(customerid=current_user, flightid=flight_number, datum=date, price=100.000)

    try:
        result_proxy = connection.execute(query)
        print(f"Flug {flight_number} für Datum {date} wurde gebucht.")
        result = connection.execute(select(booking))
        for row in result:
            print(row)
        connection.commit()
    except sqlalchemy.exc.IntegrityError:
        print(f"Sie haben den Flug {flight_number} für Datum {date} bereits gebucht.")


if __name__ == "__main__":

    current_user = None
    home = None
    while True:
        print()
        if current_user is None:
            print("Buchungssystem für Flüge - Hauptmenü")
            print("------------------------------------")
        else:
            print(
                f"Buchungssystem für Flüge - Hauptmenü (Eingeloggt: {current_user})")
            print("----------------------------------------------------")

        print("1 Benutzer einloggen")
        if current_user is not None:
            print("2 Heimatflughafen wählen")
            print("3 Flüge anzeigen und buchen")
        print("0 Programm beenden")
        inp = input("Eingabe? ")

        if inp == "0":
            break

        if inp == "1":
            vorname = input("Vorname? ")
            nachname = input("Nachname? ")
            current_user = login(vorname, nachname)
            print("Passagier eingeloggt")

        if current_user is not None and inp == "2":
            print()
            airports = get_all_airports()
            for airport in enumerate(airports):
                print(airport[0], airport[1][0], airport[1][1])
            inp = int(input("Welche Flughafennummer? "))
            if inp < 0 or inp >= len(airports):
                print("Ungültige Nummer ausgewählt!")
            else:
                home = airports[inp][0]

        if current_user is not None and inp == "3":
            if home is None:
                print("Bitte zuerst einen Heimatflughafen wählen")
            else:
                book_flight(current_user, home)
