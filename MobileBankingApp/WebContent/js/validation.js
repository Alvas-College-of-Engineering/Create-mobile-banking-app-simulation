/**
 * NexaBank - Client-side Form Validation
 * Provides instant feedback before server-side checks.
 */

// ── Transfer Form Validation ────────────────────────────────────
function validateTransferForm(event) {
    const accNo   = document.getElementById('receiverAccNo').value.trim();
    const amount  = parseFloat(document.getElementById('amount').value.trim());
    const errDiv  = document.getElementById('clientError');

    errDiv.style.display = 'none';
    errDiv.textContent = '';

    if (!accNo || accNo.length < 5) {
        showClientError(errDiv, 'Please enter a valid receiver account number (min 5 characters).');
        event.preventDefault(); return false;
    }

    if (isNaN(amount) || amount <= 0) {
        showClientError(errDiv, 'Please enter a valid positive amount.');
        event.preventDefault(); return false;
    }

    if (amount > 1000000) {
        showClientError(errDiv, 'Transfer limit per transaction is ₹10,00,000.');
        event.preventDefault(); return false;
    }

    return true;
}

// ── Bill Pay Form Validation ────────────────────────────────────
function validateBillForm(event) {
    const billType = document.getElementById('billType').value;
    const consNo   = document.getElementById('consumerNumber').value.trim();
    const amount   = parseFloat(document.getElementById('amount').value.trim());
    const errDiv   = document.getElementById('clientError');

    errDiv.style.display = 'none';

    if (!billType) {
        showClientError(errDiv, 'Please select a bill type.');
        event.preventDefault(); return false;
    }

    if (!consNo) {
        showClientError(errDiv, 'Consumer / Reference number is required.');
        event.preventDefault(); return false;
    }

    if (isNaN(amount) || amount <= 0) {
        showClientError(errDiv, 'Please enter a valid positive amount.');
        event.preventDefault(); return false;
    }

    return true;
}

// ── Login Form Validation ────────────────────────────────────
function validateLoginForm(event) {
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value.trim();
    const errDiv   = document.getElementById('clientError');

    if (errDiv) {
        errDiv.style.display = 'none';
    }

    if (!username) {
        if (errDiv) showClientError(errDiv, 'Username is required.');
        event.preventDefault(); return false;
    }

    if (!password) {
        if (errDiv) showClientError(errDiv, 'Password is required.');
        event.preventDefault(); return false;
    }

    return true;
}

// ── Helper ──────────────────────────────────────────────────────
function showClientError(el, message) {
    el.textContent = '⚠ ' + message;
    el.style.display = 'flex';
}

// ── Amount Formatter ────────────────────────────────────────────
function formatAmountInput(input) {
    const val = parseFloat(input.value);
    if (!isNaN(val) && val > 0) {
        const preview = document.getElementById('amountPreview');
        if (preview) {
            preview.textContent = '₹ ' + val.toLocaleString('en-IN', { minimumFractionDigits: 2 });
            preview.style.display = 'block';
        }
    }
}

// ── Auto-dismiss alerts ─────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    const alerts = document.querySelectorAll('.alert-success');
    alerts.forEach(alert => {
        setTimeout(() => {
            alert.style.opacity = '0';
            alert.style.transition = 'opacity 0.5s ease';
            setTimeout(() => { alert.style.display = 'none'; }, 500);
        }, 5000);
    });

    // Attach validators
    const transferForm = document.getElementById('transferForm');
    if (transferForm) transferForm.addEventListener('submit', validateTransferForm);

    const billForm = document.getElementById('billForm');
    if (billForm) billForm.addEventListener('submit', validateBillForm);

    const loginForm = document.getElementById('loginForm');
    if (loginForm) loginForm.addEventListener('submit', validateLoginForm);

    const amountInput = document.getElementById('amount');
    if (amountInput) amountInput.addEventListener('input', () => formatAmountInput(amountInput));
});
