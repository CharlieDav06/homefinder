const params = new URLSearchParams(window.location.search);
const propertyId = params.get('id');

fetch(`http://localhost:5000/api/properties/${propertyId}`)
  .then(res => res.json())
  .then(property => {
    if (!property) {
      console.error("Property not found");
      return;
    }

    const {
      name,
      location,
      description,
      image_url,
      owner_email,
      price,
      type
    } = property;

    const formattedPrice =
      type === 'rental'
        ? `£${price.toLocaleString()}/month`
        : `£${price.toLocaleString()}`;

    document.getElementById('price').textContent = formattedPrice;
    document.getElementById('location').textContent = location;
    document.getElementById('description').textContent = description;
    document.getElementById('image').src =
      `/client/assets/property-images/${image_url.split('/').pop()}`;

    let roomsText = '';
    let detailsHTML = '';

    if (type === 'residential') {
      roomsText = `${property.num_bedrooms} Bedrooms · ${property.num_bathrooms} Bathrooms`;
      detailsHTML = `<li>${property.is_furnished ? 'Furnished' : 'Unfurnished'}</li>`;
    }

    else if (type === 'rental') {
      roomsText = `${property.num_bedrooms} Bedrooms · ${property.num_bathrooms} Bathrooms`;
      detailsHTML = `
        <li>${property.is_furnished ? 'Furnished' : 'Unfurnished'}</li>
        <li>${property.is_pet_friendly ? 'Pet Friendly' : 'No Pets'}</li>
        <li>Lease: ${property.lease_duration} months</li>
        <li>Security Deposit: £${Number(property.security_deposit).toLocaleString()}</li>
      `;
    }

    else if (type === 'commercial') {
      roomsText = `${property.square_ft.toLocaleString()} sq ft · ${property.floors} Floors`;
      detailsHTML = `
        <li>Usage: ${property.property_usage}</li>
        <li>${property.has_parking ? 'Parking Available' : 'No Parking'}</li>
        <li>Zoning: ${property.zoning_type}</li>
      `;
    }

    document.getElementById('rooms').textContent = roomsText;
    document.getElementById('property-details').innerHTML = detailsHTML;

    document.querySelector('.contact-button').addEventListener('click', function () {
      const subject = encodeURIComponent(`Enquiry about ${name}`);
      const body = encodeURIComponent(
        `Hi, I am interested in the property: ${name} located at ${location}.`
      );

      window.location.href =
        `mailto:${owner_email}?subject=${subject}&body=${body}`;
    });
  })
  .catch(err => console.error(err));




  // Open modal
document.querySelector('.book-button').addEventListener('click', () => {
  document.getElementById('modal-overlay').classList.add('active');
});

// Close modal
function closeModal() {
  document.getElementById('modal-overlay').classList.remove('active');
}
document.getElementById('modal-close').addEventListener('click', closeModal);
document.getElementById('modal-cancel').addEventListener('click', closeModal);
document.getElementById('modal-overlay').addEventListener('click', function (e) {
  if (e.target === this) closeModal(); // click outside to close
});

// Submit booking
document.getElementById('modal-submit').addEventListener('click', () => {
  const body = {
    property_id: propertyId,
    user_id: 1, // hardcode for now until you have auth
    reservation_name: document.getElementById('reservation-name').value,
    schedule_date: document.getElementById('schedule-date').value,
    reservation_duration: document.getElementById('reservation-duration').value,
    reservation_type: document.getElementById('reservation-type').value,
  };

  // Basic validation
  if (!body.reservation_name || !body.schedule_date) {
    alert('Please fill in all fields.');
    return;
  }

  fetch('http://localhost:5000/api/reservations', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        closeModal();
        alert('Viewing booked successfully!');
      } else {
        alert('Something went wrong. Please try again.');
      }
    })
    .catch(err => {
      console.error(err);
      alert('Could not connect to server.');
    });
});