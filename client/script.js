const API = "http://localhost:5000/api";


document.addEventListener("DOMContentLoaded", function () {
    const registerBtn = document.getElementById("registerBtn");

    if (registerBtn) {
        registerBtn.addEventListener("click", registerUser);
    }
});

function registerUser() {
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    const msg = document.getElementById("msg");

    msg.innerText = "Registering...";

    fetch(API + "/register", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            email: email,
            password: password
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            msg.innerText = "Registration successful. Redirecting...";

            setTimeout(function () {
                window.location.href = "/properties";
            }, 1000);
        } else {
            msg.innerText = data.message || "Registration failed.";
        }
    })
    .catch(error => {
        console.error("Register error:", error);
        msg.innerText = "Could not connect to server.";
    });
}

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
