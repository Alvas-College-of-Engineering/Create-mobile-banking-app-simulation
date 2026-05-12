<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaBank – Error</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body>

<%-- Minimal navbar --%>
<nav class="navbar">
    <div class="navbar-inner">
        <a href="<%= request.getContextPath() %>/dashboard" class="navbar-brand">
            <div class="brand-icon">🏦</div>
            <span class="brand-name">Nexa<span>Bank</span></span>
        </a>
    </div>
</nav>

<div class="error-page">
    <div>
        <%
            String errorMsg   = (String)  request.getAttribute("error");
            Integer errorCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
            String  errorUri  = (String)  request.getAttribute("javax.servlet.error.request_uri");

            int code = (errorCode != null) ? errorCode : 500;
        %>

        <div class="error-code"><%= code %></div>

        <h1 class="error-title">
            <% if (code == 404) { %>
                Page Not Found
            <% } else if (code == 403) { %>
                Access Denied
            <% } else { %>
                Something Went Wrong
            <% } %>
        </h1>

        <p class="error-msg" style="max-width:420px; margin:0 auto 2rem;">
            <% if (errorMsg != null) { %>
                <%= errorMsg %>
            <% } else if (code == 404) { %>
                The page you are looking for doesn't exist or has been moved.
                <% if (errorUri != null) { %>
                    <br><span class="mono" style="font-size:0.82rem; color:var(--muted);"><%= errorUri %></span>
                <% } %>
            <% } else { %>
                An unexpected error occurred. Please try again or contact support.
            <% } %>
        </p>

        <%-- Stack trace in dev mode (remove in production) --%>
        <% if (exception != null && System.getProperty("bank.debug", "false").equals("true")) { %>
        <div style="background:rgba(255,79,107,0.08); border:1px solid rgba(255,79,107,0.2); border-radius:10px; padding:1rem; text-align:left; max-width:600px; margin:0 auto 2rem; font-family:var(--mono); font-size:0.75rem; color:#FF8FA3; overflow-x:auto;">
            <strong>Debug Info:</strong><br>
            <%= exception.getClass().getName() %>: <%= exception.getMessage() %>
        </div>
        <% } %>

        <div style="display:flex; gap:1rem; justify-content:center; flex-wrap:wrap;">
            <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-primary">
                ⬛ Go to Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-outline">
                ← Back to Login
            </a>
        </div>
    </div>
</div>

</body>
</html>
