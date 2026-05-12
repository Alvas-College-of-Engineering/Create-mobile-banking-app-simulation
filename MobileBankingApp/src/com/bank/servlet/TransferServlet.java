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
 * Servlet handling fund transfer between accounts.
 * GET  → shows transfer.jsp
 * POST → validates and performs transfer atomically
 */
public class TransferServlet extends HttpServlet {

    private final AccountDAO     accountDAO     = new AccountDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        request.getRequestDispatcher("/transfer.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User    user       = (User)    session.getAttribute("user");
        Account senderAcc  = (Account) session.getAttribute("account");

        String receiverAccNo = request.getParameter("receiverAccNo");
        String amountStr     = request.getParameter("amount");
        String remarks       = request.getParameter("remarks");

        // ------ Input Validation ------
        if (receiverAccNo == null || receiverAccNo.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Receiver account number is required.");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);
            return;
        }

        if (receiverAccNo.trim().equals(senderAcc.getAccountNo())) {
            request.setAttribute("errorMsg", "Cannot transfer to your own account.");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);
            return;
        }

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountStr.trim());
            if (amount.compareTo(BigDecimal.ZERO) <= 0) throw new NumberFormatException();
        } catch (NumberFormatException | NullPointerException e) {
            request.setAttribute("errorMsg", "Enter a valid positive amount.");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);
            return;
        }

        // Minimum transfer amount
        if (amount.compareTo(new BigDecimal("1")) < 0) {
            request.setAttribute("errorMsg", "Minimum transfer amount is ₹1.");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);
            return;
        }

        // Receiver account existence check
        Account receiverAcc = accountDAO.getAccountByAccountNo(receiverAccNo.trim());
        if (receiverAcc == null) {
            request.setAttribute("errorMsg", "Receiver account not found. Please verify the account number.");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);
            return;
        }

        // ------ Atomic DB Transaction ------
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            boolean deducted = accountDAO.deductBalance(conn, senderAcc.getAccountNo(), amount);
            if (!deducted) {
                conn.rollback();
                request.setAttribute("errorMsg", "Insufficient balance. Your current balance is ₹" + senderAcc.getBalance());
                request.getRequestDispatcher("/transfer.jsp").forward(request, response);
                return;
            }

            accountDAO.creditBalance(conn, receiverAcc.getAccountNo(), amount);

            String desc = (remarks != null && !remarks.trim().isEmpty())
                         ? "Transfer to " + receiverAccNo + " - " + remarks.trim()
                         : "Fund Transfer to " + receiverAccNo;

            Transaction txn = new Transaction(senderAcc.getAccountNo(), receiverAccNo, amount, "TRANSFER", desc);
            transactionDAO.insertTransaction(conn, txn);

            conn.commit();

            // Refresh session account
            Account updatedAcc = accountDAO.getAccountByUserId(user.getId());
            session.setAttribute("account", updatedAcc);

            request.setAttribute("successMsg", "₹" + amount + " transferred successfully to account " + receiverAccNo + ".");
            request.getRequestDispatcher("/transfer.jsp").forward(request, response);

        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignore */ }
            }
            request.setAttribute("error", "Transfer failed due to a system error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        } finally {
            DBConnection.closeConnection(conn);
        }
    }
}
