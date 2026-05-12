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
    <title>NexaBank – Bill Payment</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .bill-types-grid {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 0.75rem;
            margin-bottom: 2rem;
        }
        .bill-type-card {
            border: 1px solid var(--card-border);
            border-radius: var(--radius-sm);
            padding: 0.9rem 0.5rem;
            text-align: center;
            cursor: pointer;
            transition: var(--transition);
            background: var(--card-bg);
        }
        .bill-type-card:hover, .bill-type-card.selected {
            border-color: var(--accent);
            background: rgba(0,198,167,0.08);
        }
        .bill-type-card .bt-icon { font-size: 1.5rem; margin-bottom: 0.3rem; }
        .bill-type-card .bt-label { font-size: 0.72rem; color: var(--muted); font-weight: 600; }
        @media (max-width: 600px) { .bill-types-grid { grid-template-columns: repeat(3,1fr); } }
    </style>
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
            <li><a href="<%= request.getContextPath() %>/transfer">↔ Transfer</a></li>
            <li><a href="<%= request.getContextPath() %>/billpay" class="active">🧾 Bill Pay</a></li>
            <li><a href="<%= request.getContextPath() %>/history">📋 History</a></li>
            <li class="nav-logout"><a href="<%= request.getContextPath() %>/logout">⎋ Logout</a></li>
        </ul>
    </div>
</nav>

<main class="page-container">
    <div class="page-header">
        <h1>🧾 Bill Payment</h1>
        <p class="text-muted">Pay all your bills quickly and securely</p>
    </div>

    <div style="display:grid; grid-template-columns: 1.3fr 1fr; gap:2rem; align-items:start;">

        <%-- Bill Pay Form --%>
        <div class="card card-lg">

            <%-- Alerts --%>
            <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="alert alert-error">⚠ <%= request.getAttribute("errorMsg") %></div>
            <% } %>
            <% if (request.getAttribute("successMsg") != null) { %>
                <div class="alert alert-success">✓ <%= request.getAttribute("successMsg") %></div>
            <% } %>
            <div id="clientError" class="alert alert-error" style="display:none;"></div>

            <%-- Visual Bill Type Selector --%>
            <div class="section-title mb-2">Select Service</div>
            <div class="bill-types-grid">
                <div class="bill-type-card" onclick="selectBill('ELECTRICITY', this)">
                    <div class="bt-icon">⚡</div><div class="bt-label">Electricity</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('WATER', this)">
                    <div class="bt-icon">🌊</div><div class="bt-label">Water</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('GAS', this)">
                    <div class="bt-icon">🔥</div><div class="bt-label">Gas</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('MOBILE', this)">
                    <div class="bt-icon">📱</div><div class="bt-label">Mobile</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('BROADBAND', this)">
                    <div class="bt-icon">📡</div><div class="bt-label">Broadband</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('DTH', this)">
                    <div class="bt-icon">📺</div><div class="bt-label">DTH</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('INSURANCE', this)">
                    <div class="bt-icon">🛡</div><div class="bt-label">Insurance</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('CREDIT_CARD', this)">
                    <div class="bt-icon">💳</div><div class="bt-label">Credit Card</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('LOAN_EMI', this)">
                    <div class="bt-icon">🏠</div><div class="bt-label">Loan EMI</div>
                </div>
                <div class="bill-type-card" onclick="selectBill('MUNICIPALITY', this)">
                    <div class="bt-icon">🏛</div><div class="bt-label">Municipality</div>
                </div>
            </div>

            <form id="billForm" action="<%= request.getContextPath() %>/billpay" method="POST" novalidate>

                <input type="hidden" id="billType" name="billType" value="">

                <div class="form-group">
                    <label class="form-label">Selected Service</label>
                    <div id="selectedBillDisplay" class="form-control" style="cursor:default; color:var(--muted);">
                        Click a service above
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="consumerNumber">Consumer / Reference Number</label>
                    <input
                        type="text"
                        id="consumerNumber"
                        name="consumerNumber"
                        class="form-control"
                        placeholder="Enter consumer/reference number"
                        maxlength="50"
                    >
                </div>

                <div class="form-group">
                    <label class="form-label" for="amount">Amount to Pay (₹)</label>
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

                <button type="submit" class="btn btn-primary btn-lg btn-full">
                    Pay Bill →
                </button>
            </form>
        </div>

        <%-- Sidebar --%>
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

            <div class="card" style="background:rgba(0,198,167,0.04); border-color:rgba(0,198,167,0.15);">
                <div class="section-title text-accent">✓ Why Pay Here?</div>
                <ul style="font-size:0.82rem; color:var(--muted); line-height:2; padding-left:1rem;">
                    <li>Instant processing</li>
                    <li>Zero transaction fees</li>
                    <li>Instant confirmation</li>
                    <li>Transaction history saved</li>
                    <li>10 service categories</li>
                </ul>
            </div>
        </div>

    </div>
</main>

<script src="<%= request.getContextPath() %>/js/validation.js"></script>
<script>
    function selectBill(type, el) {
        document.querySelectorAll('.bill-type-card').forEach(c => c.classList.remove('selected'));
        el.classList.add('selected');
        document.getElementById('billType').value = type;
        const labels = {
            'ELECTRICITY':'⚡ Electricity Bill','WATER':'🌊 Water Bill','GAS':'🔥 Gas Bill',
            'MOBILE':'📱 Mobile Recharge','BROADBAND':'📡 Broadband Bill','DTH':'📺 DTH Recharge',
            'INSURANCE':'🛡 Insurance Premium','CREDIT_CARD':'💳 Credit Card Payment',
            'LOAN_EMI':'🏠 Loan EMI','MUNICIPALITY':'🏛 Municipality Tax'
        };
        const display = document.getElementById('selectedBillDisplay');
        display.textContent = labels[type] || type;
        display.style.color = 'var(--white)';
    }
</script>
</body>
</html>
