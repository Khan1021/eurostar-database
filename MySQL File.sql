-- This script runs on MySQL

-- Drop Eurostar Database (for fresh run)
DROP DATABASE IF EXISTS eurostar;

-- Create Eurostar Database
CREATE DATABASE IF NOT EXISTS eurostar;
USE eurostar;

-- Create Tables 

-- Table Trains
CREATE TABLE IF NOT EXISTS Trains (
     train_id INT AUTO_INCREMENT,
     year_built YEAR NOT NULL,
     status ENUM('operating', 'not_in_service') NOT NULL,
	 PRIMARY KEY (train_id),
     CONSTRAINT check_year_built CHECK (year_built >= 1800)
     );
    
	
-- Table Cities
CREATE TABLE IF NOT EXISTS Cities (
     city_id INT AUTO_INCREMENT,
	 city_name VARCHAR(255) NOT NULL,
	 country VARCHAR(255) NOT NULL,
	 PRIMARY KEY (city_id),
	 CONSTRAINT unique_city_country UNIQUE (city_name, country)
	 );


-- Table Stations 
CREATE TABLE IF NOT EXISTS Stations(
     station_id INT AUTO_INCREMENT,
	 station_name VARCHAR(255) NOT NULL,
	 city_id INT NOT NULL,
	 PRIMARY KEY (station_id),
	 FOREIGN KEY (city_id) REFERENCES Cities(city_id),
	 CONSTRAINT unique_city_station UNIQUE (station_name, city_id)
	 );
	 
     
-- Table PassengerTypes
CREATE TABLE IF NOT EXISTS PassengerTypes (
     passenger_type_id INT AUTO_INCREMENT,
	 description_name VARCHAR(255) NOT NULL UNIQUE,
	 PRIMARY KEY (passenger_type_id)
	 );
	 
     
-- Table Employees
CREATE TABLE IF NOT EXISTS Employees (
     employee_id INT AUTO_INCREMENT,
	 employee_name VARCHAR(255) NOT NULL,
	 job_category ENUM('crew', 'admin', 'maintenance') NOT NULL,
	 PRIMARY KEY (employee_id)
	 );
	 
     
-- Table CrewRoles 
CREATE TABLE IF NOT EXISTS CrewRoles (
     crew_role_id INT AUTO_INCREMENT,
	 crew_role VARCHAR(255) NOT NULL UNIQUE,
	 PRIMARY KEY (crew_role_id)
	 );
	 
     
-- Table CrewMembers (
CREATE TABLE IF NOT EXISTS CrewMembers (
     employee_id INT,
	 crew_role_id INT NOT NULL,
	 license_expiry_date DATE NOT NULL,
	 safety_cert_id INT NOT NULL,
	 PRIMARY KEY (employee_id),
	 FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE,
	 FOREIGN KEY (crew_role_id) REFERENCES CrewRoles(crew_role_id)
	 );
	 
     
-- Table AdminDepartments 
CREATE TABLE IF NOT EXISTS AdminDepartments (
     admin_department_id INT AUTO_INCREMENT,
	 department_name VARCHAR(255) NOT NULL UNIQUE,
	 PRIMARY KEY (admin_department_id)
	 );
	 
     
-- Table AdminStaff
CREATE TABLE IF NOT EXISTS AdminStaff (
     employee_id INT,
	 office_location VARCHAR(255) NOT NULL,
	 admin_department_id INT NOT NULL,
	 PRIMARY KEY (employee_id),
	 FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE,
	 FOREIGN KEY (admin_department_id) REFERENCES AdminDepartments(admin_department_id)
	 );
	 
     
-- Table MaintenanceSpecialty
CREATE TABLE IF NOT EXISTS MaintenanceSpecialty (
     maintenance_specialty_id INT AUTO_INCREMENT,
	 specialty VARCHAR(255) NOT NULL UNIQUE,
	 PRIMARY KEY (maintenance_specialty_id)
	 );


-- Table MaintenanceStaff
CREATE TABLE IF NOT EXISTS MaintenanceStaff (
     employee_id INT,
	 workshop_location VARCHAR(255),
	 maintenance_specialty_id INT NOT NULL,
	 PRIMARY KEY (employee_id),
	 FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON DELETE CASCADE,
	 FOREIGN KEY (maintenance_specialty_id) REFERENCES MaintenanceSpecialty(maintenance_specialty_id)
	 );
	 
     
-- Table Routes
CREATE TABLE IF NOT EXISTS Routes (
     route_id INT AUTO_INCREMENT,
	 route_name VARCHAR(255) NOT NULL UNIQUE,
	 status ENUM('operational', 'planned') NOT NULL,
	 route_type ENUM('direct', 'connecting') NOT NULL, 
	 start_station_id INT NOT NULL,
	 terminal_station_id INT NOT NULL,
	 requires_modern BOOLEAN NOT NULL,
	 estimated_duration INT NOT NULL,
	 total_distance DECIMAL(10, 2) NOT NULL,
	 PRIMARY KEY (route_id),
	 FOREIGN KEY (start_station_id) REFERENCES Stations(station_id),
	 FOREIGN KEY (terminal_station_id) REFERENCES Stations(station_id),
	 CONSTRAINT check_different_stations CHECK (start_station_id != terminal_station_id)
	 );
	 
     
-- Table RouteStops
CREATE TABLE IF NOT EXISTS RouteStops (
     route_id INT NOT NULL,
	 station_id INT NOT NULL, 
	 stop_seq INT NOT NULL,
	 distance_from_start DECIMAL(10, 2) NOT NULL,
	 minutes_from_start INT NOT NULL,
	 PRIMARY KEY (route_id, stop_seq), 
	 FOREIGN KEY (route_id) REFERENCES Routes(route_id) ON UPDATE CASCADE ON DELETE CASCADE,
	 FOREIGN KEY (station_id) REFERENCES Stations(station_id) ON UPDATE CASCADE
	 );
	 
     
-- Table Trips 
CREATE TABLE IF NOT EXISTS Trips (
     trip_id INT AUTO_INCREMENT,
	 route_id INT NOT NULL,
	 train_id INT NOT NULL,
	 departure_datetime DATETIME NOT NULL,
	 PRIMARY KEY (trip_id),
	 FOREIGN KEY (route_id) REFERENCES Routes(route_id) ON UPDATE CASCADE ON DELETE CASCADE,
	 FOREIGN KEY (train_id) REFERENCES Trains(train_id) ON UPDATE CASCADE
	 );
	 
     
-- Table PassengerStats 
CREATE TABLE IF NOT EXISTS PassengerStats (
     trip_id INT NOT NULL,
	 passenger_type_id INT NOT NULL,
	 passenger_count INT NOT NULL,
	 PRIMARY KEY (trip_id, passenger_type_id),
	 FOREIGN KEY (trip_id) REFERENCES Trips(trip_id) ON UPDATE CASCADE ON DELETE CASCADE,
	 FOREIGN KEY (passenger_type_id) REFERENCES PassengerTypes(passenger_type_id) ON UPDATE CASCADE ON DELETE CASCADE
	 );
	 
     
-- Table CrewAssignments 
CREATE TABLE IF NOT EXISTS CrewAssignments (
     trip_id INT NOT NULL, 
	 employee_id INT NOT NULL, 
	 is_head_conductor BOOLEAN NOT NULL,
	 PRIMARY KEY (trip_id, employee_id),
	 FOREIGN KEY (trip_id) REFERENCES Trips(trip_id) ON UPDATE CASCADE ON DELETE CASCADE,
	 FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) ON UPDATE CASCADE ON DELETE CASCADE
	 );
	 
     
-- Table TravelModes 
CREATE TABLE IF NOT EXISTS TravelModes (
     travel_mode_id INT AUTO_INCREMENT,
	 travel_mode VARCHAR(255) NOT NULL UNIQUE,
	 PRIMARY KEY (travel_mode_id)
	 );
	 
     
-- Table ExternalTravels
CREATE TABLE IF NOT EXISTS ExternalTravels(
     external_id INT AUTO_INCREMENT,
	 travel_date DATE NOT NULL,
	 travel_mode_id INT NOT NULL,
	 passenger_count INT NOT NULL,
	 city_start_id INT NOT NULL,
	 city_end_id INT NOT NULL,
	 PRIMARY KEY (external_id),
	 FOREIGN KEY (travel_mode_id) REFERENCES TravelModes(travel_mode_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	 FOREIGN KEY (city_start_id) REFERENCES Cities(city_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	 FOREIGN KEY (city_end_id) REFERENCES Cities(city_id) ON UPDATE CASCADE ON DELETE RESTRICT
	 );


-- Insert Data Into Tables

-- Insert data into Trains Table
INSERT INTO Trains (year_built, status)
VALUES
    (2018, 'operating'),
    (2019, 'operating'),
    (2017, 'operating'),  
    (2016, 'operating'),
    (2015, 'operating'),
    (2014, 'not_in_service'),
    (2013, 'operating'),
    (2012, 'not_in_service'),
    (2011, 'operating'),
    (2010, 'operating'),
    (2009, 'not_in_service'),
    (2008, 'operating'),
    (2007, 'operating'),
    (2005, 'operating'),
    (2003, 'not_in_service'),
    (2001, 'operating'),
    (1999, 'operating'),
    (1998, 'not_in_service'),
    (1995, 'operating'),
    (1990, 'not_in_service');


-- Insert data into Cities Table
INSERT INTO Cities (city_name, country)
VALUES
    ('London', 'United Kingdom'),
    ('Paris', 'France'),
    ('Berlin', 'Germany'),
    ('Frankfurt', 'Germany'),
    ('Madrid', 'Spain'),
    ('Milan', 'Italy'),
    ('Amsterdam', 'Netherlands'),
    ('Brussels', 'Belgium'),
    ('Copenhagen', 'Denmark'),
    ('Vienna', 'Austria'),
    ('Cologne', 'Germany');


 -- Insert data into Stations Table
INSERT INTO Stations (station_name, city_id)
VALUES
    ('London St Pancras', 1),
    ('London Waterloo', 1),
    ('Gare du Nord', 2),
    ('Gare de Lyon', 2),
    ('Berlin Central Station', 3),
    ('Berlin Ostbahnhof', 3),
    ('Frankfurt Hauptbahnhof', 4),
    ('Frankfurt Süd Station', 4),
    ('Madrid Atocha', 5),
    ('Madrid Chamartín', 5),
    ('Milano Centrale', 6),
    ('Milano Porta Garibaldi', 6),
    ('Amsterdam Centraal', 7),
    ('Amsterdam Zuid', 7),
    ('Brussels Midi', 8),
    ('Brussels Central', 8),
    ('Copenhagen Central Station', 9),
    ('Copenhagen Østerport', 9),
    ('Vienna Hauptbahnhof', 10),
    ('Vienna Meidling', 10),
    ('Stratford', 1),
    ('Cologne Central', 11);


-- Insert data into PassengerTypes Table
INSERT INTO PassengerTypes (description_name)
VALUES
    ('Standard Class Adult'),
    ('Standard Class Child'),
    ('Business Premium'),
    ('Flex Ticket Adult'),
    ('Flex Ticket Child'),
    ('Rail Pass Holder'),
    ('Student');


-- Insert data into Employees Table
INSERT INTO Employees (employee_name, job_category)
VALUES
    -- Crew
    ('Lucas Muller', 'crew'),
    ('Emma Dubois', 'crew'),
    ('Sadie Sink', 'crew'),
    ('Joyce Byers', 'crew'),
    ('Sofia Romano', 'crew'),
    ('Nikolai Petrov', 'crew'),
    ('Michael Jackson', 'crew'),
    ('Hanna Johansson', 'crew'),
    ('Jakob Schneider', 'crew'),
    ('Elena Rossi', 'crew'),
    ('Sam Smith', 'crew'),
    ('Oliver Jensen', 'crew'),
    ('Finn Wolfhard', 'crew'),
    ('Marie Lefevre', 'crew'),
    ('David Novak', 'crew'),
    ('Kevin Hart', 'crew'),
    ('Mike Wheeler', 'crew'),
    ('Jane Hopper', 'crew'),
    ('Steve Harrington', 'crew'),
    ('Johnathan Byers', 'crew'),
    ('Dustin Henderson', 'crew'),
    ('Eva Green', 'crew'),

    -- Admin
    ('Anna Keller', 'admin'),
    ('Thomas Bauer', 'admin'),
    ('Clara Schmidt', 'admin'),
    ('Marko Kovač', 'admin'),
    ('Sara Conti', 'admin'),

    -- Maintenance
    ('Lukas Weber', 'maintenance'),
    ('Pavel Horák', 'maintenance'),
    ('Jasmin Berger', 'maintenance'),
    ('Marek Nowak', 'maintenance'),
    ('Felix Brandt', 'maintenance');


-- Insert data into CrewRoles Table
INSERT INTO CrewRoles (crew_role)
VALUES
    ('Driver'), -- 2 Drivers
    ('Conductor'), -- 2 Conductors
    ('Service Staff'), -- 5 Service Staff
    ('Security Guard'); -- 2 Security Guards


-- Insert data into CrewMembers Table
INSERT INTO CrewMembers (employee_id, crew_role_id, license_expiry_date, safety_cert_id)
VALUES
    (1, 1, '2028-06-15', 101),
    (2, 1, '2029-02-10', 102),
    (3, 1, '2027-11-20', 103),
    (4, 1, '2028-08-01', 104),
    (5, 2, '2026-12-30', 105),
    (6, 2, '2027-04-25', 106),
    (7, 2, '2029-01-14', 107),
    (8, 2, '2028-03-09', 108),
    (9, 3, '2027-07-22', 109),
    (10, 3, '2029-11-11', 110),
    (11, 3, '2027-07-22', 111),
    (12, 3, '2027-09-24', 112),
    (13, 3, '2029-07-22', 113),
    (14, 3, '2028-05-25', 114),
    (15, 3, '2026-07-02', 115),
    (16, 3, '2029-11-12', 116),
    (17, 3, '2028-04-23', 117),
    (18, 3, '2027-09-28', 118),
    (19, 4, '2029-03-26', 119),
    (20, 4, '2027-12-06', 120),
    (21, 4, '2027-11-06', 121),
    (22, 4, '2029-11-06', 122);


-- Insert data into AdminDepartments Table
INSERT INTO AdminDepartments (department_name)
VALUES
    ('Human Resources'),
    ('Finance and Accounting'),
    ('Customer Service'),
    ('Sales and Marketing'),
    ('Operations Management'),
    ('IT and Systems'),
    ('Safety and Compliance'),
    ('Logistics and Planning');


-- Insert data into AdminStaff Table
INSERT INTO AdminStaff (employee_id, office_location, admin_department_id)
VALUES
    (11, 'London Headquarters', 1),   
    (12, 'Berlin Office', 2),         
    (13, 'Paris Customer Center', 3), 
    (14, 'Vienna Sales Office', 4),   
    (15, 'Amsterdam Operations Hub', 5); 


-- Insert data into MaintenanceSpecialty Table
INSERT INTO MaintenanceSpecialty(specialty)
VALUES
     ('Electronic controls'),
     ('Wheels and axles'),
     ('Bodywork repair'),
     ('HVAC systems'),
     ('Engine maintenance'),
     ('Brake systems'),
     ('Electrical systems'),
     ('Communication systems'),
     ('Interior maintenance'),
     ('Safety Systems'),
     ('Chassis engineering');


-- Insert data into MaintenanceStaff Table
INSERT INTO MaintenanceStaff(employee_id, workshop_location, maintenance_specialty_id)
VALUES
     (16, 'London Central Depot',1),
     (17, 'Berlin Repair Facility',2),
     (18, 'Paris Maintenance Hub', 3),
     (19, 'Vienna Service Center', 4),
     (20, 'Amsterdam Workshop', 5);
      
      
-- Insert data into Routes Table
INSERT INTO Routes(route_name, status, route_type, start_station_id, terminal_station_id, requires_modern, estimated_duration, total_distance)
VALUES
     ('London-Paris Express','operational','direct', 1, 3, TRUE, 135, 495.0),
     ('London-Brussels Express', 'operational', 'direct', 1, 15, FALSE, 120, 370.00),
     ('London-Amsterdam Express', 'operational', 'direct', 1, 13, FALSE, 180, 550.00),
     ('Paris-Brussels Express', 'operational', 'direct', 3, 15, FALSE, 85, 310.00),
     ('Berlin-Frankfurt Express', 'operational', 'direct', 5, 7, FALSE, 240, 550.00),
     ('Madrid-Barcelona Express', 'planned', 'direct', 9, 11, TRUE, 150, 620.00),
     ('Vienna-Milan Connect', 'operational', 'connecting', 19, 11, FALSE, 480, 800.00),
     ('Copenhagen-Vienna Connect', 'planned', 'connecting', 17, 5, TRUE, 400, 750.00),
     ('Amsterdam-Frankfurt Express', 'operational', 'direct', 13, 7, FALSE, 220, 440.00),
     ('Brussels-Berlin Express', 'operational', 'direct', 15, 7, FALSE, 105, 210.00),
     ('London-Frankfurt Connect', 'operational', 'connecting', 1, 7, TRUE, 600, 1000.0),
     ('Stratford-Cologne Connect', 'planned', 'connecting', 21, 22, TRUE, 800, 1200.0);


-- Insert data into RouteStops Table
INSERT INTO RouteStops(route_id, station_id, stop_seq, distance_from_start, minutes_from_start)
VALUES    
     -- Route 1 : London - Paris (London St Pancras -> Gare du Nord)
    (1, 1, 1, 0.00, 0),   
    (1, 15, 2, 370.00, 120),
    (1, 3, 3, 495.00, 135),

    -- Route 2 : London - Brussels (London St Pancras -> Brussels Midi)
    (2, 1, 1, 0.00, 0),    
    (2, 15, 2, 370.00, 120), 

    -- Route 3 : London - Amsterdam (London St Pancras -> Amsterdam Centraal)
    (3, 1, 1, 0.00, 0),
    (3, 15, 2, 370.00, 120),
    (3, 13, 3, 550.00, 180),
    
	-- Route 4 : Vienna - Milan (Vienna Hauptbahnhof - Milano Centrale)
    (7, 19, 1, 0.00, 0),
    (7, 10, 2, 300.00, 180),
    (7, 4, 3, 550.00, 320),
    (7, 11, 4, 800.00, 480),

    -- Route 5 : Copenhagen-Vienna (Copenhagen Central Station -> Vienna Hauptbahnhof)
    (8, 17, 1, 0.00, 0),
    (8, 5, 2, 400.00, 220),
    (8, 19, 3, 750.00, 180),
    
    -- Route 6: Brussels-Berlin (Brussels Central -> Berlin Central)
    (10, 16, 1, 0, 0),
    (10, 5, 2, 210, 105);


-- Insert data into Trips Table
INSERT INTO Trips(route_id, train_id, departure_datetime)
VALUES
    -- Route 1: London-Paris Express
    (1,  1, '2024-01-05 08:00:00'),
    (1,  2, '2024-01-12 08:00:00'),

    -- Route 2: London-Brussels Express
    (2,  3, '2024-01-06 09:30:00'),
    (2,  4, '2024-01-13 09:30:00'),

    -- Route 3: London-Amsterdam Express
    (3,  5, '2024-01-07 07:45:00'),
    (3,  9, '2024-01-14 07:45:00'),

    -- Route 7: Vienna-Milan Connect
    (7,  7, '2024-02-01 10:15:00'),
    (7,  14, '2024-02-08 10:15:00'),

    -- Route 8: Copenhagen-Vienna Connect
    (8,  1,  '2024-02-03 12:00:00'),
    (8, 2,  '2024-02-10 12:00:00'),

    -- Route 10: Brussels-Berlin Express
    (10, 16, '2024-02-05 15:30:00');


-- Insert data into PassengerStats Table
INSERT INTO PassengerStats(trip_id, passenger_type_id, passenger_count)
VALUES
     -- Trip 1 & 2 : London Paris
     (1, 1, 120), (1, 2, 25), (1, 3, 45), (1, 4, 30), (1, 5, 8), (1, 6, 12), (1, 7, 40),
     (2, 1, 118), (2, 2, 22), (2, 3, 38), (2, 4, 28), (2, 6, 10), (2, 7, 32),

     -- Trip 3 & 4 : London Brussels
     (3, 1, 135), (3, 2, 30), (3, 4, 15), (3, 5, 10), (3, 6, 7), (3, 7, 45),
     (4, 1, 129), (4, 3, 42), (4, 4, 18), (4, 6, 12), (4, 7, 36),

     -- Trip 5 & 6 : London Amsterdam
     (5, 1, 140), (5, 2, 35), (5, 3, 20), (5, 4, 12), (5, 6, 9), (5, 7, 30),
     (6, 1, 150), (6, 2, 28), (6, 3, 18), (6, 4, 16), (6, 5, 6), (6, 6, 10), (6, 7, 34),

     -- Trip 7 & 8 : Vienna Milan
     (7, 1, 90),  (7, 3, 30),  (7, 6, 8),  (7, 7, 22),
     (8, 1, 95),  (8, 3, 27),  (8, 6, 10), (8, 7, 21),

     -- Trip 9 & 10 : Copenhagen Vienna
     (9, 1, 130), (9, 2, 30),  (9, 3, 33),  (9, 4, 18), (9, 6, 12), (9, 7, 40),
     (10, 1, 125), (10, 2, 28), (10, 3, 29), (10, 6, 14), (10, 7, 35),

     -- Trip 11 : Brussels Berlin
     (11, 1, 110), (11, 2, 20), (11, 3, 15), (11, 4, 17), (11, 6, 11), (11, 7, 33);


-- Insert data into CrewAssignments Table
-- Insert Format:
-- 2 Drivers
-- 2 Conductors (only 1 is head)
-- 5 Service Stafg
-- 2 Security 
INSERT INTO CrewAssignments(trip_id, employee_id, is_head_conductor)
VALUES
     -- Trip 1 : London Paris
     (1, 1, FALSE), (1, 2, FALSE),
     (1, 5, TRUE),  (1, 6, FALSE),
     (1, 9, FALSE), (1, 10, FALSE), (1, 11, FALSE), (1, 12, FALSE), (1, 13, FALSE),
     (1, 19, FALSE), (1, 20, FALSE),

     -- Trip 2 : London Paris
     (2, 3, FALSE), (2, 4, FALSE),
     (2, 6, TRUE),  (2, 7, FALSE),
     (2, 14, FALSE), (2, 15, FALSE), (2, 16, FALSE), (2, 17, FALSE), (2, 18, FALSE),
     (2, 21, FALSE), (2, 22, FALSE),

     -- Trip 3 : London Brussels
     (3, 1, FALSE), (3, 3, FALSE),
     (3, 5, TRUE),  (3, 8, FALSE),
     (3, 9, FALSE), (3, 10, FALSE), (3, 14, FALSE), (3, 15, FALSE), (3, 16, FALSE),
     (3, 19, FALSE), (3, 21, FALSE),

     -- Trip 4 : London Brussels
     (4, 2, FALSE), (4, 4, FALSE),
     (4, 6, TRUE),  (4, 7, FALSE),
     (4, 11, FALSE), (4, 12, FALSE), (4, 13, FALSE), (4, 17, FALSE), (4, 18, FALSE),
     (4, 20, FALSE), (4, 22, FALSE),

     -- Trip 5 : London Amsterdam
     (5, 1, FALSE), (5, 4, FALSE),
     (5, 5, TRUE),  (5, 7, FALSE),
     (5, 9, FALSE), (5, 11, FALSE), (5, 14, FALSE), (5, 17, FALSE), (5, 18, FALSE),
     (5, 19, FALSE), (5, 21, FALSE),

     -- Trip 6 : London Amsterdam
     (6, 2, FALSE), (6, 3, FALSE),
     (6, 6, TRUE),  (6, 8, FALSE),
     (6, 10, FALSE), (6, 12, FALSE), (6, 13, FALSE), (6, 15, FALSE), (6, 16, FALSE),
     (6, 20, FALSE), (6, 22, FALSE),

     -- Trip 7 : Vienna Milan
     (7, 1, FALSE), (7, 2, FALSE),
     (7, 5, TRUE),  (7, 8, FALSE),
     (7, 9, FALSE), (7, 10, FALSE), (7, 11, FALSE), (7, 14, FALSE), (7, 15, FALSE),
     (7, 19, FALSE), (7, 21, FALSE),

     -- Trip 8 : Vienna Milan
     (8, 3, FALSE), (8, 4, FALSE),
     (8, 6, TRUE),  (8, 7, FALSE),
     (8, 12, FALSE), (8, 13, FALSE), (8, 16, FALSE), (8, 17, FALSE), (8, 18, FALSE),
     (8, 20, FALSE), (8, 22, FALSE),

     -- Trip 9 : Copenhagen Vienna
     (9, 1, FALSE), (9, 3, FALSE),
     (9, 5, TRUE),  (9, 7, FALSE),
     (9, 9, FALSE), (9, 10, FALSE), (9, 14, FALSE), (9, 15, FALSE), (9, 16, FALSE),
     (9, 19, FALSE), (9, 21, FALSE),

     -- Trip 10 : Copenhagen Vienna
     (10, 2, FALSE), (10, 4, FALSE),
     (10, 6, TRUE),  (10, 8, FALSE),
     (10, 11, FALSE), (10, 12, FALSE), (10, 13, FALSE), (10, 17, FALSE), (10, 18, FALSE),
     (10, 20, FALSE), (10, 22, FALSE),

     -- Trip 11 : Brussels Berlin
     (11, 1, FALSE), (11, 4, FALSE),
     (11, 7, TRUE),  (11, 8, FALSE),
     (11, 9, FALSE), (11, 10, FALSE), (11, 11, FALSE), (11, 12, FALSE), (11, 13, FALSE),
     (11, 19, FALSE), (11, 22, FALSE);


-- Insert data into TravelModes Table
INSERT INTO TravelModes(travel_mode)
VALUES
     ('Airplane'),
     ('Bus'),
     ('Car'),
     ('Ferry'),
     ('Train'),
     ('Tram'),
     ('Subway'),
     ('Taxi'),
     ('Other rail');


-- Insert data into ExternalTravels Table
INSERT INTO ExternalTravels(travel_date,travel_mode_id,passenger_count,city_start_id,city_end_id)
VALUES
     -- Trip 1 : 2024-01-05 (London–Paris train)
     ('2024-01-05', 1, 220, 1, 2),  
     ('2024-01-05', 2, 150, 1, 2), 
     ('2024-01-05', 3, 80,  2, 1),
     
     -- Trip 2 : 2024-01-12 (London–Paris train)
     ('2024-01-12', 1, 210, 1, 2), 
     ('2024-01-12', 5, 160, 2, 1), 
     ('2024-01-12', 8, 70,  1, 2), 

     -- Trip 3 : 2024-01-06 (London–Brussels train)
     ('2024-01-06', 1, 190, 1, 8),  
     ('2024-01-06', 2, 120, 1, 8), 
     ('2024-01-06', 3, 60,  8, 1),

     -- Trip 4 : 2024-01-13 (London–Brussels train)
     ('2024-01-13', 1, 185, 1, 8),
     ('2024-01-13', 5, 140, 8, 1),
     ('2024-01-13', 9, 50,  1, 3),  

     -- Trip 5 : 2024-01-07 (London–Amsterdam train)
     ('2024-01-07', 1, 210, 1, 7), 
     ('2024-01-07', 2, 130, 1, 7), 
     ('2024-01-07', 3, 75,  7, 1), 

     -- Trip 6 : 2024-01-14 (London–Amsterdam train)
     ('2024-01-14', 1, 205, 1, 7),
     ('2024-01-14', 5, 150, 7, 1),
     ('2024-01-14', 8, 65,  1, 7),

     -- Trip 7 : 2024-02-01 (Vienna–Milan train)
     ('2024-02-01', 1, 185, 10, 6), 
     ('2024-02-01', 3, 90,  6, 10), 
     ('2024-02-01', 5, 140, 10, 6),

     -- Trip 8 : 2024-02-08 (Vienna–Milan train)
     ('2024-02-08', 1, 178, 10, 6),
     ('2024-02-08', 2, 110, 10, 6),
     ('2024-02-08', 9, 55,  6, 3),

     -- Trip 9 : 2024-02-03 (Copenhagen–Vienna train)
     ('2024-02-03', 1, 200, 9, 10),
     ('2024-02-03', 2, 125, 9, 10),
     ('2024-02-03', 3, 70,  10, 9),

     -- Trip 10 : 2024-02-10 (Copenhagen–Vienna train)
     ('2024-02-10', 1, 195, 9, 10),
     ('2024-02-10', 5, 145, 10, 9),
     ('2024-02-10', 8, 60,  9, 10),

     -- Trip 11 : 2024-02-05 (Brussels–Berlin train)
     ('2024-02-05', 1, 175, 8, 3),
     ('2024-02-05', 2, 115, 8, 3), 
     ('2024-02-05', 3, 65,  3, 8); 
     
-- Basic Queries

-- 1. Fetch all eurostar trains in Jan 2024 where the trains are modern
SELECT t.train_id, r.route_name, tr.departure_datetime, r.estimated_duration
FROM Trains t
INNER JOIN Trips tr
  ON t.train_id = tr.train_id
INNER JOIN Routes r 
  ON tr.route_id =  r.route_id
WHERE t.year_built >=2016
AND tr.departure_datetime BETWEEN '2024-01-01' AND '2024-01-31'
ORDER BY departure_datetime ASC;


-- 2. Employees with Safety Certifications expiring in 2029
SELECT e.employee_name, c.crew_role, cr.license_expiry_date
FROM Employees e
INNER JOIN CrewMembers cr 
  ON e.employee_id = cr.employee_id
INNER JOIN CrewRoles c
  ON cr.crew_role_id = c.crew_role_id
WHERE cr.license_expiry_date BETWEEN '2029-01-01' AND '2029-12-31'
ORDER BY license_expiry_date ASC; 

-- Medium Queries

-- 1. List all routes together with the total number of passengers for each route, 
-- including routes that have no trips and therefore no passengers.

SELECT r.route_name, COALESCE(SUM(p.passenger_count),0) AS passenger_count
FROM Routes r 
LEFT JOIN Trips t
  ON r.route_id = t.route_id
LEFT JOIN PassengerStats p
  ON p.trip_id = t.trip_id
GROUP BY r.route_name;

-- 2. List all pairs of stations that belong to the same city.
SELECT s1.station_name AS station1, s2.station_name AS station2 
FROM Stations s1
INNER JOIN Stations s2
  ON s1.city_id = s2.city_id
AND s1.station_id < s2.station_id;

-- 3. For each trip, show how many crew members participated in that trip, 
-- grouped by each crew role (driver, conductor, service staff, security, etc.)
SELECT t.trip_id, cr.crew_role, COUNT(*) AS crew_count
FROM CrewAssignments ca
JOIN CrewMembers cm
  ON ca.employee_id = cm.employee_id
JOIN CrewRoles cr
  ON cm.crew_role_id = cr.crew_role_id
JOIN Trips t 
  ON ca.trip_id = t.trip_id
GROUP BY t.trip_id, cr.crew_role
ORDER BY t.trip_id, cr.crew_role;

-- Advanced Queries 

-- 1. Find all trains that transported more passengers than the average total passengers transported per train in January 2024.
SELECT t.train_id, SUM(ps.passenger_count) AS total_passengers
FROM Trains t
JOIN Trips tr
  ON t.train_id = tr.train_id
JOIN PassengerStats ps
  ON tr.trip_id = ps.trip_id
WHERE tr.departure_datetime BETWEEN '2024-01-01' AND '2024-02-01' 
GROUP BY t.train_id
HAVING SUM(ps.passenger_count) > 
   (
	  SELECT AVG(train_totals.total_passengers)
      FROM (
          SELECT SUM(ps2.passenger_count) AS total_passengers
          FROM Trips tr2
          JOIN PassengerStats ps2 ON tr2.trip_id = ps2.trip_id
          GROUP BY tr2.train_id
          ) AS train_totals
	);
    
-- 2. Show trips where more than 70% of all passengers were Standard Class (PassengerTypes 1 and 2)
SELECT tr.trip_id, tr.departure_datetime
FROM Trips tr
JOIN PassengerStats ps 
ON tr.trip_id = ps.trip_id
GROUP BY tr.trip_id, tr.departure_datetime
HAVING
    (
      SELECT SUM(ps2.passenger_count)
      FROM PassengerStats ps2
      JOIN PassengerTypes pt2
      ON ps2.passenger_type_id = pt2.passenger_type_id
      WHERE ps2.trip_id = tr.trip_id
      AND ps2.passenger_type_id IN (1,2)
      ) > 0.7 * 
      (
        SELECT SUM(ps3.passenger_count)
        FROM PassengerStats ps3
        WHERE ps3.trip_id = tr.trip_id
        );
      


-- 3. On each route, which passenger types make up more than 40% of all passengers on that route?

SELECT r.route_id, r.route_name, pt.passenger_type_id, pt.description_name,SUM(ps.passenger_count) AS passenger_type_total, rt.route_total_passengers, ROUND(100* SUM(ps.passenger_count)/ rt.route_total_passengers,2) AS pct_of_route
FROM Routes r
INNER JOIN Trips tr 
    ON tr.route_id = r.route_id
INNER JOIN PassengerStats ps
    ON ps.trip_id = tr.trip_id
INNER JOIN PassengerTypes pt
    ON pt.passenger_type_id = ps.passenger_type_id
INNER JOIN (
        -- total passengers per route (all trips, all passenger types)
        SELECT t2.route_id, SUM(ps2.passenger_count) AS route_total_passengers
        FROM Trips t2
        JOIN PassengerStats ps2
            ON ps2.trip_id = t2. trip_id
        GROUP BY t2.route_id
)   AS rt
        ON rt.route_id = r.route_id
    GROUP BY 
        r.route_id,
        r.route_name,
        pt.passenger_type_id,
        rt.route_total_passengers
    HAVING 
        SUM(ps.passenger_count) > 0.4 * rt.route_total_passengers;
