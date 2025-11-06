
-- Set schema
SET search_path TO schema_lab1, public;

-- Insert departments
INSERT INTO departments (department_name, building_nr) VALUES
('Cardiology', 1),
('Neurology', 2),
('Oncology', 3);

-- Insert employees
INSERT INTO employees (name, phone_nr, start_date, department_name) VALUES
('Alice Smith', '070-1111111', '2025-01-10', 'Cardiology'),
('Bob Johnson', '070-2222222', '2025-02-15', 'Neurology'),
('Charlie Lee', '070-3333333', '2025-03-01', 'Oncology'),
('Dana Kim', '070-4444444', DEFAULT, 'Cardiology');

-- Insert doctors
INSERT INTO doctors (employee_id, specialization, room_nr) VALUES
(1, 'Cardiologist', 101),
(2, 'Neurologist', 202);

-- Insert nurses
INSERT INTO nurses (employee_id, degree) VALUES
(3, 'RN'),
(4, 'BSN');

-- Insert patients
INSERT INTO patients (name, diagnosises, age) VALUES
('Patient A', 'Heart Disease', 60),
('Patient B', 'Stroke', 70),
('Patient C', 'Cancer', 55);

-- Insert treating relationships
INSERT INTO treating (doctor_id, patient_id) VALUES
(1, 1),
(2, 2),
(2, 3);

-- Insert mentorship relationships
INSERT INTO mentorship (mentor_id, mentee_id, start_date) VALUES
(1, 4, '2025-04-01'),
(2, 3, DEFAULT);
