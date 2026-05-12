package com.bank.servlet;

import com.bank.dao.AccountDAO;
import com.bank.model.Account;
import com.bank.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet handling the user dashboard.
 * Refreshes account balance from DB on every visit.
 */
public class DashboardServlet extends HttpServlet {

    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Refresh account from DB to get updated balance
        User user = (User) session.getAttribute("user");
        Account account = accountDAO.getAccountByUserId(user.getId());

        if (account != null) {
            session.setAttribute("account", account); // Keep session in sync
        }

        request.setAttribute("account", account);
        request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
    }
}
