<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NexaBank – Secure Login</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <style>
        .login-card { background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.09); border-radius: 20px; padding: 2.5rem; backdrop-filter: blur(20px); }
        .demo-creds { background: rgba(0,198,167,0.07); border: 1px solid rgba(0,198,167,0.2); border-radius: 10px; padding: 1rem 1.25rem; margin-top: 1.5rem; font-size: 0.82rem; }
        .demo-row { display: flex; justify-content: space-between; margin-bottom: 0.3rem; }
        .demo-row:last-child { margin-bottom: 0; }
        .demo-label { color: var(--muted); }
        .demo-value { font-family: var(--mono); color: var(--accent); }
        .pass-wrapper { position: relative; }
        .pass-toggle { position: absolute; right: 1rem; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--muted); cursor: pointer; font-size: 1rem; padding: 0; }
        .pass-toggle:hover { color: var(--white); }
    </style>
</head>
<body>
<div class="login-page">
    <div class="login-box">
        <div class="login-header">
            <div class="login-logo">🏦</div>
            <h1 class="login-title">NexaBank</h1>
            <p class="login-subtitle">Secure Mobile Banking Platform</p>
        </div>

        <div class="login-card">
            <h2 style="font-size:1.3rem; margin-bottom:1.5rem;">Sign in to your account</h2>

            <%-- Server-side error message --%>
            <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="alert alert-error">
                    ⚠ <%= request.getAttribute("errorMsg") %>
                </div>
            <% } %>

            <%-- Logout success message --%>
            <% if ("true".equals(request.getParameter("logout"))) { %>
                <div class="alert alert-success">
                    ✓ You have been signed out securely.
                </div>
            <% } %>

            <%-- Client-side error placeholder --%>
            <div id="clientError" class="alert alert-error" style="display:none;"></div>

            <form id="loginForm" action="<%= request.getContextPath() %>/login" method="POST" novalidate>
                <div class="form-group">
                    <label class="form-label" for="username">Username</label>
                    <input
                        type="text"
                        id="username"
                        name="username"
                        class="form-control"
                        placeholder="Enter your username"
                        autocomplete="username"
                        value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                    >
                </div>

                <div class="form-group">
                    <label class="form-label" for="password">Password</label>
                    <div class="pass-wrapper">
                        <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-control"
                            placeholder="Enter your password"
                            autocomplete="current-password"
                        >
                        <button type="button" class="pass-toggle" onclick="togglePass()">👁</button>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-lg btn-full" style="margin-top:0.5rem;">
                    Sign In  →
                </button>
            </form>

            <%-- Demo Credentials Panel --%>
            <div class="demo-creds">
                <div style="font-weight:600; color:var(--accent); margin-bottom:0.6rem;">🔑 Demo Accounts</div>
                <div class="demo-row"><span class="demo-label">alice / password123</span><span class="demo-value">₹75,000</span></div>
                <div class="demo-row"><span class="demo-label">bob / password123</span><span class="demo-value">₹42,500</span></div>
                <div class="demo-row"><span class="demo-label">charlie / password123</span><span class="demo-value">₹1,20,000</span></div>
            </div>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/validation.js"></script>
<script>
    function togglePass() {
        const p = document.getElementById('password');
        p.type = (p.type === 'password') ? 'text' : 'password';
    }
</script>
</body>
</html>
