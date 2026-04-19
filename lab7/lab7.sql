# Q1. Show the 10 customers with the highest single transaction amount.
SELECT
    C.name AS CustomerName,
    MAX(T.amount) AS HighestTransactionAmount
FROM
    Customer AS C
JOIN
    Transaction AS T ON C.id = T.customer_id
GROUP BY
    CustomerName
ORDER BY
    HighestTransactionAmount DESC
LIMIT 10;


# Q2. Show all customers ordered by the total amount of all their transactions.
#     Show the name of the customer and the total. Start with the customer with the highest total.
SELECT
    C.name AS CustomerName,
    SUM(T.amount) AS TotalTransactionAmount
FROM
    Customer AS C
LEFT JOIN
    Transaction AS T ON C.id = T.customer_id
GROUP BY
    CustomerName
ORDER BY
    TotalTransactionAmount DESC;


# Q3. Show vendors that have transactions with every single credit card.
SELECT
    V.name AS VendorName
FROM
    Vendor AS V
WHERE NOT EXISTS (
    SELECT DISTINCT
        C.number
    FROM
        CreditCard AS C
    WHERE NOT EXISTS (
        SELECT
            O.credit_card_number
        FROM
            Ownership AS O
        WHERE
            O.credit_card_number = C.number
            AND O.customer_id IN (
                SELECT DISTINCT
                    T.customer_id
                FROM
                    Transaction AS T
                WHERE
                    T.vendor_id = V.id
            )
    )
);


# Q4. Show vendors that have transactions with every single credit card type.
SELECT
    V.name AS VendorName
FROM
    Vendor AS V
WHERE NOT EXISTS (
    SELECT DISTINCT
        C.type
    FROM
        CreditCard AS C
    WHERE NOT EXISTS (
        SELECT
            O.credit_card_number
        FROM
            Ownership AS O
        WHERE
            O.credit_card_number IN (
                SELECT DISTINCT
                    T.credit_card_number
                FROM
                    Transaction AS T
                WHERE
                    T.vendor_id = V.id
            )
            AND O.customer_id IN (
                SELECT DISTINCT
                    T.customer_id
                FROM
                    Transaction AS T
                WHERE
                    T.vendor_id = V.id
            )
    )
);


# Q5. Print the 5 richest vendors. These are the vendors that have made the most money from transactions. Start with the richest vendor.
SELECT
    V.name AS VendorName,
    SUM(T.amount) AS TotalSales
FROM
    Vendor AS V
JOIN
    Transaction AS T ON V.id = T.vendor_id
GROUP BY
    VendorName
ORDER BY
    TotalSales DESC
LIMIT 5;


# Q6. Print the names of vendors that have more than 1000 transactions in a single month.
SELECT
    V.name AS VendorName
FROM
    Vendor AS V
JOIN
    Transaction AS T ON V.id = T.vendor_id
WHERE
    YEAR(T.transaction_date) = 2014
GROUP BY
    VendorName
HAVING
    COUNT(*) > 1000;


# Q7. Print the names of customers that own more than 10 credit cards.
SELECT
    C.name AS CustomerName
FROM
    Customer AS C
JOIN
    Ownership AS O ON C.id = O.customer_id
GROUP BY
    CustomerName
HAVING
    COUNT(DISTINCT O.credit_card_number) > 10;


# Q8. Print the names of customers that have posted a payment every single month in 2014.
SELECT
    C.name AS CustomerName
FROM
    Customer AS C
WHERE NOT EXISTS (
    SELECT DISTINCT
        1
    FROM
        (SELECT DISTINCT YEAR(payment_date) AS year, MONTH(payment_date) AS month
         FROM Payment
         WHERE YEAR(payment_date) = 2014) AS Months2014
    WHERE NOT EXISTS (
        SELECT
            P.payment_date
        FROM
            Payment AS P
        WHERE
            YEAR(P.payment_date) = 2014
            AND MONTH(P.payment_date) = Months2014.month
            AND P.credit_card_number IN (
                SELECT DISTINCT
                    O.credit_card_number
                FROM
                    Ownership AS O
                WHERE
                    O.customer_id = C.id
            )
    )
);



# Q9. Print the names of customers that have posted more than one payment in a single month.
SELECT
    C.name AS CustomerName
FROM
    Customer AS C
JOIN
    Payment AS P ON C.id = (
        SELECT DISTINCT
            O.customer_id
        FROM
            Ownership AS O
        WHERE
            O.credit_card_number = P.credit_card_number
    )
GROUP BY
    CustomerName, YEAR(P.payment_date), MONTH(P.payment_date)
HAVING
    COUNT(*) > 1;


# Q10. Print the names of customer that have a month without a payment in 2014.
SELECT DISTINCT
    C.name AS CustomerName
FROM
    Customer AS C
WHERE NOT EXISTS (
    SELECT DISTINCT
        1
    FROM
        Payment AS P
    WHERE
        YEAR(P.payment_date) = 2014
        AND C.id = (
            SELECT DISTINCT
                O.customer_id
            FROM
                Ownership AS O
            WHERE
                O.credit_card_number = P.credit_card_number
        )
)



