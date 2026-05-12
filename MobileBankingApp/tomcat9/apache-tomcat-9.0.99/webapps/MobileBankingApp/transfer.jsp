<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bank.model.User, com.bank.model.Account" %>
<%@ page import="java.text.NumberFormat, java.util.Locale" %>
<%
    User    user    = (User)    session.getAttribute("user");
    Account account = (Account) session.getAttribute("account");
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
    <title>NexaBank – Fund Transfer</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%-- NAVBAR --%>
<nav class="navbar">
    <div class="navbar-inner">
        <a href="<%= request.getContextPath() %>/dashboard" class="navbar-brand">
            <div class="brand-icon">🏦</div>
            <span class="brand-name">Nexa<span>Bank</span></span>
        </a>
        <ul class="nav-links">
            <li><a href="<%= request.getContextPath() %>/dashboard">⬛ Dashboard</a></li>
            <li><a href="<%= request.getContextPath() %>/transfer" class="active">↔ Transfer</a></li>
            <li><a href="<%= request.getContextPath() %>/billpay">🧾 Bill Pay</a></li>
            <li><a href="<%= request.getContextPath() %>/history">📋 History</a></li>
            <li class="nav-logout"><a href="<%= request.getContextPath() %>/logout">⎋ Logout</a></li>
        </ul>
    </div>
</nav>

<main class="page-container">
    <div class="page-header">
        <h1>↔ Fund Transfer</h1>
        <p class="text-muted">Transfer funds instantly to any NexaBank account</p>
    </div>

    <div style="display:grid; grid-template-columns: 1.2fr 1fr; gap:2rem; align-items:start;">

        <%-- Transfer Form --%>
        <div class="card card-lg">
            <%-- Alerts --%>
            <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="alert alert-error">⚠ <%= request.getAttribute("errorMsg") %></div>
            <% } %>
            <% if (request.getAttribute("successMsg") != null) { %>
                <div class="alert alert-success">✓ <%= request.getAttribute("successMsg") %></div>
            <% } %>
            <div id="clientError" class="alert alert-error" style="display:none;"></div>

            <form id="transferForm" action="<%= request.getContextPath() %>/transfer" method="POST" novalidate>

                <div class="form-group">
                    <label class="form-label" for="receiverAccNo">Receiver Account Number</label>
                    <input
                        type="text"
                        id="receiverAccNo"
                        name="receiverAccNo"
                        class="form-control"
                        placeholder="e.g. ACC1001002"
                        maxlength="20"
                    >
                </div>

                <div class="form-group">
                    <label class="form-label" for="amount">Transfer Amount (₹)</label>
                    <input
                        type="number"
                        id="amount"
                        name="amount"
                        class="form-control"
                        placeholder="0.00"
                        min="1"
                        step="0.01"
                    >
                    <div id="amountPreview" style="display:none; margin-top:0.4rem; font-family:var(--mono); font-size:0.9rem; color:var(--accent);"></div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="remarks">Remarks (Optional)</label>
                    <input
                        type="text"
                        id="remarks"
                        name="remarks"
                        class="form-control"
                        placeholder="Purpose of transfer"
                        maxlength="100"
                    >
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-full">
                    Send Money →
                </button>
            </form>
        </div>

        <%-- Info Sidebar --%>
        <div>
            <div class="card mb-2">
                <div class="section-title">💳 Your Account</div>
                <div class="text-muted" style="font-size:0.82rem; margin-bottom:0.3rem;">Account Number</div>
                <div class="mono" style="font-size:1rem; margin-bottom:1rem;"><%= account.getAccountNo() %></div>
                <div class="text-muted" style="font-size:0.82rem; margin-bottom:0.3rem;">Available Balance</div>
                <div style="font-size:1.4rem; font-weight:700;" class="text-accent">
                    ₹<%= nf.format(account.getBalance()) %>
                </div>
            </div>

            <div class="card" style="background:rgba(244,200,66,0.05); border-color:rgba(244,200,66,0.15);">
                <div class="section-title text-gold">⚠ Transfer Guidelines</div>
                <ul style="font-size:0.82rem; color:var(--muted); line-height:1.8; padding-left:1rem;">
                    <li>Max transfer: ₹10,00,000 per transaction</li>
                    <li>Verify receiver account number carefully</li>
                    <li>Transfers are instant and irreversible</li>
                    <li>Receiver must have an active account</li>
                </ul>
            </div>
        </div>

    </div>
</main>

<script src="<%= request.getContextPath() %>/js/validation.js"></script>
</body>
</html>
