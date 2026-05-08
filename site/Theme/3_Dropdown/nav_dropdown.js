/**
 * nav_dropdown.js — version body-attached
 * Le dropdown est injecté dans <body> pour échapper aux transformations
 * CSS de Material Theme qui cassent position:fixed.
 */
document.addEventListener('DOMContentLoaded', function () {

  /* ── 1. Trouver l'onglet "Projet Simulateur" ─────────────── */
  const tabs = document.querySelectorAll('.md-tabs__link');
  let simTab = null;
  tabs.forEach(function (t) {
    if (t.textContent.trim() === 'Simulator Project') simTab = t;
  });
  if (!simTab) return;

  const tabItem = simTab.closest('.md-tabs__item');

  /* ── 2. Construire le dropdown ───────────────────────────── */
const tabHref = simTab.href;

// Extrait la racine du projet : tout ce qui est avant "Projet_Simulateur/"
const projectRoot = tabHref.substring(0, tabHref.indexOf('Projet_Simulateur/') + 'Projet_Simulateur/'.length);
// → "https://ton-site/.../Projects/Projet_Simulateur/"

const items = [
  { label:'Présentation',           href: projectRoot + 'index_4WS_Simu/' },
  { label:'Theory',                 href: projectRoot + 'Theory/1_Simulator_Overview/' },
  { label:'Implementation',         href: projectRoot + 'Implementation/1_Parameters_Launch/' },
  { label:'Results',                href: projectRoot + 'index_Results_4WS_Simu/' }
];

  const dropdown = document.createElement('div');
  dropdown.className = 'nav-dropdown';

  items.forEach(function (item, idx) {
    const a = document.createElement('a');
    a.href = item.href;
    a.className = 'nav-dropdown__item';
    a.innerHTML = '<span>' + item.label + '</span>';
    dropdown.appendChild(a);

    if (idx < items.length - 1) {
      const div = document.createElement('div');
      div.className = 'nav-dropdown__divider';
      dropdown.appendChild(div);
    }
  });

  /* ── 3. Injecter dans BODY (pas dans la nav) ─────────────── */
  document.body.appendChild(dropdown);

  /* ── 4. Logique de hover avec délai de grâce ─────────────── */
  let hideTimer = null;

  function show() {
    clearTimeout(hideTimer);
    const r = tabItem.getBoundingClientRect();
    dropdown.style.top  = r.bottom + 'px';
    dropdown.style.left = (r.left + r.width / 2) + 'px';
    dropdown.classList.add('is-visible');
  }
  function hide() {
    hideTimer = setTimeout(function () {
      dropdown.classList.remove('is-visible');
    }, 180);
  }

  tabItem.addEventListener('mouseenter', show);
  tabItem.addEventListener('mouseleave', hide);
  dropdown.addEventListener('mouseenter', function () { clearTimeout(hideTimer); });
  dropdown.addEventListener('mouseleave', hide);

  /* Repositionner si scroll/resize pendant qu'il est ouvert */
  window.addEventListener('scroll', function () {
    if (dropdown.classList.contains('is-visible')) show();
  }, { passive: true });
  window.addEventListener('resize', function () {
    if (dropdown.classList.contains('is-visible')) show();
  });
});
