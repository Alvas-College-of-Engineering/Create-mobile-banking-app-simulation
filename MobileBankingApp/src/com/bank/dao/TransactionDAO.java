package com.bank.dao;

import com.bank.model.Transaction;
import com.bank.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO class for Transaction-related database operations.
 * Uses PreparedStatement exclusively to prevent SQL Injection.
 */
public class TransactionDAO {

    /**
     * Inserts a new transaction record.
     * Uses the provided connection (for use within atomic operations).
     *
     * @param conn        shared connection (caller manages)
     * @param transaction the transaction to insert
     * @return true if successful
     */
    public boolean insertTransaction(Connection conn, Transaction transaction) throws SQLException {
        String sql = "INSERT INTO transactions (from_acc, to_acc, amount, type, description) VALUES (?, ?, ?, ?, ?)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, transaction.getFromAcc());
        ps.setString(2, transaction.getToAcc());
        ps.setBigDecimal(3, transaction.getAmount());
        ps.setString(4, transaction.getType());
        ps.setString(5, transaction.getDescription());
        return ps.executeUpdate() > 0;
    }

    /**
     * Fetches all transactions involving a specific account number.
     * Returns most recent transactions first.
     *
     * @param accountNo the account whose transactions to fetch
     * @return list of Transaction objects
     */
    public List<Transaction> getTransactionsByAccount(String accountNo) {
        String sql = "SELECT id, from_acc, to_acc, amount, type, description, date " +
                     "FROM transactions " +
                     "WHERE from_acc = ? OR to_acc = ? " +
                     "ORDER BY date DESC";
        Connection conn = null;
        List<Transaction> list = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, accountNo);
            ps.setString(2, accountNo);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Transaction t = new Transaction();
                t.setId(rs.getInt("id"));
                t.setFromAcc(rs.getString("from_acc"));
                t.setToAcc(rs.getString("to_acc"));
                t.setAmount(rs.getBigDecimal("amount"));
                t.setType(rs.getString("type"));
                t.setDescription(rs.getString("description"));
                t.setDate(rs.getTimestamp("date"));
                list.add(t);
            }

        } catch (SQLException e) {
            System.err.println("TransactionDAO.getTransactionsByAccount() error: " + e.getMessage());
        } finally {
            DBConnection.closeConnection(conn);
        }

        return list;
    }
}
