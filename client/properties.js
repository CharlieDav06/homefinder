
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

  return allProperties.filter(property => {
    const name = (property.name || '').toLowerCase();
    const address = (property.location || '').toLowerCase();
    const type = property.type;

    const matchesSearch =
      name.includes(query) || address.includes(query);

    const matchesFilter = activeFilters.has(type);

    return matchesSearch && matchesFilter;
  });
}

function displayProperties(properties) {
  const grid = document.getElementById('property-grid');
  grid.innerHTML = '';

  properties.forEach(property => {
    const {
      property_id,
      name,
      location,
      image_url,
      price,
      type
    } = property;

    const safePrice = Number(price || 0);

    const formattedPrice =
      type === 'rental'
        ? `£${safePrice.toLocaleString()}/month`
        : `£${safePrice.toLocaleString()}`;

    grid.innerHTML += `
      <div class="property-container">
        <div class="property-image-container">
          <img class="property-image"
               src="/client/assets/property-images/${(image_url || '').split('/').pop()}"
               alt="${name}">
        </div>

        <div class="bottom-property-container">
          <div class="bottom-left-property">
            <div class="house-price">${formattedPrice}</div>
            <div class="house-name">${name}</div>
            <div class="house-location">${location}</div>
          </div>

          <div class="bottom-right-property">
            <button class="info-button"
                    onclick="goToProperty(${property_id})">
              Find out more
            </button>
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

updateNavbar();