const API = "http://localhost:5000/api";

function updateNavbar() {
    const userId = localStorage.getItem("userId");
    const firstName = localStorage.getItem("firstName");
    const role = localStorage.getItem("role");

    if (userId && firstName) {
        document.getElementById("auth-buttons").innerHTML = `
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

function showTypeFields() {
    document.querySelectorAll('.type-fields').forEach(el => el.style.display = 'none');
    const type = document.getElementById('property-type').value;
    if (type) {
        document.getElementById(`${type}-fields`).style.display = 'block';
    }
}

function submitProperty() {
    const msg = document.getElementById('admin-msg');
    const type = document.getElementById('property-type').value;

    if (!type) {
        msg.innerText = 'Please select a property type.';
        return;
    }

    const base = {
        type,
        name: document.getElementById('name').value,
        location: document.getElementById('location').value,
        description: document.getElementById('description').value,
        image_url: document.getElementById('image_url').value,
        user_id: localStorage.getItem('userId')
    };

    let typeData = {};

    if (type === 'residential') {
        typeData = {
            num_bedrooms: document.getElementById('res-bedrooms').value,
            num_bathrooms: document.getElementById('res-bathrooms').value,
            price: document.getElementById('res-price').value,
            is_furnished: document.getElementById('res-furnished').checked
        };
    } else if (type === 'rental') {
        typeData = {
            num_bedrooms: document.getElementById('ren-bedrooms').value,
            num_bathrooms: document.getElementById('ren-bathrooms').value,
            monthly_rent: document.getElementById('ren-monthly-rent').value,
            security_deposit: document.getElementById('ren-security-deposit').value,
            lease_duration: document.getElementById('ren-lease-duration').value,
            lease_terms: document.getElementById('ren-lease-terms').value,
            is_furnished: document.getElementById('ren-furnished').checked,
            is_pet_friendly: document.getElementById('ren-pet-friendly').checked
        };
    } else if (type === 'commercial') {
        typeData = {
            square_ft: document.getElementById('com-sqft').value,
            floors: document.getElementById('com-floors').value,
            property_usage: document.getElementById('com-usage').value,
            zoning_type: document.getElementById('com-zoning').value,
            price: document.getElementById('com-price').value,
            has_parking: document.getElementById('com-parking').checked
        };
    }

    fetch(API + "/admin/add-property", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...base, ...typeData })
    })
    .then(res => res.json())
    .then(data => {
        msg.innerText = data.message || (data.success ? 'Property added!' : 'Failed.');
    });
}



function loadPropertiesForDelete() {
    fetch(API + '/properties')
        .then(res => res.json())
        .then(properties => {
            const container = document.getElementById('delete-property-list');
            container.innerHTML = '';

            properties.forEach(property => {
                const div = document.createElement('div');
                div.className = 'delete-property-row';
                div.id = `property-row-${property.property_id}`;
                div.innerHTML = `
                    <div class="delete-property-info">
                        <span class="delete-property-name">${property.name}</span>
                        <span class="delete-property-location">${property.location}</span>
                        <span class="delete-property-type">${property.type}</span>
                    </div>
                    <button class="delete-button" onclick="deleteProperty(${property.property_id})">Delete</button>
                `;
                container.appendChild(div);
            });
        });
}

function deleteProperty(propertyId) {
    if (!confirm('Are you sure you want to delete this property? This cannot be undone.')) return;

    fetch(API + `/admin/delete-property/${propertyId}`, {
        method: 'DELETE'
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            document.getElementById(`property-row-${propertyId}`).remove();
        } else {
            alert('Failed to delete property.');
        }
    });
}

loadPropertiesForDelete();









updateNavbar();
document.getElementById('property-type').addEventListener('change', showTypeFields);