INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', GETDATE() - 24,  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', GETDATE() - 13,  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', GETDATE() - 7,  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', GETDATE() - 32,  '978-0-375-50167-0', 'E101');

ALTER TABLE return_status
ADD book_quality VARCHAR(20) DEFAULT 'Good';

UPDATE Return_Status
SET book_quality = 'Good'
WHERE book_quality IS NULL;

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;


