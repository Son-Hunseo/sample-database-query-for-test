-- ********************************************************************
-- HR (Human Resources) Schema Creation Script for MySQL
-- Converted from Oracle SQL
-- ********************************************************************

-- Create the REGIONS table to hold region information for locations
-- HR.LOCATIONS table has a foreign key to this table.

-- Creating REGIONS table
CREATE TABLE regions (
    region_id INT NOT NULL,
    region_name VARCHAR(25),
    PRIMARY KEY (region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ********************************************************************
-- Create the COUNTRIES table to hold country information for customers
-- and company locations.

-- Creating COUNTRIES table
CREATE TABLE countries (
    country_id CHAR(2) NOT NULL,
    country_name VARCHAR(60),
    region_id INT,
    PRIMARY KEY (country_id),
    CONSTRAINT countr_reg_fk 
        FOREIGN KEY (region_id) 
        REFERENCES regions(region_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ********************************************************************
-- Create the LOCATIONS table to hold address information for company departments.
-- HR.DEPARTMENTS has a foreign key to this table.

-- Creating LOCATIONS table
CREATE TABLE locations (
    location_id INT NOT NULL,
    street_address VARCHAR(40),
    postal_code VARCHAR(12),
    city VARCHAR(30) NOT NULL,
    state_province VARCHAR(25),
    country_id CHAR(2),
    PRIMARY KEY (location_id),
    CONSTRAINT loc_c_id_fk 
        FOREIGN KEY (country_id) 
        REFERENCES countries(country_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX loc_city_ix ON locations (city);
CREATE INDEX loc_state_province_ix ON locations (state_province);
CREATE INDEX loc_country_ix ON locations (country_id);

-- ********************************************************************
-- Create the DEPARTMENTS table to hold company department information.
-- HR.EMPLOYEES and HR.JOB_HISTORY have a foreign key to this table.

-- Creating DEPARTMENTS table
CREATE TABLE departments (
    department_id INT NOT NULL,
    department_name VARCHAR(30) NOT NULL,
    manager_id INT,
    location_id INT,
    PRIMARY KEY (department_id),
    CONSTRAINT dept_loc_fk 
        FOREIGN KEY (location_id) 
        REFERENCES locations(location_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX dept_location_ix ON departments (location_id);

-- ********************************************************************
-- Create the JOBS table to hold the different names of job roles within the company.
-- HR.EMPLOYEES has a foreign key to this table.

-- Creating JOBS table
CREATE TABLE jobs (
    job_id VARCHAR(10) NOT NULL,
    job_title VARCHAR(35) NOT NULL,
    min_salary DECIMAL(8,2),
    max_salary DECIMAL(8,2),
    PRIMARY KEY (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ********************************************************************
-- Create the EMPLOYEES table to hold the employee personnel
-- information for the company.
-- HR.EMPLOYEES has a self referencing foreign key to this table.

-- Creating EMPLOYEES table
CREATE TABLE employees (
    employee_id INT NOT NULL,
    first_name VARCHAR(20),
    last_name VARCHAR(25) NOT NULL,
    email VARCHAR(25) NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL,
    salary DECIMAL(10,2),
    commission_pct DECIMAL(4,2),
    manager_id INT,
    department_id INT,
    PRIMARY KEY (employee_id),
    UNIQUE KEY emp_email_uk (email),
    CONSTRAINT emp_salary_min CHECK (salary > 0),
    CONSTRAINT emp_dept_fk 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id),
    CONSTRAINT emp_job_fk 
        FOREIGN KEY (job_id) 
        REFERENCES jobs(job_id),
    CONSTRAINT emp_manager_fk 
        FOREIGN KEY (manager_id) 
        REFERENCES employees(employee_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX emp_department_ix ON employees (department_id);
CREATE INDEX emp_job_ix ON employees (job_id);
CREATE INDEX emp_manager_ix ON employees (manager_id);
CREATE INDEX emp_name_ix ON employees (last_name, first_name);

-- Add foreign key from departments to employees (circular reference)
ALTER TABLE departments
ADD CONSTRAINT dept_mgr_fk 
    FOREIGN KEY (manager_id) 
    REFERENCES employees(employee_id);

-- ********************************************************************
-- Create the JOB_HISTORY table to hold the history of jobs that 
-- employees have held in the past.

-- Creating JOB_HISTORY table
CREATE TABLE job_history (
    employee_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id VARCHAR(10) NOT NULL,
    department_id INT,
    PRIMARY KEY (employee_id, start_date),
    CONSTRAINT jhist_date_interval CHECK (end_date > start_date),
    CONSTRAINT jhist_emp_fk 
        FOREIGN KEY (employee_id) 
        REFERENCES employees(employee_id),
    CONSTRAINT jhist_job_fk 
        FOREIGN KEY (job_id) 
        REFERENCES jobs(job_id),
    CONSTRAINT jhist_dept_fk 
        FOREIGN KEY (department_id) 
        REFERENCES departments(department_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX jhist_job_ix ON job_history (job_id);
CREATE INDEX jhist_employee_ix ON job_history (employee_id);
CREATE INDEX jhist_department_ix ON job_history (department_id);

-- ********************************************************************
-- Create the EMP_DETAILS_VIEW view to provide a comprehensive view
-- of employee information.

-- Creating EMP_DETAILS_VIEW
CREATE OR REPLACE VIEW emp_details_view AS
SELECT
    e.employee_id,
    e.job_id,
    e.manager_id,
    e.department_id,
    d.location_id,
    l.country_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.commission_pct,
    d.department_name,
    j.job_title,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name
FROM employees e
    INNER JOIN departments d ON e.department_id = d.department_id
    INNER JOIN jobs j ON j.job_id = e.job_id
    INNER JOIN locations l ON d.location_id = l.location_id
    INNER JOIN countries c ON l.country_id = c.country_id
    INNER JOIN regions r ON c.region_id = r.region_id;

-- ********************************************************************
-- Add table and column comments (MySQL uses COMMENT clause)

ALTER TABLE regions 
COMMENT = 'Regions table that contains region numbers and names. References with the Countries table.';

ALTER TABLE regions 
MODIFY region_id INT NOT NULL 
COMMENT 'Primary key of regions table.';

ALTER TABLE regions 
MODIFY region_name VARCHAR(25) 
COMMENT 'Names of regions. Locations are in the countries of these regions.';

ALTER TABLE locations 
COMMENT = 'Locations table that contains specific address of a specific office, warehouse, and/or production site of a company. References with the departments and countries tables.';

ALTER TABLE locations 
MODIFY location_id INT NOT NULL 
COMMENT 'Primary key of locations table';

ALTER TABLE locations 
MODIFY street_address VARCHAR(40) 
COMMENT 'Street address of an office, warehouse, or production site of a company. Contains building number and street name';

ALTER TABLE locations 
MODIFY postal_code VARCHAR(12) 
COMMENT 'Postal code of the location of an office, warehouse, or production site of a company.';

ALTER TABLE locations 
MODIFY city VARCHAR(30) NOT NULL 
COMMENT 'A not null column that shows city where an office, warehouse, or production site of a company is located.';

ALTER TABLE locations 
MODIFY state_province VARCHAR(25) 
COMMENT 'State or Province where an office, warehouse, or production site of a company is located.';

ALTER TABLE locations 
MODIFY country_id CHAR(2) 
COMMENT 'Country where an office, warehouse, or production site of a company is located. Foreign key to country_id column of the countries table.';

ALTER TABLE departments 
COMMENT = 'Departments table that shows details of departments where employees work. References with locations, employees, and job_history tables.';

ALTER TABLE departments 
MODIFY department_id INT NOT NULL 
COMMENT 'Primary key of departments table.';

ALTER TABLE departments 
MODIFY department_name VARCHAR(30) NOT NULL 
COMMENT 'A not null column that shows name of a department. Administration, Marketing, Purchasing, Human Resources, Shipping, IT, Executive, Public Relations, Sales, Finance, and Accounting.';

ALTER TABLE departments 
MODIFY manager_id INT 
COMMENT 'Manager_id of a department. Foreign key to employee_id column of employees table.';

ALTER TABLE departments 
MODIFY location_id INT 
COMMENT 'Location id where a department is located. Foreign key to location_id column of locations table.';

ALTER TABLE job_history 
COMMENT = 'Table that stores job history of the employees. If an employee changes departments within the job or changes jobs within the department, new rows get inserted into this table with old job information of the employee. Contains a complex primary key: employee_id+start_date. References with jobs, employees, and departments tables.';

ALTER TABLE job_history 
MODIFY employee_id INT NOT NULL 
COMMENT 'A not null column in the complex primary key employee_id+start_date. Foreign key to employee_id column of the employee table';

ALTER TABLE job_history 
MODIFY start_date DATE NOT NULL 
COMMENT 'A not null column in the complex primary key employee_id+start_date. Must be less than the end_date of the job_history table.';

ALTER TABLE job_history 
MODIFY end_date DATE NOT NULL 
COMMENT 'Last day of the employee in this job role. A not null column. Must be greater than the start_date of the job_history table.';

ALTER TABLE job_history 
MODIFY job_id VARCHAR(10) NOT NULL 
COMMENT 'Job role in which the employee worked in the past; foreign key to job_id column in the jobs table. A not null column.';

ALTER TABLE job_history 
MODIFY department_id INT 
COMMENT 'Department id in which the employee worked in the past; foreign key to department_id column in the departments table';

ALTER TABLE countries 
COMMENT = 'Country table. References with locations table.';

ALTER TABLE countries 
MODIFY country_id CHAR(2) NOT NULL 
COMMENT 'Primary key of countries table.';

ALTER TABLE countries 
MODIFY country_name VARCHAR(60) 
COMMENT 'Country name';

ALTER TABLE countries 
MODIFY region_id INT 
COMMENT 'Region ID for the country. Foreign key to region_id column in the regions table.';

ALTER TABLE jobs 
COMMENT = 'Jobs table with job titles and salary ranges. References with employees and job_history table.';

ALTER TABLE jobs 
MODIFY job_id VARCHAR(10) NOT NULL 
COMMENT 'Primary key of jobs table.';

ALTER TABLE jobs 
MODIFY job_title VARCHAR(35) NOT NULL 
COMMENT 'A not null column that shows job title, e.g. AD_VP, FI_ACCOUNTANT';

ALTER TABLE jobs 
MODIFY min_salary DECIMAL(8,2) 
COMMENT 'Minimum salary for a job title.';

ALTER TABLE jobs 
MODIFY max_salary DECIMAL(8,2) 
COMMENT 'Maximum salary for a job title';

ALTER TABLE employees 
COMMENT = 'Employees table. References with departments, jobs, job_history tables. Contains a self reference.';

ALTER TABLE employees 
MODIFY employee_id INT NOT NULL 
COMMENT 'Primary key of employees table.';

ALTER TABLE employees 
MODIFY first_name VARCHAR(20) 
COMMENT 'First name of the employee.';

ALTER TABLE employees 
MODIFY last_name VARCHAR(25) NOT NULL 
COMMENT 'Last name of the employee. A not null column.';

ALTER TABLE employees 
MODIFY email VARCHAR(25) NOT NULL 
COMMENT 'Email id of the employee';

ALTER TABLE employees 
MODIFY phone_number VARCHAR(20) 
COMMENT 'Phone number of the employee; includes country code and area code';

ALTER TABLE employees 
MODIFY hire_date DATE NOT NULL 
COMMENT 'Date when the employee started on this job. A not null column.';

ALTER TABLE employees 
MODIFY job_id VARCHAR(10) NOT NULL 
COMMENT 'Current job of the employee; foreign key to job_id column of the jobs table. A not null column.';

ALTER TABLE employees 
MODIFY salary DECIMAL(10,2) 
COMMENT 'Monthly salary of the employee. Must be greater than zero (enforced by constraint emp_salary_min)';

ALTER TABLE employees 
MODIFY commission_pct DECIMAL(4,2) 
COMMENT 'Commission percentage of the employee; Only employees in sales department eligible for commission percentage';

ALTER TABLE employees 
MODIFY manager_id INT 
COMMENT 'Manager id of the employee; has same domain as manager_id in departments table. Foreign key to employee_id column of employees table.';

ALTER TABLE employees 
MODIFY department_id INT 
COMMENT 'Department id where employee works; foreign key to department_id column of the departments table';

-- ********************************************************************
-- Script completed successfully
