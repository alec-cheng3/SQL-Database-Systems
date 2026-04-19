# 1. Print the SSN of John Smith.
SELECT
    ssn
FROM
    Customer
WHERE
    Name = 'John Smith';

# 2. Print the numbers of all the credit cards of John Smith.
SELECT
    credit_card_number
FROM
    Ownership
JOIN
    Customer ON Ownership.customer_id = Customer.id
WHERE
    name = 'John Smith';

# 3. Print all the transaction information from January 1st, 2015 for credit card number 1236666.
SELECT
    *
FROM
    Transaction
WHERE
    credit_card_number = '1236666'
    AND transaction_date >= '2015-01-01';

# 4. Print the credit limit for all credit cards of Maria Johnson.
SELECT
    number,
    credit_limit
FROM
    Ownership
JOIN Customer ON Ownership.customer_id = Customer.id
JOIN CreditCard ON Ownership.credit_card_number = CreditCard.number
WHERE
    name = 'Maria Johnson';


# 5. Print the names of vendors who have transaction on January 2nd, 2015.
SELECT
    name
FROM
    Vendor
JOIN Transaction ON Vendor.id = Transaction.vendor_id
WHERE
    transaction_date = '2015-02-01';

