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