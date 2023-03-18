/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     05-Dec-22 3:14:00 PM                         */
/*==============================================================*/


drop index if exists AIRPORT_PK cascade;

drop table if exists Airport cascade;

drop index if exists DEPARTUREBOOKING_FK cascade;

drop index if exists PASSENGERBOOKING_FK cascade;

drop index if exists BOOKING_PK cascade;

drop table if exists Booking cascade;

drop index if exists DEPARTURE_PLANE_FK cascade;

drop index if exists DEPARTURE_FLIGHT_FK cascade;

drop index if exists DEPARTURE_PK cascade;

drop table if exists Departure cascade;

drop index if exists FLIGHTDEST_AIRPORT_FK cascade;

drop index if exists FLIGHTORIG_AIRPORT_FK cascade;

drop index if exists FLIGHT_PK cascade;

drop table if exists Flight cascade;

drop index if exists MAINTENANCETECHNICIAN_FK cascade;

drop index if exists PLANEMAINTENANCE_FK cascade;

drop index if exists MAINTENANCE_PK cascade;

drop table if exists Maintenance cascade;

drop index if exists PASSENGER_PK cascade;

drop table if exists Passenger cascade;

drop index if exists PLANE_PK cascade;

drop table if exists Plane cascade;

drop index if exists TECHNICIAN_PK cascade;

drop table if exists Technician cascade;

/*==============================================================*/
/* Table: Airport                                               */
/*==============================================================*/
create table Airport (
   IATA                 VARCHAR(254)         not null,
   Name                 VARCHAR(254)         null,
   Longitude            NUMERIC              null,
   Latitude             NUMERIC              null,
   constraint PK_AIRPORT primary key (IATA)
);

/*==============================================================*/
/* Index: AIRPORT_PK                                            */
/*==============================================================*/
create unique index AIRPORT_PK on Airport (
IATA
);

/*==============================================================*/
/* Table: Booking                                               */
/*==============================================================*/
create table Booking (
   CustomerID           INT4                 not null,
   FlightID             VARCHAR(254)         not null,
   Datum                DATE                 not null,
   Price                NUMERIC              not null,
   constraint PK_BOOKING primary key (FlightID, CustomerID, Datum)
);

/*==============================================================*/
/* Index: BOOKING_PK                                            */
/*==============================================================*/
create unique index BOOKING_PK on Booking (
FlightID,
CustomerID,
Datum
);

/*==============================================================*/
/* Index: PASSENGERBOOKING_FK                                   */
/*==============================================================*/
create  index PASSENGERBOOKING_FK on Booking (
CustomerID
);

/*==============================================================*/
/* Index: DEPARTUREBOOKING_FK                                   */
/*==============================================================*/
create  index DEPARTUREBOOKING_FK on Booking (
FlightID,
Datum
);

/*==============================================================*/
/* Table: Departure                                             */
/*==============================================================*/
create table Departure (
   FlightID             VARCHAR(254)         not null,
   Datum                DATE                 not null,
   PlaneID              VARCHAR(254)         not null,
   constraint PK_DEPARTURE primary key (FlightID, Datum)
);

/*==============================================================*/
/* Index: DEPARTURE_PK                                          */
/*==============================================================*/
create unique index DEPARTURE_PK on Departure (
FlightID,
Datum
);

/*==============================================================*/
/* Index: DEPARTURE_FLIGHT_FK                                   */
/*==============================================================*/
create  index DEPARTURE_FLIGHT_FK on Departure (
FlightID
);

/*==============================================================*/
/* Index: DEPARTURE_PLANE_FK                                    */
/*==============================================================*/
create  index DEPARTURE_PLANE_FK on Departure (
PlaneID
);

/*==============================================================*/
/* Table: Flight                                                */
/*==============================================================*/
create table Flight (
   FlightID             VARCHAR(254)         not null,
   Dest_IATA            VARCHAR(254)         not null,
   Orig_IATA            VARCHAR(254)         not null,
   constraint PK_FLIGHT primary key (FlightID)
);

/*==============================================================*/
/* Index: FLIGHT_PK                                             */
/*==============================================================*/
create unique index FLIGHT_PK on Flight (
FlightID
);

/*==============================================================*/
/* Index: FLIGHTORIG_AIRPORT_FK                                 */
/*==============================================================*/
create  index FLIGHTORIG_AIRPORT_FK on Flight (
Orig_IATA
);

/*==============================================================*/
/* Index: FLIGHTDEST_AIRPORT_FK                                 */
/*==============================================================*/
create  index FLIGHTDEST_AIRPORT_FK on Flight (
Dest_IATA
);

/*==============================================================*/
/* Table: Maintenance                                           */
/*==============================================================*/
create table Maintenance (
   PlaneID              VARCHAR(254)         not null,
   tID                  INT4                 not null,
   Datum                DATE                 not null,
   constraint PK_MAINTENANCE primary key (PlaneID, tID, Datum)
);

/*==============================================================*/
/* Index: MAINTENANCE_PK                                        */
/*==============================================================*/
create unique index MAINTENANCE_PK on Maintenance (
PlaneID,
tID,
Datum
);

/*==============================================================*/
/* Index: PLANEMAINTENANCE_FK                                   */
/*==============================================================*/
create  index PLANEMAINTENANCE_FK on Maintenance (
PlaneID
);

/*==============================================================*/
/* Index: MAINTENANCETECHNICIAN_FK                              */
/*==============================================================*/
create  index MAINTENANCETECHNICIAN_FK on Maintenance (
tID
);

/*==============================================================*/
/* Table: Passenger                                             */
/*==============================================================*/
create table Passenger (
   CustomerID           INT4                 not null,
   FirstName            VARCHAR(254)         null,
   LastName             VARCHAR(254)         null,
   BonusMiles           INT4                 null default 0,
   constraint PK_PASSENGER primary key (CustomerID)
);

/*==============================================================*/
/* Index: PASSENGER_PK                                          */
/*==============================================================*/
create unique index PASSENGER_PK on Passenger (
CustomerID
);

/*==============================================================*/
/* Table: Plane                                                 */
/*==============================================================*/
create table Plane (
   PlaneID              VARCHAR(254)         not null,
   Type                 VARCHAR(254)         null,
   Seats                INT4                 not null,
   constraint PK_PLANE primary key (PlaneID)
);

/*==============================================================*/
/* Index: PLANE_PK                                              */
/*==============================================================*/
create unique index PLANE_PK on Plane (
PlaneID
);

/*==============================================================*/
/* Table: Technician                                            */
/*==============================================================*/
create table Technician (
   tID                  INT4                 not null,
   tFirstName           VARCHAR(254)         null,
   tLastName            VARCHAR(254)         null,
   constraint PK_TECHNICIAN primary key (tID)
);

/*==============================================================*/
/* Index: TECHNICIAN_PK                                         */
/*==============================================================*/
create unique index TECHNICIAN_PK on Technician (
tID
);

alter table Booking
   add constraint FK_BOOKING_DEPARTURE_DEPARTUR foreign key (FlightID, Datum)
      references Departure (FlightID, Datum)
      on delete restrict on update restrict;

alter table Booking
   add constraint FK_BOOKING_PASSENGER_PASSENGE foreign key (CustomerID)
      references Passenger (CustomerID)
      on delete restrict on update restrict;

alter table Departure
   add constraint FK_DEPARTUR_DEPARTURE_FLIGHT foreign key (FlightID)
      references Flight (FlightID)
      on delete restrict on update restrict;

alter table Departure
   add constraint FK_DEPARTUR_DEPARTURE_PLANE foreign key (PlaneID)
      references Plane (PlaneID)
      on delete restrict on update restrict;

alter table Flight
   add constraint FK_FLIGHT_FLIGHTDES_AIRPORT foreign key (Dest_IATA)
      references Airport (IATA)
      on delete restrict on update restrict;

alter table Flight
   add constraint FK_FLIGHT_FLIGHTORI_AIRPORT foreign key (Orig_IATA)
      references Airport (IATA)
      on delete restrict on update restrict;

alter table Maintenance
   add constraint FK_MAINTENA_MAINTENAN_TECHNICI foreign key (tID)
      references Technician (tID)
      on delete restrict on update restrict;

alter table Maintenance
   add constraint FK_MAINTENA_PLANEMAIN_PLANE foreign key (PlaneID)
      references Plane (PlaneID)
      on delete restrict on update restrict;

