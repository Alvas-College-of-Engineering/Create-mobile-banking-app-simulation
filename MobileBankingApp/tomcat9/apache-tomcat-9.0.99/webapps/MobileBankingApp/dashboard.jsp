<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bank.model.User, com.bank.model.Account" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    User    user    = (User)    session.getAttribute("user");
    Account account = (Account) request.getAttribute("account");
    if (user == null || account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("en","IN"));
    nf.setMinimumFractionDigits(2);
    nf.setMaximumFractionDigits(2);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaBank – Dashboard</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%-- ========= NAVBAR ========= --%>
<nav class="navbar">
    <div class="navbar-inner">
        <a href="<%= request.getContextPath() %>/dashboard" class="navbar-brand">
            <div class="brand-icon">🏦</div>
            <span class="brand-name">Nexa<span>Bank</span></span>
        </a>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/dashboard" class="active">⬛ Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/transfer">↔ Transfer</a></li>
            <li><a href="<%= request.getContextPath() %>/billpay">🧾 Bill Pay</a></li>
            <li><a href="<%= request.getContextPath() %>/history">📋 History</a></li>
            <li class="nav-logout"><a href="<%= request.getContextPath() %>/logout">⎋ Logout</a></li>
        </ul>
    </div>
</nav>

<%-- ========= MAIN ========= --%>
<main class="page-container">

    <div class="page-header">
        <h1>Good day, <%= user.getFullName().split(" ")[0] %> 👋</h1>
        <p class="text-muted">Here's a snapshot of your account</p>
    </div>

    <%-- Dashboard Grid --%>
    <div class="dashboard-grid">

        <%-- Left: Bank Card + Stats --%>
        <div>
            <%-- Bank Card --%>
            <div class="bank-card mb-3">
                <div class="card-chip"></div>
                <div class="card-type"><%= account.getAccountType() %> Account</div>
                <div class="card-balance">
                    <span class="currency">₹</span><%= nf.format(account.getBalance()) %>
                </div>
                <div class="card-footer">
                    <div>
                        <div class="card-holder">Account Holder</div>
                        <div class="card-holder-name"><%= user.getFullName() %></div>
                    </div>
                    <div class="card-number"><%= account.getAccountNo() %></div>
                </div>
            </div>

            <%-- Stats Row --%>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon green">✓</div>
                    <div>
                        <div class="stat-label">Status</div>
                        <div class="stat-value text-accent"><%= account.getStatus() %></div>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue">👤</div>
                    <div>
                        <div class="stat-label">Username</div>
                        <div class="stat-value"><%= user.getUsername() %></div>
                    </div>
                </div>
            </div>
        </div>

        <%-- Right: Quick Actions --%>
        <div>
            <div class="card">
                <div class="section-title">⚡ Quick Actions</div>
                <div class="quick-actions">
                    <a href="<%= request.getContextPath() %>/transfer" class="quick-action-btn">
                        <div class="qa-icon">↔</div>
                        <div class="qa-label">Fund Transfer</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/billpay" class="quick-action-btn">
                        <div class="qa-icon">⚡</div>
                        <div class="qa-label">Electricity</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/billpay" class="quick-action-btn">
                        <div class="qa-icon">📱</div>
                        <div class="qa-label">Mobile</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/billpay" class="quick-action-btn">
                        <div class="qa-icon">🌊</div>
                        <div class="qa-label">Water Bill</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/billpay" class="quick-action-btn">
                        <div class="qa-icon">📡</div>
                        <div class="qa-label">Broadband</div>
                    </a>
                    <a href="<%= request.getContextPath() %>/history" class="quick-action-btn">
                        <div class="qa-icon">📋</div>
                        <div class="qa-label">History</div>
                    </a>
                </div>

                <hr class="divider">

                <%-- Account Info --%>
                <div class="section-title">ℹ Account Details</div>
                <table style="width:100%; font-size:0.88rem;">
                    <tr>
                        <td class="text-muted" style="padding: 0.5rem 0;">Account No</td>
                        <td class="mono" style="text-align:right; color:var(--white);"><%= account.getAccountNo() %></td>
                    </tr>
                    <tr>
                        <td class="text-muted" style="padding: 0.5rem 0;">Account Type</td>
                        <td style="text-align:right;"><%= account.getAccountType() %></td>
                    </tr>
                    <tr>
                        <td class="text-muted" style="padding: 0.5rem 0;">Email</td>
                        <td style="text-align:right;"><%= user.getEmail() %></td>
                    </tr>
                    <tr>
                        <td class="text-muted" style="padding: 0.5rem 0;">Phone</td>
                        <td style="text-align:right;"><%= user.getPhone() != null ? user.getPhone() : "—" %></td>
                    </tr>
                    <tr>
                        <td class="text-muted" style="padding: 0.5rem 0;">Available Balance</td>
                        <td style="text-align:right;" class="text-accent">₹<%= nf.format(account.getBalance()) %></td>
                    </tr>
                </table>
            </div>
        </div>

    </div>
</main>

<script src="<%= request.getContextPath() %>/js/validation.js"></script>
</body>
</html>
