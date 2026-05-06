const API = "http://localhost:5000/api";

function updateNavbar() {
    const userId = localStorage.getItem("userId");
    const firstName = localStorage.getItem("firstName");
    const role = localStorage.getItem("role");

    if (userId && firstName) {
        document.getElementById("auth-buttons").innerHTML = `
            ${role === 'admin' ? '<button class="log-in-button" onclick="window.location.href=\'/admin\'">Add Property</button>' : ''}
            <span class="user-greeting">Hi ${firstName}!</span>
            <button class="log-in-button" onclick="logout()">Logout</button>
        `;
    }
}

function logout() {
    fetch(API + "/logout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ userId: localStorage.getItem("userId") })
    }).then(() => {
        localStorage.removeItem("userId");
        localStorage.removeItem("firstName");
        localStorage.removeItem("role");
        window.location.href = "/login";
    });
}

function loadFavourites() {
    const userId = localStorage.getItem('userId');
    if (!userId) {
        window.location.href = '/login';
        return;
    }

    fetch(API + `/favourites/${userId}`)
        .then(res => res.json())
        .then(properties => {
            document.getElementById('fav-count').innerText = 
                `${properties.length} saved propert${properties.length === 1 ? 'y' : 'ies'}`;

            const grid = document.getElementById('favourites-grid');
            grid.innerHTML = '';

            if (properties.length === 0) {
                grid.innerHTML = `
                    <div style="text-align:center; margin: 50px auto; color: grey;">
                        <p style="font-size:3rem;">♡</p>
                        <h3>Nothing saved yet</h3>
                        <p>Click the ♡ heart on any property to save it here.</p>
                        <button class="log-in-button" onclick="window.location.href='/properties'">Browse Properties</button>
                    </div>
                `;
                return;
            }

            properties.forEach(property => {
                const {property_id, name, location, image_url, price, type} = property;
                const safePrice = Number(price || 0);
                const formattedPrice = type === 'rental'
                    ? `£${safePrice.toLocaleString()}/month`
                    : `£${safePrice.toLocaleString()}`;

                grid.innerHTML += `
                    <div class="property-container">
                        <div class="property-image-container">
                            <img class="property-image"
                                 src="/client/assets/property-images/${(image_url || '').split('/').pop()}"
                                 alt="${name}">
                            <button class="fav-button favourited" onclick="removeFavourite(${property_id}, this)">♥</button>
                        </div>
                        <div class="bottom-property-container">
                            <div class="bottom-left-property">
                                <div class="house-price">${formattedPrice}</div>
                                <div class="house-name">${name}</div>
                                <div class="house-location">${location}</div>
                            </div>
                            <div class="bottom-right-property">
                                <button class="info-button" onclick="window.location.href='/client/property-info.html?id=${property_id}'">Find out more</button>
                            </div>
                        </div>
                    </div>
                `;
            });
        });
}

function removeFavourite(propertyId, btn) {
    const userId = localStorage.getItem('userId');
    fetch(API + '/favourites/toggle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: userId, property_id: propertyId })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            btn.closest('.property-container').remove();
            const remaining = document.querySelectorAll('.property-container').length;
            document.getElementById('fav-count').innerText = 
                `${remaining} saved propert${remaining === 1 ? 'y' : 'ies'}`;
        }
    });
}

updateNavbar();
loadFavourites();