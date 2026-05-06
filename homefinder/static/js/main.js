/* ============================================================
   HomeFinder Portal — main.js
   Handles: favourites drawer, heart buttons, user menu
   ============================================================ */

document.addEventListener('DOMContentLoaded', function () {

  // ── Favourites Drawer ──────────────────────────────────────
  const trigger  = document.getElementById('favDrawerTrigger');
  const drawer   = document.getElementById('favDrawer');
  const overlay  = document.getElementById('favOverlay');
  const closeBtn = document.getElementById('drawerClose');

  function openDrawer() {
    drawer.classList.add('open');
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
    loadDrawerItems();
  }
  function closeDrawer() {
    drawer.classList.remove('open');
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  if (trigger) trigger.addEventListener('click', openDrawer);
  if (closeBtn) closeBtn.addEventListener('click', closeDrawer);
  if (overlay)  overlay.addEventListener('click', closeDrawer);

  // ── Load drawer mini-cards from the current page's property cards ─
  function loadDrawerItems() {
    const listEl = document.getElementById('drawerList');
    const emptyEl = document.getElementById('drawerEmpty');
    if (!listEl) return;

    // Collect saved IDs from heart buttons that are active
    const activeHearts = document.querySelectorAll('.heart-btn.active, .heart-btn-lg.active');
    const savedIds = new Set([...activeHearts].map(b => b.dataset.id));

    // Also check nav badge count as a fallback indicator
    const count = parseInt(document.getElementById('navFavCount')?.textContent || '0');

    if (savedIds.size === 0 && count === 0) {
      listEl.innerHTML = '';
      if (emptyEl) emptyEl.style.display = 'block';
      return;
    }
    if (emptyEl) emptyEl.style.display = 'none';

    // Build mini cards from property cards on the page
    const cards = document.querySelectorAll('.property-card');
    let html = '';
    cards.forEach(card => {
      const id = card.dataset.id;
      const heartBtn = card.querySelector('.heart-btn');
      if (!heartBtn || !heartBtn.classList.contains('active')) return;

      const img   = card.querySelector('.card-img-wrap img')?.src || '';
      const title = card.querySelector('.card-title a')?.textContent?.trim() || 'Property';
      const price = card.querySelector('.card-price')?.textContent?.trim() || '';
      const loc   = card.querySelector('.card-location')?.textContent?.trim() || '';
      const link  = card.querySelector('.card-title a')?.href || '#';

      html += `
        <div class="drawer-item" id="drawer-item-${id}">
          <a href="${link}"><img src="${img}" alt="${title}"/></a>
          <div class="drawer-item-info">
            <div class="drawer-item-title">
              <a href="${link}">${title}</a>
            </div>
            <div class="drawer-item-price">${price}</div>
            <div class="drawer-item-loc">${loc}</div>
          </div>
          <button class="drawer-remove" data-id="${id}" title="Remove">✕</button>
        </div>`;
    });

    listEl.innerHTML = html || '<p style="font-size:.85rem;color:var(--text-muted);padding:1rem 0">No saved properties on this page. <a href="/favourites">View all →</a></p>';

    // Remove buttons inside drawer
    listEl.querySelectorAll('.drawer-remove').forEach(btn => {
      btn.addEventListener('click', () => toggleFav(btn.dataset.id));
    });
  }

  // ── Heart Button Toggle ────────────────────────────────────
  function toggleFav(id) {
    fetch(`/api/favourite/${id}`, { method: 'POST' })
      .then(r => r.json())
      .then(data => {
        // Update all heart buttons for this property
        document.querySelectorAll(`.heart-btn[data-id="${id}"]`).forEach(btn => {
          btn.classList.toggle('active', data.added);
          btn.textContent = data.added ? '♥' : '♡';
        });

        // Detail page heart
        const detailHeart = document.getElementById('detailHeart');
        if (detailHeart && detailHeart.dataset.id == id) {
          detailHeart.classList.toggle('active', data.added);
          detailHeart.textContent = data.added ? '♥ Saved' : '♡ Save';
        }

        // Update badge counts
        const badge = document.getElementById('navFavCount');
        const drawerCount = document.getElementById('drawerFavCount');
        if (badge) {
          badge.textContent = data.count;
          badge.style.display = data.count > 0 ? 'flex' : 'none';
        }
        if (drawerCount) drawerCount.textContent = data.count;

        // Remove from drawer if unsaved
        if (!data.added) {
          const item = document.getElementById(`drawer-item-${id}`);
          if (item) item.remove();
        }

        // Pulse animation on badge
        if (badge && data.added) {
          badge.style.transform = 'scale(1.4)';
          setTimeout(() => badge.style.transform = '', 250);
        }
      })
      .catch(() => {
        // Fallback: redirect to login if unauthenticated
        window.location.href = '/login';
      });
  }

  // Attach to all heart buttons
  document.querySelectorAll('.heart-btn').forEach(btn => {
    btn.addEventListener('click', e => {
      e.preventDefault();
      e.stopPropagation();
      toggleFav(btn.dataset.id);
    });
  });

  // Detail page large heart
  const detailHeart = document.getElementById('detailHeart');
  if (detailHeart) {
    detailHeart.addEventListener('click', () => toggleFav(detailHeart.dataset.id));
  }

  // ── User Dropdown ──────────────────────────────────────────
  const userBtn      = document.getElementById('userMenuTrigger');
  const userDropdown = document.getElementById('userDropdown');
  if (userBtn && userDropdown) {
    userBtn.addEventListener('click', e => {
      e.stopPropagation();
      userDropdown.classList.toggle('open');
    });
    document.addEventListener('click', () => userDropdown.classList.remove('open'));
  }

  // ── Filter form auto-submit on select change ──────────────
  const filterForm = document.getElementById('filterForm');
  if (filterForm) {
    filterForm.querySelectorAll('select').forEach(sel => {
      sel.addEventListener('change', () => filterForm.submit());
    });
  }

  // ── Toggle opts (radio buttons styled as button group) ────
  document.querySelectorAll('.toggle-opt input[type=radio]').forEach(radio => {
    radio.addEventListener('change', () => {
      document.querySelectorAll('.toggle-opt').forEach(opt => opt.classList.remove('sel'));
      radio.closest('.toggle-opt').classList.add('sel');
      if (filterForm) filterForm.submit();
    });
  });

  // ── Flash message auto-dismiss ────────────────────────────
  document.querySelectorAll('.flash').forEach(f => {
    setTimeout(() => f.remove(), 6000);
  });

  // ── Gallery thumbnail active state ────────────────────────
  document.querySelectorAll('.thumb').forEach(thumb => {
    thumb.addEventListener('click', () => {
      document.querySelectorAll('.thumb').forEach(t => t.style.borderColor = 'transparent');
      thumb.style.borderColor = 'var(--green-mid)';
    });
  });

});
