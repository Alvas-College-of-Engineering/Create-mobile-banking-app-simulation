package com.bank.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model class representing a bank account.
 */
public class Account {

    private String     accountNo;
    private int        userId;
    private BigDecimal balance;
    private String     accountType;
    private String     status;
    private Timestamp  createdAt;

    public Account() {}

    public Account(String accountNo, int userId, BigDecimal balance, String accountType, String status) {
        this.accountNo   = accountNo;
        this.userId      = userId;
        this.balance     = balance;
        this.accountType = accountType;
        this.status      = status;
    }

    // Getters and Setters
    public String     getAccountNo()             { return accountNo; }
    public void       setAccountNo(String a)     { this.accountNo = a; }

    public int        getUserId()                { return userId; }
    public void       setUserId(int u)           { this.userId = u; }

    public BigDecimal getBalance()               { return balance; }
    public void       setBalance(BigDecimal b)   { this.balance = b; }

    public String     getAccountType()           { return accountType; }
    public void       setAccountType(String t)   { this.accountType = t; }

    public String     getStatus()                { return status; }
    public void       setStatus(String s)        { this.status = s; }

    public Timestamp  getCreatedAt()             { return createdAt; }
    public void       setCreatedAt(Timestamp t)  { this.createdAt = t; }
}
