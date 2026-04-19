package org.example;
import com.github.javafaker.Faker;

import java.io.FileWriter;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.time.LocalDate;
import java.util.concurrent.ThreadLocalRandom;

public class Main {

    public static void main(String[] args) {
        Faker faker = new Faker();
        int numCustomers = 1000;
        int numCreditCards = 1000;
        int numVendors = 100;
        int numTransactions = 2000;
        int numPayments = 500;

        generateData(faker, numCustomers, numCreditCards, numVendors, numTransactions, numPayments);
    }

    public static void generateData(Faker faker, int numCustomers, int numCreditCards, int numVendors, int numTransactions, int numPayments) {
        try {
            FileWriter customerWriter = new FileWriter("customer_data.txt");
            FileWriter creditCardWriter = new FileWriter("credit_card_data.txt");
            FileWriter ownershipWriter = new FileWriter("ownership_data.txt");
            FileWriter vendorWriter = new FileWriter("vendor_data.txt");
            FileWriter transactionWriter = new FileWriter("transaction_data.txt");
            FileWriter paymentWriter = new FileWriter("payment_data.txt");

            Random random = new Random();
            List<String> cardNumbers = new ArrayList<>();
            List<OwnershipEntry> ownershipList = new ArrayList<>();

            for (int i = 1; i <= numCustomers; i++) {
                String ssn = generateRandomSSN();
                String name = faker.name().fullName().replace("'", "");
                String address = faker.address().streetAddress().replace("'", "") + ", " +
                        faker.address().city().replace("'", "") + ", " +
                        faker.address().stateAbbr().replace("'", "");

                String customerInsert = String.format("INSERT INTO Customer (id, ssn, name, address, phone_number) VALUES (%d, '%s', '%s', '%s', '%s');\n",
                        i, ssn, name, address, generateRandomPhoneNumber());
                customerWriter.write(customerInsert);

                int numCards = random.nextInt(3) + 1; // Each customer can own 1 to 3 cards

                for (int j = 0; j < numCards; j++) {
                    if (cardNumbers.size() >= numCreditCards) {
                        break;
                    }

                    String cardNumber = generateRandomCardNumber();
                    cardNumbers.add(cardNumber);

                    String cardType = getRandomCardType(random);
                    boolean isActive = random.nextBoolean();

                    String creditCardInsert = String.format("INSERT INTO CreditCard (number, type, credit_limit, current_balance, active) VALUES ('%s', '%s', %.2f, %.2f, %b);\n",
                            cardNumber, cardType, random.nextDouble() * 9000 + 1000,
                            random.nextDouble() * 500, isActive);
                    creditCardWriter.write(creditCardInsert);

                    ownershipList.add(new OwnershipEntry(i, cardNumber));
                }
            }


            for (int i = 1; i <= numVendors; i++) {
                String location = String.format("%s, %s, %s",
                        faker.address().streetAddress().replace("'", ""), faker.address().city().replace("'", ""), faker.address().stateAbbr().replace("'", ""));

                String vendorInsert = String.format("INSERT INTO Vendor (name, location) VALUES ('%s', '%s');\n",
                        faker.company().name().replace("'", ""), location);
                vendorWriter.write(vendorInsert);
            }

            for (int i = 0; i < numTransactions; i++) {
                int customerId = random.nextInt(numCustomers) + 1;
                String cardNumber = getRandomCardNumber(customerId, ownershipList, cardNumbers);
                int vendorId = random.nextInt(numVendors) + 1;
                BigDecimal amount = BigDecimal.valueOf(random.nextDouble() * 499 + 1);

                // Generate a random transaction date within a range
                LocalDate startDate = LocalDate.parse("2000-01-01");
                LocalDate endDate = LocalDate.parse("2023-08-31");
                LocalDate randomDate = startDate.plusDays(ThreadLocalRandom.current().nextLong(0, endDate.toEpochDay() - startDate.toEpochDay() + 1));

                String transactionInsert = String.format("INSERT INTO Transaction (transaction_date, customer_id, credit_card_number, vendor_id, amount) VALUES ('%s', %d, '%s', %d, %.2f);\n",
                        randomDate, customerId, cardNumber, vendorId, amount);
                transactionWriter.write(transactionInsert);
            }

            for (int i = 0; i < numPayments; i++) {
                int customerId = random.nextInt(numCustomers) + 1;
                List<String> customerCardNumbers = getCustomerCardNumbers(customerId, ownershipList);

                if (customerCardNumbers.isEmpty()) {
                    continue;
                }

                String cardNumber = customerCardNumbers.get(random.nextInt(customerCardNumbers.size()));
                BigDecimal amount = BigDecimal.valueOf(random.nextDouble() * 200);

                String paymentInsert = String.format("INSERT INTO Payment (payment_date, credit_card_number, amount) VALUES (CURRENT_DATE, '%s', %.2f);\n",
                        cardNumber, amount);
                paymentWriter.write(paymentInsert);
            }

            fillOwnershipTable(ownershipList, ownershipWriter);

            customerWriter.close();
            creditCardWriter.close();
            ownershipWriter.close();
            vendorWriter.close();
            transactionWriter.close();
            paymentWriter.close();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String generateRandomCardNumber() {
        Random random = new Random();
        StringBuilder cardNumber = new StringBuilder();
        for (int i = 0; i < 16; i++) {
            int digit = random.nextInt(10);
            cardNumber.append(digit);
        }
        return cardNumber.toString();
    }

    public static String getRandomCardType(Random random) {
        String[] cardTypes = {"VISA", "MC", "AMERICAN_EXPRESS", "DISCOVER"};
        return cardTypes[random.nextInt(cardTypes.length)];
    }

    public static String getRandomCardNumber(int customerId, List<OwnershipEntry> ownershipList, List<String> cardNumbers) {
        List<String> customerCardNumbers = getCustomerCardNumbers(customerId, ownershipList);
        if (!customerCardNumbers.isEmpty()) {
            return customerCardNumbers.get(new Random().nextInt(customerCardNumbers.size()));
        }
        return cardNumbers.get(new Random().nextInt(cardNumbers.size()));
    }

    public static List<String> getCustomerCardNumbers(int customerId, List<OwnershipEntry> ownershipList) {
        List<String> cardNumbers = new ArrayList<>();
        for (OwnershipEntry entry : ownershipList) {
            if (entry.getCustomerId() == customerId) {
                cardNumbers.add(entry.getCreditCardNumber());
            }
        }
        return cardNumbers;
    }

    public static void fillOwnershipTable(List<OwnershipEntry> ownershipList, FileWriter ownershipWriter) {
        for (OwnershipEntry entry : ownershipList) {
            String ownershipInsert = String.format("INSERT INTO Ownership (customer_id, credit_card_number) VALUES (%d, '%s');\n",
                    entry.getCustomerId(), entry.getCreditCardNumber());
            try {
                ownershipWriter.write(ownershipInsert);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public static String generateRandomPhoneNumber() {
        Random random = new Random();
        StringBuilder phoneNumber = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            int digit = random.nextInt(10);
            phoneNumber.append(digit);
        }
        return phoneNumber.toString();
    }

    public static String generateRandomSSN() {
        Random random = new Random();
        int firstPart = random.nextInt(900) + 100;
        int secondPart = random.nextInt(90) + 10;
        int thirdPart = random.nextInt(9000) + 1000;
        return String.format("%03d-%02d-%04d", firstPart, secondPart, thirdPart);
    }
}

class OwnershipEntry {
    private int customerId;
    private String creditCardNumber;

    public OwnershipEntry(int customerId, String creditCardNumber) {
        this.customerId = customerId;
        this.creditCardNumber = creditCardNumber;
    }

    public int getCustomerId() {
        return customerId;
    }

    public String getCreditCardNumber() {
        return creditCardNumber;
    }
}