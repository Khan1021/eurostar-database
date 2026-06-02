# Eurostar Relational Database System

A MySQL-based relational database solution for managing a high-speed rail network. This system models core components of the Eurostar operations ecosystem, including rolling stock management, stations, employee roles, scheduling, route-stop sequencing, crew assignments, and multi-modal external passenger metrics.

---

## 📌 Features & Core Architecture

The schema implements a highly organised architecture split into four distinct logic domains:
* **Infrastructure:** Cities, Stations, Routes, and sequence-mapped Route Stops.
* **Asset Management:** Fleet Trains tracking build year and service availability metrics.
* **Workforce & HR:** Polymorphic employee relationships grouping staff into `Crew`, `Admin`, and `Maintenance` roles with corresponding sub-specialties.
* **Operational Analytics:** Multi-tier passenger profiling across specific Trips, Crew mapping workflows, and cross-border `ExternalTravels` trend analysis.

---

## 🗂️ Database Schema Overview

The database utilises a strongly typed relational architecture with cascaded integrity rules:

### Table Relationships at a Glance

| Table Name | Primary Key | Description / Relationships |
| :--- | :--- | :--- |
| **`Trains`** | `train_id` | Tracks rolling stock fleet and service status. |
| **`Cities`** | `city_id` | Core European destinations with localized country tags. |
| **`Stations`** | `station_id` | Train terminals; linked 1:N with `Cities`. |
| **`PassengerTypes`** | `passenger_type_id`| Categories tickets (e.g., Business Premium, Student). |
| **`Employees`** | `employee_id` | Central workforce directory split by operational category. |
| **`CrewMembers`** | `employee_id` | Subset of employees holding valid railway licenses and safety certifications. |
| **`AdminStaff`** | `employee_id` | Back-office employees attached to corporate departments. |
| **`MaintenanceStaff`**| `employee_id` | Service technicians assigned to specific depots and repair fields. |
| **`Routes`** | `route_id` | Network lines connecting origin and terminal stations. |
| **`RouteStops`** | (`route_id`, `stop_seq`) | Composite entity establishing precise intermediate stop sequences. |
| **`Trips`** | `trip_id` | Scheduled occurrences of a Route assigned to a specific Train. |
| **`PassengerStats`** | (`trip_id`, `passenger_type_id`) | Granular seat utilization tracking metrics per trip. |
| **`CrewAssignments`** | (`trip_id`, `employee_id`) | Rostering tracking for train drivers, conductors, and guards. |
| **`ExternalTravels`** | `external_id` | Competitor/market data mapping non-rail passenger movements. |

---

## 🛠️ Getting Started & Installation

### Prerequisites
* MySQL Server (v8.0+ recommended due to modern analytical features)
* A database client interface (e.g., MySQL Workbench, DBeaver, or Command Line Interface)

### Deployment Steps
1. Copy the raw contents of the SQL script.
2. Open your preferred database tool and establish a connection to your target MySQL instance.
3. Paste the code into a fresh query window and execute the entire script.

> ⚠️ **Note:** The script begins with a `DROP DATABASE IF EXISTS eurostar;` clause. Executing this script will completely reset and re-initialize the database environment, erasing existing state variations.

---

## 📊 Analytical Queries Included

The final section of the script includes several pre-written operational optimization scripts divided by complexity metrics:

### 🟩 Basic Reports
* **Modern Fleet Filter:** Identifies all active routes deployed using post-2016 rolling stock structures within target date parameters.
* **Compliance Audit Tracking:** Triggers human resource compliance audits evaluating safety certification lifespans expiring inside calendar windows.

### 🟨 Medium Analytics
* **Route Performance Baseline:** Yields data tracking cumulative historical travelers grouped across all active system lines via dynamic `COALESCE` formatting.
* **Terminal Optimization:** Pairs regional stations located inside identical boundaries to evaluate localized network footprints.
* **Roster Breakdown:** Aggregates and reports specific personnel counts grouped across functional crew fields for active deployments.

### 🟥 Advanced Metrics
* **Volume Outliers:** Dynamically selects active equipment hauling totals exceeding average volume limits utilizing nested independent `HAVING` subqueries.
* **Demographic Volume Sieve:** Highlights runs where standard retail customer bookings exceed 70% of total payload configurations.
* **Regional Market Density:** Selects and calculates specific high-yield ticket classes controlling over 40% of standard route allocations.
