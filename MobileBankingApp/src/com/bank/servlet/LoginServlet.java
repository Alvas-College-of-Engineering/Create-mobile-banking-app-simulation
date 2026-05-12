package com.bank.servlet;

import com.bank.dao.AccountDAO;
import com.bank.dao.UserDAO;
import com.bank.model.Account;
import com.bank.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet handling user login.
 * GET  → shows login.jsp
 * POST → validates credentials, creates session, redirects to dashboard
 */
public class LoginServlet extends HttpServlet {

    private final UserDAO    userDAO    = new UserDAO();
    private final AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Basic input validation
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMsg", "Username and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.validateUser(username.trim(), password.trim());

        if (user != null) {
            Account account = accountDAO.getAccountByUserId(user.getId());

            if (account == null) {
                request.setAttribute("errorMsg", "No account found for this user. Contact support.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Create a new session (invalidate old to prevent session fixation)
            HttpSession session = request.getSession(false);
            if (session != null) session.invalidate();
            session = request.getSession(true);

            session.setAttribute("user", user);
            session.setAttribute("account", account);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            response.sendRedirect(request.getContextPath() + "/dashboard");

        } else {
            request.setAttribute("errorMsg", "Invalid username or password. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
