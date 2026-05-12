package com.bank.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model class representing a bank transaction.
 */
public class Transaction {

    private int        id;
    private String     fromAcc;
    private String     toAcc;
    private BigDecimal amount;
    private String     type;
    private String     description;
    private Timestamp  date;

    public Transaction() {}

    public Transaction(String fromAcc, String toAcc, BigDecimal amount, String type, String description) {
        this.fromAcc     = fromAcc;
        this.toAcc       = toAcc;
        this.amount      = amount;
        this.type        = type;
        this.description = description;
    }

    // Getters and Setters
    public int        getId()                    { return id; }
    public void       setId(int i)               { this.id = i; }

    public String     getFromAcc()               { return fromAcc; }
    public void       setFromAcc(String f)       { this.fromAcc = f; }

    public String     getToAcc()                 { return toAcc; }
    public void       setToAcc(String t)         { this.toAcc = t; }

    public BigDecimal getAmount()                { return amount; }
    public void       setAmount(BigDecimal a)    { this.amount = a; }

    public String     getType()                  { return type; }
    public void       setType(String t)          { this.type = t; }

    public String     getDescription()           { return description; }
    public void       setDescription(String d)   { this.description = d; }

    public Timestamp  getDate()                  { return date; }
    public void       setDate(Timestamp d)       { this.date = d; }
}
