const divider = document.querySelector('.mountains-divider');
const heroContent = document.querySelector('.hero-content'); // ← ajout

if (divider) {
  const layers = [
    { el: divider.querySelectorAll('.m1'), offset: 0   },
    { el: divider.querySelectorAll('.m2'), offset: 60  },
    { el: divider.querySelectorAll('.m3'), offset: 120 },
  ];

  const lerp = (a, b, t) => a + (b - a) * Math.max(0, Math.min(1, t));

  function update() {
    const rect     = divider.getBoundingClientRect();
    const vh       = window.innerHeight;
    const progress = (vh - rect.top - 200) / 100;

    // Montagnes qui apparaissent
    layers.forEach(({ el, offset }) => {
      const p = Math.max(0, Math.min(1, (progress * 100 - offset) / 200));
      el.forEach(e => {
        e.style.opacity   = lerp(0, 1, p);
        e.style.transform = `translateY(${lerp(30, 0, p)}px)`;
      });
    });

    // Texte hero qui disparaît en même temps
    if (heroContent) {
      const p = Math.max(0, Math.min(1, progress * 2));
      heroContent.style.opacity   = lerp(1, 0, p);
      heroContent.style.transform = `translateY(${lerp(0, -20, p)}px)`;
    }
  }

  window.addEventListener('scroll', update);
  update();
}

// Animation des feature cards au scroll
const cards = document.querySelectorAll('.feature-card');
if (cards.length > 0) {
  const cardObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        // Délai en cascade basé sur la position dans la grille
        const index = Array.from(cards).indexOf(entry.target);
        const delay = (index % 3) * 150; // 150ms entre chaque colonne
        setTimeout(() => {
          entry.target.classList.add('visible');
        }, delay);
        cardObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.2 });

  cards.forEach(card => cardObserver.observe(card));
}

// Animation des project cards au scroll
const projCards = document.querySelectorAll('.proj-card');
if (projCards.length > 0) {
  const projObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const index = Array.from(projCards).indexOf(entry.target);
        setTimeout(() => {
          entry.target.classList.add('visible');
        }, index * 120); // ← 120ms de délai entre chaque card
        projObserver.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  projCards.forEach(card => projObserver.observe(card));
}