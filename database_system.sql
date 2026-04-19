CREATE TABLE Customer (
    id INT PRIMARY KEY AUTO_INCREMENT,
    SSN VARCHAR(11) UNIQUE,
    name VARCHAR(255),
    address VARCHAR(255),
    phone_number VARCHAR(15)
);

CREATE TABLE CreditCard (
    number VARCHAR(20) PRIMARY KEY,
    type ENUM('VISA', 'MC', 'AMERICAN_EXPRESS', 'DISCOVER'),
    credit_limit DECIMAL(10, 2),
    current_balance DECIMAL(10, 2),
    active BOOLEAN
);

CREATE TABLE Ownership (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    credit_card_number VARCHAR(20),
    is_current BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES Customer(id) ON DELETE CASCADE,
    FOREIGN KEY (credit_card_number) REFERENCES CreditCard(number)
);


CREATE TABLE Vendor (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    location VARCHAR(255)
);

CREATE TABLE Transaction (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_date DATE,
    customer_id INT,
    credit_card_number VARCHAR(20),
    vendor_id INT,
    amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customer(id),
    FOREIGN KEY (credit_card_number) REFERENCES CreditCard(number),
    FOREIGN KEY (vendor_id) REFERENCES Vendor(id)
);

CREATE TABLE Payment (
    id INT PRIMARY KEY AUTO_INCREMENT,
    payment_date DATE,
    credit_card_number VARCHAR(20),
    amount DECIMAL(10, 2),
    FOREIGN KEY (credit_card_number) REFERENCES CreditCard(number)
);
