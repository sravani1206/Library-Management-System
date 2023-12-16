create database library_SP;

use library_SP;


CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name VARCHAR(255) NOT NULL
);

CREATE TABLE genres (
    genre_id INT PRIMARY KEY,
    genre_name VARCHAR(255) NOT NULL
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    genre_id INT,
    ISBN VARCHAR(13) UNIQUE,
    publication_year INT,
    available_copies INT,
    FOREIGN KEY (author_id) REFERENCES authors(author_id),
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20) UNIQUE
);


CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    user_id INT,
    book_id INT,
    checkout_date DATE,
    return_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
);

-- Inserting authors

INSERT INTO authors (author_id, author_name) VALUES
(1, 'Jane Doe'),
(2, 'John Smith'),
(3, 'Alice Johnson'),
(4, 'Bob Anderson'),
(5, 'Eva Williams'),
(6, 'Michael Brown');

Select * from authors;

-- Inserting genres

INSERT INTO genres (genre_id, genre_name) VALUES
(1, 'Fiction'),
(2, 'Non-fiction'),
(3, 'Mystery'),
(4, 'Science Fiction'),
(5, 'History'),
(6, 'Biography');

Select * from genres;
-- Inserting books

INSERT INTO books (book_id, title, author_id, genre_id, ISBN, publication_year, available_copies) VALUES
(1, 'The Great Novel', 1, 1, '1234567890123', 2020, 5),
(2, 'Programming 101', 2, 2, '9876543210123', 2018, 8),
(3, 'Mystery at Midnight', 3, 3, '1112233445566', 2019, 10),
(4, 'Space Odyssey', 4, 4, '5556667778889', 2022, 3),
(5, 'Ancient History', 5, 5, '4443332221110', 2017, 12),
(6, 'Einstein: A Life', 6, 6, '9990001112223', 2021, 6);

Select * from books;

-- Inserting users

INSERT INTO users (user_id, user_name, email, phone_number) VALUES
(1, 'Alice Johnson', 'alice@example.com', '123-456-7890'),
(2, 'Bob Anderson', 'bob@example.com', '987-654-3210'),
(3, 'Eva Williams', 'eva@example.com', '555-555-5555'),
(4, 'Michael Brown', 'michael@example.com', '111-222-3333'),
(5, 'Jane Doe', 'jane@example.com', '999-888-7777'),
(6, 'John Smith', 'john@example.com', '444-333-2222');

Select * from users;

-- Inserting transactions
INSERT INTO transactions (transaction_id, user_id, book_id, checkout_date, return_date) VALUES
(1, 1, 1, '2023-01-01', '2023-01-15'),
(2, 2, 3, '2023-02-05', '2023-02-20'),
(3, 3, 5, '2023-03-10', NULL),
(4, 4, 2, '2023-04-15', '2023-05-01'),
(5, 5, 4, '2023-06-20', NULL),
(6, 6, 6, '2023-07-25', '2023-08-10');

Select * from transactions;

-- Retrieve all books with their titles, authors, and genres

SELECT books.title, authors.author_name, genres.genre_name
FROM books
JOIN authors ON books.author_id = authors.author_id
JOIN genres ON books.genre_id = genres.genre_id;


-- Find books published in a specific year:                                                     
SELECT title, publication_year
FROM books
WHERE publication_year = 2022; 

-- Retrieve user transactions, including book details:

SELECT users.user_name, books.title, transactions.checkout_date, transactions.return_date
FROM transactions
JOIN users ON transactions.user_id = users.user_id
JOIN books ON transactions.book_id = books.book_id;

-- Count the number of books in each genre:     
SELECT genres.genre_name, COUNT(*) as book_count
FROM books
JOIN genres ON books.genre_id = genres.genre_id
GROUP BY genres.genre_name;

-- Find users who have overdue books:

SELECT users.user_name, books.title, transactions.checkout_date, transactions.return_date
FROM transactions
JOIN users ON transactions.user_id = users.user_id
JOIN books ON transactions.book_id = books.book_id
WHERE transactions.return_date IS NULL AND CURRENT_DATE > transactions.checkout_date;

-- Update the available copies of a book after a checkout:     
UPDATE books
SET available_copies = available_copies - 1
WHERE book_id = 1;


-- Retrieve the most borrowed book:  
SELECT books.title, COUNT(*) as borrow_count
FROM transactions
JOIN books ON transactions.book_id = books.book_id
GROUP BY books.title
ORDER BY borrow_count DESC
LIMIT 1;

-- Question1: What are the top three most borrowed books?             
SELECT books.title, COUNT(*) as borrow_count
FROM transactions
JOIN books ON transactions.book_id = books.book_id
GROUP BY books.title
ORDER BY borrow_count DESC
LIMIT 3;
-- Question2: How many books are available in each genre?           
SELECT genres.genre_name, COUNT(*) as book_count
FROM books
JOIN genres ON books.genre_id = genres.genre_id
GROUP BY genres.genre_name;

-- Question3: Which users have overdue books, and what are the details of those books?   
SELECT users.user_name, books.title, transactions.checkout_date, transactions.return_date
FROM transactions
JOIN users ON transactions.user_id = users.user_id
JOIN books ON transactions.book_id = books.book_id
WHERE transactions.return_date IS NULL AND CURRENT_DATE > transactions.checkout_date;

-- Trigger to Update Available Copies After Checkout:
DELIMITER 
//
CREATE TRIGGER after_checkout
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    UPDATE books
    SET available_copies = available_copies - 1
    WHERE book_id = NEW.book_id;
END;
//
DELIMITER ;


-- Trigger to Update Available Copies After Return:                                       
DELIMITER //

CREATE TRIGGER after_return
AFTER UPDATE ON transactions
FOR EACH ROW
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE books
        SET available_copies = available_copies + 1
        WHERE book_id = NEW.book_id;
    END IF;
END;
//
DELIMITER ;

-- Performance tuning
-- Indexing:                        
CREATE INDEX idx_author_id ON books (author_id);
CREATE INDEX idx_genre_id ON books (genre_id);
CREATE INDEX idx_ISBN ON books (ISBN);
CREATE INDEX idx_user_id ON transactions (user_id);
CREATE INDEX idx_book_id ON transactions (book_id);

 -- Optimizing Queries:                                             
 EXPLAIN SELECT books.title, authors.author_name, genres.genre_name
FROM books
JOIN authors ON books.author_id = authors.author_id
JOIN genres ON books.genre_id = genres.genre_id;

-- Limitations
-- Limited Support for Different Types of Transactions:     
-- Query to handle reservations
SELECT *
FROM transactions
WHERE return_date IS NULL AND checkout_date IS NULL;
-- Handling of Book Copies:      
-- Query to get information about a specific copy of a book
SELECT *
FROM books
WHERE book_id = 1;

-- Lack of Constraints for Transaction Dates:                                
-- Query to identify transactions with invalid dates
SELECT *
FROM transactions
WHERE return_date < checkout_date OR checkout_date > CURRENT_DATE;
 
 -- Categorization
 -- Book Information:       
 -- Query to retrieve book information
SELECT title, author_name, genre_name
FROM books
JOIN authors ON books.author_id = authors.author_id
JOIN genres ON books.genre_id = genres.genre_id;
 -- User Information:
 -- Query to retrieve user information
SELECT user_name, email, phone_number
FROM users;




-- Transactions:
-- Query to retrieve transaction details
SELECT user_name, title, checkout_date, return_date
FROM transactions
JOIN users ON transactions.user_id = users.user_id
JOIN books ON transactions.book_id = books.book_id;


-- Authors and Genres:    
-- Query to retrieve authors and their genres
SELECT author_name, genre_name
FROM authors
JOIN books ON authors.author_id = books.author_id
JOIN genres ON books.genre_id = genres.genre_id;
