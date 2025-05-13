
--Creating Tables
DROP TABLE IF EXISTS Branch;
CREATE TABLE Branch(
branch_id VARCHAR(10) PRIMARY KEY,
manager_id VARCHAR(25),
branch_address VARCHAR(55),
contact_no VARCHAR(15),
);

DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees(
Emp_id VARCHAR(20) PRIMARY KEY,
Emp_name VARCHAR(25),
Position VARCHAR(25),
Salary INT,
Branch_id VARCHAR(10),
);

DROP TABLE IF EXISTS Books;
CREATE TABLE Books(
isbn VARCHAR(20) PRIMARY KEY,
book_title VARCHAR(75),
category VARCHAR(15),
rental_price FLOAT,
status VARCHAR(10),
author VARCHAR(25),
publisher VARCHAR(50),
);


DROP TABLE IF EXISTS Members;
CREATE TABLE Members(
member_id VARCHAR(20) PRIMARY KEY,
member_name VARCHAR(25),
member_address VARCHAR(60),
reg_date DATE
);

DROP TABLE IF EXISTS Issued_Status;
CREATE TABLE Issued_Status(
issued_id VARCHAR(20) PRIMARY KEY,
issued_member_id VARCHAR(20),
issued_book_name VARCHAR(75),
issued_date DATE,
issued_book_isbn VARCHAR(20),
issued_emp_id VARCHAR(20),
);

DROP TABLE IF EXISTS Return_Status;
CREATE TABLE Return_Status(
return_id VARCHAR(20) PRIMARY KEY,
issued_id VARCHAR(20),
return_book_name VARCHAR(75),
return_date DATE,
return_book_isbn VARCHAR(20),
);


ALTER TABLE Issued_Status
ADD CONSTRAINT Fk_MemberID
FOREIGN KEY (issued_member_id)
REFERENCES Members(member_id);

ALTER TABLE Books
ALTER COLUMN Category VARCHAR(25);

SELECT * FROM members;

/*PROBLEM STATEMENTS*/

--Task 1. Create a New Book Record:
INSERT INTO Books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

--Task 2: Update an Existing Member's Address:
UPDATE Members
SET member_address = '333 Mall Road'
WHERE member_id = 'C119';

--Task 3: Delete a Record from the Issued Status Table:
DELETE FROM Issued_Status
WHERE issued_id  = 'IS121';

--Task 4: Retrieve All Books Issued by a Specific Employee:
SELECT * 
FROM Issued_Status
WHERE issued_emp_id = 'E102';

--Task 5: List Members Who Have Issued More Than One Book:
SELECT issued_member_id, COUNT(issued_member_id) as 'Books Issued'
FROM Issued_Status
GROUP BY issued_member_id
HAVING COUNT(issued_member_id) > 1;

--Task 6:Create a new table based on query results - name of the book issued and the total number of times each book is issued:
CREATE TABLE BookIssue_Count(
Issued_book_name VARCHAR(75),
IssueCount INT
);

SELECT issued_book_name, COUNT(Issued_book_name) as 'Issued.Count' 
INTO BookIssue_Count
FROM Issued_Status
GROUP BY issued_book_name;

SELECT * FROM BookIssue_Count;


--Task 7.Retrieve All Books in a Specific Category:
SELECT * 
FROM Books
WHERE category = 'CHILDREN';


--Task 8: Find Total Rental Income by Category:
SELECT B.category, SUM(B.RENTAL_PRICE),COUNT(B.BOOK_TITLE)
FROM Books as b
JOIN Issued_Status as I
ON  b.isbn = I.issued_book_isbn
GROUP BY B.category;

--Task 9: List the members who have newly registered:
SELECT *
FROM Members
WHERE reg_date > (GETDATE() - 400);

--Task 10:List Employees with their Branch Manager's Name and their branch details:
SELECT E.Emp_name,e.Emp_id,e.Position,b.branch_id,b.manager_id,E2.Emp_name AS MANAGERNAME
FROM Employees E
JOIN Branch B
ON B.branch_id = E.Branch_id
JOIN Employees E2
ON E2.Emp_id = B.manager_id;

--Task 11.Create a Table of Books with Rental Price Above a Certain Threshold:
SELECT book_title,rental_price
INTO HIGH_RENTAL_BOOKS
FROM Books
WHERE rental_price > 7;

SELECT * FROM HIGH_RENTAL_BOOKS

--Task 12:Retrieve the List of Books Not Yet Returned:
SELECT I.issued_id, R.RETURN_ID,I.issued_member_id,i.issued_book_name
FROM Issued_Status I
LEFT JOIN Return_Status R 
ON I.issued_id = R.issued_id
WHERE R.return_id IS NULL;


--Task 13: Identify Members with Overdue Books:
SELECT I.issued_id,I.issued_book_name,I.issued_date,R.return_id,R.return_date,M.member_name, DATEDIFF(DAY, I.ISSUED_DATE, CAST(GETDATE() AS DATE)) AS Overdue_Days
FROM Issued_Status I
LEFT JOIN Return_Status R
ON I.issued_id = R.issued_id
LEFT JOIN Members M
ON I.issued_member_id = M.member_id
WHERE R.return_id IS NULL AND DATEDIFF(DAY, I.ISSUED_DATE, CAST(GETDATE() AS DATE)) >= 60

--Task 14: Branch Performance Report.Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals:

WITH Branch_Report AS
(SELECT ist.issued_id,ist.issued_date,ist.issued_book_name,R.return_id,R.return_date,B.rental_price,Br.branch_id
FROM Issued_Status Ist
LEFT JOIN Return_Status R
ON Ist.issued_id = R.issued_id
LEFT JOIN Books B
ON Ist.issued_book_isbn = B.isbn
LEFT JOIN Employees E
ON Ist.issued_emp_id = E.Emp_id
LEFT JOIN Branch Br
ON E.Branch_id = Br.branch_id)
SELECT Branch_id, COUNT(issued_id) AS No_of_Books_Issued, COUNT(return_id) AS No_of_Books_Returned, Sum(rental_price) AS Total_Revenue
FROM Branch_Report
GROUP BY branch_id

--Task 15:Create a new table 'Active_members' containing members who have borrowed at least one book in the last 2 months:

DROP TABLE IF EXISTS Active_Members;
SELECT M.member_id,M.member_name,ist.issued_id,ist.issued_date,ist.issued_book_name,DATEDIFF(day,Ist.issued_date,GETDATE()) AS LatestActivityDays INTO Active_Members
FROM Issued_Status Ist
LEFT JOIN Books B
ON Ist.issued_book_isbn = B.isbn
LEFT JOIN Members M
ON Ist.issued_member_id = M.member_id
WHERE DATEDIFF(day,Ist.issued_date,GETDATE()) <= 60

--Task 16: Find the top 3 Employees who have issued the highest number of books. Display the employee name, number of books processed, and their branch:

SELECT TOP 3 E.Emp_name, E.Emp_id,  COUNT(Ist.issued_id) Books_Processed, E.Branch_id
FROM Issued_Status Ist
LEFT JOIN Employees E
ON Ist.issued_emp_id = E.Emp_id
LEFT JOIN Branch Br
ON E.Branch_id = Br.branch_id
GROUP BY E.Emp_name,E.Emp_id,E.Branch_id
ORDER BY COUNT(Ist.issued_id) DESC






