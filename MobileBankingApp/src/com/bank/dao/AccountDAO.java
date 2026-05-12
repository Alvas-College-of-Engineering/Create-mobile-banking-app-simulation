package com.bank.dao;

import com.bank.model.Account;
import com.bank.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * DAO class for Account-related database operations.
 * Uses PreparedStatement exclusively to prevent SQL Injection.
 */
public class AccountDAO {

    /**
     * Retrieves account information by user ID.
     *
     * @param userId the account owner's user ID
     * @return Account object or null
     */
    public Account getAccountByUserId(int userId) {
        String sql = "SELECT account_no, user_id, balance, account_type, status FROM accounts WHERE user_id = ?";
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Account account = new Account();
                account.setAccountNo(rs.getString("account_no"));
                account.setUserId(rs.getInt("user_id"));
                account.setBalance(rs.getBigDecimal("balance"));
                account.setAccountType(rs.getString("account_type"));
                account.setStatus(rs.getString("status"));
                return account;
            }

        } catch (SQLException e) {
            System.err.println("AccountDAO.getAccountByUserId() error: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }

        return null;
    }

    /**
     * Retrieves account information by account number.
     *
     * @param accountNo the account number
     * @return Account object or null
     */
    public Account getAccountByAccountNo(String accountNo) {
        String sql = "SELECT account_no, user_id, balance, account_type, status FROM accounts WHERE account_no = ?";
        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, accountNo);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Account account = new Account();
                account.setAccountNo(rs.getString("account_no"));
                account.setUserId(rs.getInt("user_id"));
                account.setBalance(rs.getBigDecimal("balance"));
                account.setAccountType(rs.getString("account_type"));
                account.setStatus(rs.getString("status"));
                return account;
            }

        } catch (SQLException e) {
            System.err.println("AccountDAO.getAccountByAccountNo() error: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }

        return null;
    }

    /**
     * Updates the balance of a given account.
     * Must be called within the same Connection for transactions.
     *
     * @param conn      shared connection (caller manages it)
     * @param accountNo the account to update
     * @param newBalance the new balance value
     * @return true if successful
     */
    public boolean updateBalance(Connection conn, String accountNo, BigDecimal newBalance) throws SQLException {
        String sql = "UPDATE accounts SET balance = ? WHERE account_no = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setBigDecimal(1, newBalance);
        ps.setString(2, accountNo);
        return ps.executeUpdate() > 0;
    }

    /**
     * Deducts an amount from the given account.
     * Returns true on success, false if insufficient funds.
     *
     * @param conn      shared connection
     * @param accountNo the account to deduct from
     * @param amount    the amount to deduct
     */
    public boolean deductBalance(Connection conn, String accountNo, BigDecimal amount) throws SQLException {
        // Lock the row for atomic update
        String selectSql = "SELECT balance FROM accounts WHERE account_no = ? FOR UPDATE";
        PreparedStatement selectPs = conn.prepareStatement(selectSql);
        selectPs.setString(1, accountNo);
        ResultSet rs = selectPs.executeQuery();

        if (rs.next()) {
            BigDecimal currentBalance = rs.getBigDecimal("balance");
            if (currentBalance.compareTo(amount) < 0) {
                return false; // Insufficient funds
            }
            BigDecimal newBalance = currentBalance.subtract(amount);
            return updateBalance(conn, accountNo, newBalance);
        }
        return false;
    }

    /**
     * Credits an amount to the given account.
     *
     * @param conn      shared connection
     * @param accountNo the account to credit
     * @param amount    the amount to credit
     */
    public boolean creditBalance(Connection conn, String accountNo, BigDecimal amount) throws SQLException {
        String selectSql = "SELECT balance FROM accounts WHERE account_no = ?";
        PreparedStatement selectPs = conn.prepareStatement(selectSql);
        selectPs.setString(1, accountNo);
        ResultSet rs = selectPs.executeQuery();

        if (rs.next()) {
            BigDecimal currentBalance = rs.getBigDecimal("balance");
            BigDecimal newBalance = currentBalance.add(amount);
            return updateBalance(conn, accountNo, newBalance);
        }
        return false;
    }
}
