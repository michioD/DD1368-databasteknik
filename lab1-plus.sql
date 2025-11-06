SET search_path TO schema_lab1, public;

CREATE TABLE IF NOT EXISTS departments(
    department_name varchar(100) PRIMARY KEY,
    building_nr integer NOT NULL 
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id serial PRIMARY KEY,
    name varchar(100) NOT NULL,
    phone_nr varchar(25) NOT NULL, 
    start_date date NOT NULL DEFAULT CURRENT_DATE,
    department_name varchar(100) NOT NULL, 
    CONSTRAINT fk_employee_department FOREIGN KEY (department_name) REFERENCES departments(department_name)
);

-- CREATE TABLE works_at(
--     employee_id integer NOT NULL,
--     department_name varchar NOT NULL,
--     CONSTRAINT FK_working_department_name FOREIGN KEY (department_name) REFERENCES departments(department_name) ON DELETE CASCADE,
--     CONSTRAINT FK_working_employee_id FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
--     start_date date NOT NULL
-- );
CREATE TABLE IF NOT EXISTS doctors (
    employee_id integer NOT NULL,
    specialization varchar(100) NOT NULL,
    room_nr integer NOT NULL,
    PRIMARY KEY(employee_id),
    CONSTRAINT fk_doctors_employee_id FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS nurses (
    employee_id integer NOT NULL,
    degree varchar(100) NOT NULL,
    CONSTRAINT fk_nurses_employee_id FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    PRIMARY KEY(employee_id)
);

CREATE TABLE IF NOT EXISTS patients (
    patient_id serial PRIMARY KEY, 
    name varchar(100) NOT NULL,
    diagnosises varchar(255) NOT NULL,
    age integer NOT NULL
);


CREATE TABLE IF NOT EXISTS treating (
    doctor_id integer NOT NULL, 
    patient_id integer NOT NULL,
    CONSTRAINT fk_treating_doctor_id FOREIGN KEY (doctor_id) REFERENCES doctors(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_treating_patient_id FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    PRIMARY KEY(doctor_id, patient_id)
);

CREATE TABLE IF NOT EXISTS mentorship (
    mentor_id integer NOT NULL UNIQUE,
    mentee_id integer NOT NULL UNIQUE,
    start_date date NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_mentor FOREIGN KEY (mentor_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_mentee FOREIGN KEY (mentee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    PRIMARY KEY(mentor_id, mentee_id),
    CONSTRAINT check_no_self_mentorship CHECK (mentor_id <> mentee_id),
    CONSTRAINT check_mentor_mentee_assymetry CHECK (mentor_id > mentee_id)
);

