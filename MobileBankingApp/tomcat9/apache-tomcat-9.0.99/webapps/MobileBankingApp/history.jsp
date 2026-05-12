<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.bank.model.User, com.bank.model.Account, com.bank.model.Transaction" %>
<%@ page import="java.util.List, java.text.NumberFormat, java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User    user    = (User)    session.getAttribute("user");
    Account account = (Account) session.getAttribute("account");
    if (user == null || account == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("en","IN"));
    nf.setMinimumFractionDigits(2);
    nf.setMaximumFractionDigits(2);
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaBank – Transaction History</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .filter-bar {
            display: flex;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 1.5rem;
        }
        .filter-btn {
            padding: 0.45rem 1rem;
            border-radius: 100px;
            border: 1px solid var(--card-border);
            background: var(--card-bg);
            color: var(--muted);
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            font-family: var(--font);
            transition: var(--transition);
        }
        .filter-btn:hover, .filter-btn.active {
            border-color: var(--accent);
            color: var(--accent);
            background: rgba(0,198,167,0.08);
        }
        .summary-strip {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1rem;
            margin-bottom: 2rem;
        }
        @media (max-width: 600px) {
            .summary-strip { grid-template-columns: 1fr; }
        }
        .search-box {
            width: 100%;
            max-width: 320px;
        }
        #noResults {
            text-align: center;
            padding: 3rem;
            color: var(--muted);
            display: none;
        }
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
            <li><a href="<%= request.getContextPath() %>/billpay">🧾 Bill Pay</a></li>
            <li><a href="<%= request.getContextPath() %>/history" class="active">📋 History</a></li>
            <li class="nav-logout"><a href="<%= request.getContextPath() %>/logout">⎋ Logout</a></li>
        </ul>
    </div>
</nav>

<main class="page-container">
    <div class="page-header">
        <h1>📋 Transaction History</h1>
        <p class="text-muted">All transactions for account <span class="mono text-accent"><%= account.getAccountNo() %></span></p>
    </div>

    <%-- Summary Strip --%>
    <%
        double totalCredit = 0, totalDebit = 0;
        int txnCount = (transactions != null) ? transactions.size() : 0;
        if (transactions != null) {
            for (Transaction t : transactions) {
                if ("TRANSFER".equals(t.getType()) && account.getAccountNo().equals(t.getToAcc())) {
                    totalCredit += t.getAmount().doubleValue();
                } else if ("TRANSFER".equals(t.getType()) && account.getAccountNo().equals(t.getFromAcc())) {
                    totalDebit += t.getAmount().doubleValue();
                } else if ("BILL_PAYMENT".equals(t.getType())) {
                    totalDebit += t.getAmount().doubleValue();
                }
            }
        }
        NumberFormat nfSummary = NumberFormat.getNumberInstance(new Locale("en","IN"));
        nfSummary.setMinimumFractionDigits(2);
        nfSummary.setMaximumFractionDigits(2);
    %>
    <div class="summary-strip">
        <div class="stat-card">
            <div class="stat-icon blue">📊</div>
            <div>
                <div class="stat-label">Total Transactions</div>
                <div class="stat-value"><%= txnCount %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon green">⬇</div>
            <div>
                <div class="stat-label">Total Credits</div>
                <div class="stat-value text-accent">₹<%= nfSummary.format(totalCredit) %></div>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon red">⬆</div>
            <div>
                <div class="stat-label">Total Debits</div>
                <div class="stat-value text-danger">₹<%= nfSummary.format(totalDebit) %></div>
            </div>
        </div>
    </div>

    <%-- Filter & Search Bar --%>
    <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; margin-bottom:1.5rem;">
        <div class="filter-bar" style="margin-bottom:0;">
            <button class="filter-btn active" onclick="filterTxns('ALL', this)">All</button>
            <button class="filter-btn" onclick="filterTxns('TRANSFER', this)">Transfers</button>
            <button class="filter-btn" onclick="filterTxns('BILL_PAYMENT', this)">Bill Payments</button>
            <button class="filter-btn" onclick="filterTxns('CREDIT', this)">Credits</button>
            <button class="filter-btn" onclick="filterTxns('DEBIT', this)">Debits</button>
        </div>
        <input
            type="text"
            id="searchInput"
            class="form-control search-box"
            placeholder="🔍 Search transactions..."
            oninput="searchTxns(this.value)"
            style="margin-bottom:0;"
        >
    </div>

    <%-- Transactions Table --%>
    <div class="table-wrapper">
        <table id="txnTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Date & Time</th>
                    <th>Type</th>
                    <th>Description</th>
                    <th>From Account</th>
                    <th>To Account</th>
                    <th>Amount</th>
                    <th>Dr / Cr</th>
                </tr>
            </thead>
            <tbody id="txnBody">
            <%
                if (transactions == null || transactions.isEmpty()) {
            %>
                <tr>
                    <td colspan="8" style="text-align:center; padding:3rem; color:var(--muted);">
                        No transactions found for this account.
                    </td>
                </tr>
            <%
                } else {
                    int sl = 1;
                    for (Transaction t : transactions) {
                        boolean isCredit = "TRANSFER".equals(t.getType())
                                          && account.getAccountNo().equals(t.getToAcc());
                        boolean isBillPay = "BILL_PAYMENT".equals(t.getType());
                        String drCr   = isCredit ? "CR" : "DR";
                        String amtCls = isCredit ? "amount-credit" : "amount-debit";
                        String amtPfx = isCredit ? "+ ₹" : "- ₹";
                        String typeBadge = isBillPay ? "badge-bill" : (isCredit ? "badge-credit" : "badge-transfer");
                        String typeLabel = isBillPay ? "BILL PAY" : "TRANSFER";
                        String txnType   = t.getType();
                        String dateStr   = (t.getDate() != null) ? sdf.format(t.getDate()) : "—";
            %>
                <tr class="txn-row"
                    data-type="<%= txnType %>"
                    data-drcr="<%= drCr %>"
                    data-desc="<%= t.getDescription() != null ? t.getDescription().toLowerCase() : "" %>">
                    <td class="text-muted"><%= sl++ %></td>
                    <td style="font-size:0.82rem; white-space:nowrap;"><%= dateStr %></td>
                    <td><span class="badge <%= typeBadge %>"><%= typeLabel %></span></td>
                    <td style="max-width:220px; white-space:normal; font-size:0.85rem;">
                        <%= t.getDescription() != null ? t.getDescription() : "—" %>
                    </td>
                    <td class="acc-mono"><%= t.getFromAcc() != null ? t.getFromAcc() : "—" %></td>
                    <td class="acc-mono"><%= t.getToAcc()   != null ? t.getToAcc()   : "—" %></td>
                    <td class="<%= amtCls %>"><%= amtPfx %><%= nf.format(t.getAmount()) %></td>
                    <td>
                        <span class="badge <%= isCredit ? "badge-credit" : "badge-debit" %>">
                            <%= drCr %>
                        </span>
                    </td>
                </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>
        <div id="noResults">
            <div style="font-size:2.5rem; margin-bottom:0.5rem;">🔍</div>
            <div>No matching transactions found.</div>
        </div>
    </div>

    <%-- Export hint --%>
    <div style="margin-top:1rem; text-align:right;">
        <span class="text-muted" style="font-size:0.8rem;">Showing all transactions · Use filters or search to narrow results</span>
    </div>

</main>

<script src="<%= request.getContextPath() %>/js/validation.js"></script>
<script>
    let currentFilter = 'ALL';

    function filterTxns(type, btn) {
        currentFilter = type;
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyFilters();
    }

    function searchTxns(query) {
        applyFilters(query.toLowerCase());
    }

    function applyFilters(searchQuery) {
        const rows   = document.querySelectorAll('.txn-row');
        const search = searchQuery !== undefined
                       ? searchQuery
                       : document.getElementById('searchInput').value.toLowerCase();
        let visible  = 0;

        rows.forEach(row => {
            const type  = row.dataset.type;
            const drCr  = row.dataset.drcr;
            const desc  = row.dataset.desc;

            let matchFilter = true;
            if (currentFilter === 'TRANSFER')    matchFilter = type === 'TRANSFER';
            if (currentFilter === 'BILL_PAYMENT') matchFilter = type === 'BILL_PAYMENT';
            if (currentFilter === 'CREDIT')      matchFilter = drCr === 'CR';
            if (currentFilter === 'DEBIT')       matchFilter = drCr === 'DR';

            const matchSearch = !search || desc.includes(search)
                                        || row.textContent.toLowerCase().includes(search);

            if (matchFilter && matchSearch) {
                row.style.display = '';
                visible++;
            } else {
                row.style.display = 'none';
            }
        });

        document.getElementById('noResults').style.display = visible === 0 ? 'block' : 'none';
    }
</script>
</body>
</html>
