const API = "http://localhost:5000/api";


function register() {

    fetch(API + "/register", {
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

        document.getElementById("message").innerText = data.message;

        if (data.success) {
            window.location.href = "/login";
        }
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
