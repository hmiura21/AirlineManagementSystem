
# ✈️ Airline Management System

This repository contains an example MySQL-based **Airline Management System** designed for learning and demonstration purposes. It includes:

- A database schema with sample data.
- Example SQL functions, procedures, and views built on top of the sample database.

## 📂 Repository Structure
airline-management-system
- cs4400_phase2_database_team128.sql # Creates tables and inserts sample data with constraints
- cs4400_phase3_stored_procedures_team128-2.sql # Defines views, stored procedures, and functions
- README.md # Project overview and usage instructions



## 🗄️ 1. `cs4400_phase2_database_team128.sql`

This SQL script:

- Creates tables relevant to an airline system (e.g., Flights, Passengers, Bookings, Airports, etc.).
- Applies **primary key** and **foreign key** constraints to enforce relational integrity.
- Populates the tables with example data for testing and exploration.

### Example Tables

- `Route`
- `Airplane`
- `Airports`
- `Leg`
- `Vacation`

## ⚙️ 2. `cs4400_phase3_stored_procedures_team128-2.sql`

This SQL script:

- Defines **views** to simplify queries and present meaningful reports.
- Implements **stored procedures** for tasks like booking a ticket or updating flight status.
- Adds **user-defined functions** for operations like calculating total fare or frequent flyer points.

### Example Features

- `people_in_the_air`: View describing where people who are currently airborne are located
- `route_summary`: view that gives a summary of every route.
- `flights_in_the_air`: View describing where flights that are currently airborne are located.


## 📌 Requirements

- A SQL-compatible RDBMS 
- A SQL client or command-line interface to run `.sql` scripts.
