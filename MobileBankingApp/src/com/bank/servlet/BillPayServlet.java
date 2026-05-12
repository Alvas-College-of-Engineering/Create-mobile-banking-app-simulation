package com.bank.servlet;

import com.bank.dao.AccountDAO;
import com.bank.dao.TransactionDAO;
import com.bank.model.Account;
import com.bank.model.Transaction;
import com.bank.model.User;
import com.bank.util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

/**
 * Servlet handling bill payments.
 * GET  → shows billpay.jsp
 * POST → validates and processes bill payment
 */
public class BillPayServlet extends HttpServlet {

    private final AccountDAO     accountDAO     = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    // Supported bill types for simulation
    private static final String[] VALID_BILL_TYPES = {
        "ELECTRICITY", "WATER", "GAS", "MOBILE", "BROADBAND",
        "DTH", "INSURANCE", "CREDIT_CARD", "LOAN_EMI", "MUNICIPALITY"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/billpay.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User    user    = (User)    session.getAttribute("user");
        Account account = (Account) session.getAttribute("account");

        String billType       = request.getParameter("billType");
        String consumerNumber = request.getParameter("consumerNumber");
        String amountStr      = request.getParameter("amount");

        // ------ Input Validation ------
        if (billType == null || billType.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Please select a bill type.");
            request.getRequestDispatcher("/billpay.jsp").forward(request, response);
            return;
        }

        if (consumerNumber == null || consumerNumber.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Consumer/Reference number is required.");
            request.getRequestDispatcher("/billpay.jsp").forward(request, response);
            return;
        }

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountStr.trim());
            if (amount.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException | NullPointerException e) {
            request.setAttribute("errorMsg", "Enter a valid positive amount.");
            request.getRequestDispatcher("/billpay.jsp").forward(request, response);
            return;
        }

        // Minimum bill amount
        if (amount.compareTo(new BigDecimal("1")) < 0) {
            request.setAttribute("errorMsg", "Minimum bill payment amount is ₹1.");
            request.getRequestDispatcher("/billpay.jsp").forward(request, response);
            return;
        }

        // ------ Atomic DB Operation ------
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean deducted = accountDAO.deductBalance(conn, account.getAccountNo(), amount);
            if (!deducted) {
                conn.rollback();
                request.setAttribute("errorMsg", "Insufficient balance. Your current balance is ₹" + account.getBalance());
                request.getRequestDispatcher("/billpay.jsp").forward(request, response);
                return;
            }

            String desc = getBillDescription(billType, consumerNumber);
            Transaction txn = new Transaction(account.getAccountNo(), null, amount, "BILL_PAYMENT", desc);
            transactionDAO.insertTransaction(conn, txn);

            conn.commit();

            // Refresh session account
            Account updatedAcc = accountDAO.getAccountByUserId(user.getId());
            session.setAttribute("account", updatedAcc);

            request.setAttribute("successMsg", "Bill payment of ₹" + amount + " successful for " + desc + ".");
            request.getRequestDispatcher("/billpay.jsp").forward(request, response);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            request.setAttribute("error", "Bill payment failed: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        } finally {
            DBConnection.closeConnection(conn);
        }
    }

    private String getBillDescription(String billType, String consumerNumber) {
        switch (billType.toUpperCase()) {
            case "ELECTRICITY": return "Electricity Bill - Consumer No: " + consumerNumber;
            case "WATER":       return "Water Bill - Consumer No: " + consumerNumber;
            case "GAS":         return "Gas Bill - Consumer No: " + consumerNumber;
            case "MOBILE":      return "Mobile Recharge - No: " + consumerNumber;
            case "BROADBAND":   return "Broadband Bill - Account: " + consumerNumber;
            case "DTH":         return "DTH Recharge - ID: " + consumerNumber;
            case "INSURANCE":   return "Insurance Premium - Policy: " + consumerNumber;
            case "CREDIT_CARD": return "Credit Card Payment - Card: " + consumerNumber;
            case "LOAN_EMI":    return "Loan EMI Payment - Account: " + consumerNumber;
            case "MUNICIPALITY":return "Municipality Tax - Property: " + consumerNumber;
            default:            return billType + " - Ref: " + consumerNumber;
        }
    }
}
