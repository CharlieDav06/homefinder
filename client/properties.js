
const API = "http://localhost:5000/api";




let allProperties = [];
let activeFilters = new Set(['rental', 'residential', 'commercial']); // all on by default

fetch('http://localhost:5000/api/properties')
  .then(res => res.json())
  .then(properties => {
    allProperties = properties;
    displayProperties(getFilteredProperties());
  })
  .catch(err => console.error('Error fetching properties:', err));

function getFilteredProperties() {
    const query = document.getElementById('search-bar').value.toLowerCase();
    const sortValue = document.getElementById('sort-select').value;
    const priceRange = document.getElementById('price-filter').value;
    const bedroomsFilter = document.getElementById('bedrooms-filter').value;
    const furnishedFilter = document.getElementById('furnished-filter').checked;

    let filtered = allProperties.filter(property => {
        const name = (property.name || '').toLowerCase();
        const address = (property.location || '').toLowerCase();
        const type = property.type;
        const price = Number(property.price || 0);
        const bedrooms = Number(property.num_bedrooms || 0);
        const furnished = property.is_furnished;

        const matchesSearch = name.includes(query) || address.includes(query);
        const matchesFilter = activeFilters.has(type);

        let matchesPrice = true;
        if (priceRange) {
            const [min, max] = priceRange.split('-').map(Number);
            matchesPrice = price >= min && price <= max;
        }

        let matchesBedrooms = true;
        if (bedroomsFilter) {
            if (bedroomsFilter === '4') {
                matchesBedrooms = bedrooms >= 4;
            } else {
                matchesBedrooms = bedrooms === Number(bedroomsFilter);
            }
        }

        const matchesFurnished = !furnishedFilter || furnished;

        return matchesSearch && matchesFilter && matchesPrice && matchesBedrooms && matchesFurnished;
    });

    if (sortValue === 'asc') {
        filtered.sort((a, b) => Number(a.price) - Number(b.price));
    } else if (sortValue === 'desc') {
        filtered.sort((a, b) => Number(b.price) - Number(a.price));
    }

    return filtered;
}

function displayProperties(properties) {
    const grid = document.getElementById('property-grid');
    grid.innerHTML = '';
    const userId = localStorage.getItem('userId');

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
                    ${userId ? `<button class="fav-button" onclick="toggleFavourite(${property_id}, this)">♡</button>` : ''}
                </div>
                <div class="bottom-property-container">
                    <div class="bottom-left-property">
                        <div class="house-price">${formattedPrice}</div>
                        <div class="house-name">${name}</div>
                        <div class="house-location">${location}</div>
                    </div>
                    <div class="bottom-right-property">
                        <button class="info-button" onclick="goToProperty(${property_id})">Find out more</button>
                    </div>
                </div>
            </div>
        `;
    });
}

// Search
document.getElementById('search-bar').addEventListener('input', () => {
  displayProperties(getFilteredProperties());
});

// Filters
document.querySelectorAll('.filter-buttons').forEach(btn => {
  btn.addEventListener('click', function () {
    const type = this.textContent.toLowerCase();

    if (activeFilters.has(type)) {
      activeFilters.delete(type);
      this.classList.remove('selected');
    } else {
      activeFilters.add(type);
      this.classList.add('selected');
    }

    displayProperties(getFilteredProperties());
  });
});

function goToProperty(id) {
  window.location.href = `/client/property-info.html?id=${id}`;
}
function updateNavbar() {
    const userId = localStorage.getItem("userId");
    const firstName = localStorage.getItem("firstName");
    const role = localStorage.getItem("role");


    if (userId && firstName) {
    document.getElementById("auth-buttons").innerHTML = `
        ${role === 'admin' ? '<button class="log-in-button" onclick="window.location.href=\'/admin\'">Add Property</button>' : ''}
        <button class="log-in-button" onclick="window.location.href='/favourites'">♥ Saved</button>
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
        window.location.href = "/login";
    });
}



function toggleFavourite(propertyId, btn) {
    const userId = localStorage.getItem('userId');
    if (!userId) return;

    fetch(API + '/favourites/toggle', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ user_id: userId, property_id: propertyId })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            btn.textContent = data.favourited ? '♥' : '♡';
            btn.classList.toggle('favourited', data.favourited);
        }
    });
}



















document.getElementById('sort-select').addEventListener('change', () => displayProperties(getFilteredProperties()));
document.getElementById('price-filter').addEventListener('change', () => displayProperties(getFilteredProperties()));
document.getElementById('bedrooms-filter').addEventListener('change', () => displayProperties(getFilteredProperties()));
document.getElementById('furnished-filter').addEventListener('change', () => displayProperties(getFilteredProperties()));

updateNavbar();