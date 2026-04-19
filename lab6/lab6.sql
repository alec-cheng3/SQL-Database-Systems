# Q1. Print the number of credit cards that John Smith owns.
SELECT
    COUNT(*) AS NumberOfCreditCards
FROM
    Customer AS C
JOIN
    Ownership AS O ON C.id = O.customer_id
JOIN
    CreditCard AS CC ON O.credit_card_number = CC.number
WHERE
    name = 'John Smith';
    
    
# Q2. For every customer, print their name and the total (in dollars) of all their purchases.
SELECT
    C.name AS CustomerName,
    C.SSN AS CustomerSSN,
    SUM(T.amount) AS TotalPurchases
FROM
    Customer AS C
JOIN
    Transaction AS T ON C.id = T.customer_id
GROUP BY
    C.name,
    C.SSN;


# Q3. Print the name of the vendor with the highest single transaction.
SELECT
    V.name
FROM
    Vendor AS V
JOIN
    Transaction AS T ON V.id = T.vendor_id
WHERE
    T.amount = (
        SELECT
            MAX(amount)
        FROM
            Transaction
    );

    
# Q4. Print the name of vendor with the highest total proceeds from transactions.
SELECT
    V.id,
    V.name
FROM
    Vendor AS V
JOIN
    (
        SELECT
            vendor_id,
            SUM(amount) AS total_amount
        FROM
            Transaction
        GROUP BY
            vendor_id
        ORDER BY
            total_amount DESC
        LIMIT 1
    ) AS MaxTotal ON V.id = MaxTotal.vendor_id;


# Q5. Write a query that prints the names of all customers that own every single credit card type.
CREATE TABLE CardType (
    id INT PRIMARY KEY AUTO_INCREMENT,
    card_type VARCHAR(50) UNIQUE
);

INSERT INTO CardType (card_type) VALUES ('Visa'), ('MC'), ('Discovery');

SELECT
    C.name,
    COUNT(DISTINCT CT.card_type) AS differentcardtype
FROM
    Customer AS C
JOIN
    Ownership AS O ON C.id = O.customer_id
JOIN
    CreditCard AS CC ON O.credit_card_number = CC.number
JOIN
    CardType AS CT ON CC.type = CT.card_type
GROUP BY
    C.name
HAVING
    differentcardtype = (SELECT COUNT(*) FROM CardType);


# Q6. What is the name of the customers that has the highest credit card balance
SELECT
    C.name
FROM
    Customer AS C
JOIN
    Ownership AS O ON C.id = O.customer_id
JOIN
    CreditCard AS CC ON O.credit_card_number = CC.number
GROUP BY
    C.name
HAVING
    SUM(CC.current_balance) = (
        SELECT
            MAX(total_balance)
        FROM (
            SELECT
                SUM(CC.current_balance) AS total_balance
            FROM
                Customer AS C
            JOIN
                Ownership AS O ON C.id = O.customer_id
            JOIN
                CreditCard AS CC ON O.credit_card_number = CC.number
            GROUP BY
                C.name
        ) AS customer_total_balances
    );


# Q7. Print the transaction with the highest amount.
SELECT
    *
FROM
    Transaction
WHERE
    Transaction.amount = (
        SELECT
            max(Transaction.amount) AS amount
        FROM
			Transaction
    );


# Q8. For every customer, print the amount of their latest payment.
SELECT
    C.name AS CustomerName,
    C.SSN AS CustomerSSN,
    MAX(P.payment_date) AS LatestPaymentDate,
    P.amount AS LatestPaymentAmount
FROM
    Customer AS C
LEFT JOIN
    Ownership AS O ON C.id = O.customer_id
LEFT JOIN
    Payment AS P ON O.credit_card_number = P.credit_card_number
GROUP BY
    C.name,
    C.SSN,
    P.amount;


# Q9. What are the total sales for each card type (i.e., total sales for visa, MC, etc.)
SELECT
    CC.type AS CardType,
    SUM(T.amount) AS TotalSales
FROM
    CreditCard AS CC
LEFT JOIN
    Transaction AS T ON CC.number = T.credit_card_number
GROUP BY
    CC.type;
    
    
# Q10. For 2014, print the total sales for each month.
SELECT
    YEAR(transaction_date) AS Year,
    MONTH(transaction_date) AS Month,
    SUM(amount) AS TotalSales
FROM
    Transaction
WHERE
    YEAR(transaction_date) = 2014
GROUP BY
    Year,
    Month
ORDER BY
    Year,
    Month;
