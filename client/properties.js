fetch('http://localhost:5000/properties')
  .then(response => response.json())
  .then(properties => {
    const grid = document.getElementById('property-grid');

    properties.forEach(property => {
      const name = property[1];
      const address = property[2];
      const image = property[4];
      const price = property[5];
      const type = property[6];

      const formattedPrice = type === 'rental'
        ? `£${price.toLocaleString()}/month`
        : `£${price.toLocaleString()}`;

      grid.innerHTML += `
        <div class="property-container">
          <div class="property-image-container">
            <img class="property-image" src="/client/assets/images/${image.split('/').pop()}" alt="${name}">
          </div>
          <div class="bottom-property-container">
            <div class="bottom-left-property">
              <div class="house-price">${formattedPrice}</div>
              <div class="house-name">${name}</div>
              <div class="house-location">${address}</div>
            </div>
            <div class="bottom-right-property">
              <button class="info-button">Find out more</button>
            </div>
          </div>
        </div>
      `;
    });
  })
  .catch(error => console.error('Error fetching properties:', error));