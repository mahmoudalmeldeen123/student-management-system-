---------------------------------------------------------
-- Student Management System - Database Script 2026
-- Optimized with Exception Handling for Stability
---------------------------------------------------------

-- 1. Create Students Table
CREATE TABLE students (
    student_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50),
    email VARCHAR2(100) UNIQUE,
    major VARCHAR2(50),
    registration_date DATE DEFAULT SYSDATE
);

-- 2. Database Trigger (Requirement #3)
CREATE OR REPLACE TRIGGER trg_before_delete_student
BEFORE DELETE ON students
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('Warning: Student ID ' || :OLD.student_id || ' is being deleted.');
END;
/

-- 3. Stored Procedures with Exception Handling (The "Safety Net")

-- A: Add New Student
CREATE OR REPLACE PROCEDURE add_student (
    p_id IN NUMBER, p_fname IN VARCHAR2, p_lname IN VARCHAR2, p_email IN VARCHAR2, p_major IN VARCHAR2
) AS
BEGIN
    INSERT INTO students (student_id, first_name, last_name, email, major)
    VALUES (p_id, p_fname, p_lname, p_email, p_major);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Student ' || p_id || ' added.');

EXCEPTION 
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR HANDLED: Student ID ' || p_id || ' already exists. Skipping this insert.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR HANDLED: An unexpected error occurred while adding ID ' || p_id);
END;
/

-- B: Update Student Major
CREATE OR REPLACE PROCEDURE update_student (
    p_id IN NUMBER, p_major IN VARCHAR2
) AS
BEGIN
    UPDATE students SET major = p_major WHERE student_id = p_id;
    
    -- Check if any row was actually updated
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('LOG: No student found with ID ' || p_id || '. Nothing updated.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Student ' || p_id || ' major updated.');
    END IF;

EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR HANDLED: Could not update ID ' || p_id);
END;
/

-- C: Delete Student
CREATE OR REPLACE PROCEDURE delete_student (p_id IN NUMBER) AS
BEGIN
    DELETE FROM students WHERE student_id = p_id;
    
    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('LOG: No student found with ID ' || p_id || '. Nothing deleted.');
    ELSE
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('SUCCESS: Student ' || p_id || ' deleted.');
    END IF;

EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR HANDLED: Could not delete ID ' || p_id);
END;
/

---------------------------------------------------------
-- 4. Testing All Operations (With Error Handling Check)
---------------------------------------------------------

BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting Test Scenario ---');

    -- [1] Testing INSERT
   
    add_student(1, 'Fares', 'RAGAB', 'Fares@email.com', 'AI');
    add_student(1, 'Duplicate', 'Test', 'dup@email.com', 'CS'); -- ??? ????? ????? ??? ????? ??????? ?? "?????"
    add_student(2, 'Ahmed', 'Ali', 'Ahmed@email.com', 'Computer Science');
     add_student(3, 'N', 'E', 'NE@email.com', 'WF');
    -- [2] Testing UPDATE
    update_student(1, 'Cyber Security');
    update_student(99, 'Non-Existent'); -- ID ??? ?????? ???? ??????? ?????
    
    -- [3] Testing DELETE
    delete_student(2);
    
    DBMS_OUTPUT.PUT_LINE('--- Test Scenario Finished ---');
END;
/

-- 5. Final Select
SELECT * FROM students ORDER BY student_id;