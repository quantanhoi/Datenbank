/*==============================================================*/
/* DBMS name:      PostgreSQL 9.x                               */
/* Created on:     18/11/2022 15:00:27                          */
/*==============================================================*/


drop index if exists AIRPORT_PK cascade;

drop table if exists Airport cascade;

drop index if exists DEPARTURE_PLANE_FK cascade;

drop index if exists DEPARTURE_FLIGHT_FK cascade;

drop index if exists DEPARTURE_PK cascade;

drop table if exists Departure cascade;

drop index if exists FLIGHTDEST_AIRPORT_FK cascade;

drop index if exists FLIGHTORIG_AIRPORT_FK cascade;

drop index if exists FLIGHT_PK cascade;

drop table if exists Flight cascade;

drop index if exists PLANE_PK cascade;

drop table if exists Plane cascade;

/*==============================================================*/
/* Table: Airport                                               */
/*==============================================================*/
create table Airport (
   IATA                 VARCHAR(254)         not null,
   Name                 VARCHAR(254)         not null,
   Longitude            NUMERIC              not null,
   Latitude             NUMERIC              not null,
   constraint PK_AIRPORT primary key (IATA)
);

/*==============================================================*/
/* Index: AIRPORT_PK                                            */
/*==============================================================*/
create unique index AIRPORT_PK on Airport (
IATA
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
   Orig_IATA            VARCHAR(254)         not null,
   Dest_IATA            VARCHAR(254)         not null,
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
Dest_IATA
);

/*==============================================================*/
/* Index: FLIGHTDEST_AIRPORT_FK                                 */
/*==============================================================*/
create  index FLIGHTDEST_AIRPORT_FK on Flight (
Orig_IATA
);

/*==============================================================*/
/* Table: Plane                                                 */
/*==============================================================*/
create table Plane (
   PlaneID              VARCHAR(254)         not null,
   Type                 VARCHAR(254)         not null,
   Seats                INT4                 not null,
   constraint PK_PLANE primary key (PlaneID)
);

/*==============================================================*/
/* Index: PLANE_PK                                              */
/*==============================================================*/
create unique index PLANE_PK on Plane (
PlaneID
);

alter table Departure
   add constraint FK_DEPARTUR_DEPARTURE_FLIGHT foreign key (FlightID)
      references Flight (FlightID)
      on delete restrict on update restrict;

alter table Departure
   add constraint FK_DEPARTUR_DEPARTURE_PLANE foreign key (PlaneID)
      references Plane (PlaneID)
      on delete restrict on update restrict;

alter table Flight
   add constraint FK_FLIGHT_FLIGHTDES_AIRPORT foreign key (Orig_IATA)
      references Airport (IATA)
      on delete restrict on update restrict;

alter table Flight
   add constraint FK_FLIGHT_FLIGHTORI_AIRPORT foreign key (Dest_IATA)
      references Airport (IATA)
      on delete restrict on update restrict;

