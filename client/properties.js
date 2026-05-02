let allProperties = [];
let activeFilters = new Set(['rental', 'residential', 'commercial']); // all on by default

fetch('http://localhost:5000/api/properties')
  .then(response => response.json())
  .then(properties => {
    allProperties = properties;
    displayProperties(getFilteredProperties());
  })
  .catch(error => console.error('Error fetching properties:', error));

function getFilteredProperties() {
  const query = document.getElementById('search-bar').value.toLowerCase();
  return allProperties.filter(property => {
    const name = property[1].toLowerCase();
    const address = property[2].toLowerCase();
    const type = property[6];
    const matchesSearch = name.includes(query) || address.includes(query);
    const matchesFilter = activeFilters.has(type);
    return matchesSearch && matchesFilter;
  });
}

function displayProperties(properties) {
  const grid = document.getElementById('property-grid');
  grid.innerHTML = '';
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
          <img class="property-image" src="/client/assets/property-images/${image.split('/').pop()}" alt="${name}">
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
}

// Search bar listener
document.getElementById('search-bar').addEventListener('input', function() {
  displayProperties(getFilteredProperties());
});

// Filter buttons
document.querySelectorAll('.filter-buttons').forEach(btn => {
  btn.addEventListener('click', function() {
    const type = this.textContent.toLowerCase(); // 'rental', 'residential', 'commercial'
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