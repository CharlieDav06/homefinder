const API = "http://localhost:5000/api";


document.addEventListener("DOMContentLoaded", function () {
    const registerBtn = document.getElementById("registerBtn");

    if (registerBtn) {
        registerBtn.addEventListener("click", registerUser);
    }
});function registerUser() {
    const msg = document.getElementById("msg");

    fetch("http://localhost:5000/api/register", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            first_name: document.getElementById("first_name").value,
            last_name: document.getElementById("last_name").value,
            phone_number: document.getElementById("phone_number").value,
            email: document.getElementById("email").value,
            password: document.getElementById("password").value,
            gdpr_consent_given: document.getElementById("gdpr_consent_given").checked
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            msg.innerText = "Registration successful. Redirecting to login...";

            setTimeout(() => {
                window.location.href = "/login";
            }, 1000);
        } else {
            msg.innerText = data.message || "Registration failed.";
        }
    })
    .catch(error => {
        console.error(error);
        msg.innerText = "Server connection failed.";
    });
}

document.addEventListener("DOMContentLoaded", function () {
    const registerBtn = document.getElementById("registerBtn");

    if (registerBtn) {
        registerBtn.addEventListener("click", registerUser);
    }
});

function login() {

    fetch(API + "/login", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            email: document.getElementById("email").value,
            password: document.getElementById("password").value
        })
    })
    .then(res => res.json())
    .then(data => {

        if (data.success) {

            localStorage.setItem("userId", data.userId);

            window.location.href = "/twofa";

        } else {

            document.getElementById("message").innerText =
                data.message || "Login failed";
        }
    });
}


function verify2FA() {

    fetch(API + "/verify-2fa", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            userId: localStorage.getItem("userId"),
            token: document.getElementById("token").value
        })
    })
    .then(res => res.json())
    .then(data => {

        if (data.success) {

            window.location.href = "/properties";

        } else {

            document.getElementById("message").innerText =
                data.message || "Invalid code";
        }
    });
}
