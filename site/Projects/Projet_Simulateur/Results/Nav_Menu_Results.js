/* ============================================================
   nav_pills.js
   Composant : Navigation flottante en pills (gauche)
   avec dots expand pour les sous-tests
   ============================================================
   Usage :
     NavPills.init(options) après que le DOM est chargé.

   Configuration via NavPills.init(options) :

     sections  {string}  Sélecteur CSS des sections de niveau.
                         Défaut : '.result-section'

     tests     {string}  Sélecteur CSS des cartes de test
                         DANS chaque section de niveau.
                         Défaut : '.result-card'

     container {string}  Où insérer le nav dans le DOM.
                         Défaut : 'body'

     labels    {object}  { sectionId: 'Label pill' }
                         Si absent, l'id de la section est utilisé.

     testLabels {object} { cardId: 'Label tooltip dot' }
                         Si une carte n'a pas d'id, son index est utilisé.
                         Optionnel — le tooltip affiche l'id ou l'index
                         si aucun label n'est fourni.

   Exemple complet (Results.html) :
     NavPills.init({
       sections   : '.result-section',
       tests      : '.result-card',
       labels     : {
         'intro'     : 'Intro',
         'niveau-1'  : 'L1',
         'niveau-2'  : 'L2',
         'niveau-3'  : 'L3',
         'conclusion': 'Fin',
       },
       testLabels : {
         'test-1-1' : '1.1',
         'test-1-2' : '1.2',
       }
     });

   Note : les cartes n'ont pas besoin d'un id pour fonctionner.
   Si elles n'en ont pas, le dot est quand même créé et cliquable —
   le tooltip affichera simplement l'index (ex: "Test 1").
   ============================================================ */

(function (global) {
  'use strict';

  const NavPills = {

    _groups    : [],   /* { pill, dotsRow, section, cards, dots } */
    _observer  : null,
    _cardObs   : null,
    _container : null,


    /* ── Point d'entrée ── */
    init(options) {
      const opts = Object.assign({
        sections   : '.result-section',
        tests      : '.result-card',
        container  : 'body',
        labels     : {},
        testLabels : {}
      }, options || {});

      const sections = Array.from(
        document.querySelectorAll(opts.sections)
      ).filter(s => s.id);

      if (sections.length === 0) return;

      this._container = this._buildDOM(sections, opts);

      const parent = document.querySelector(opts.container) || document.body;
      parent.appendChild(this._container);

      this._observeSections(sections);
      this._observeCards();
      this._hookCursor();
    },


    /* ── Construction du DOM ── */
    _buildDOM(sections, opts) {
      const nav = document.createElement('nav');
      nav.className = 'nav-pills';
      nav.setAttribute('aria-label', 'Navigation rapide');

      sections.forEach(section => {
        const id    = section.id;
        const label = opts.labels[id] || id;
        const cards = Array.from(section.querySelectorAll(opts.tests));

        /* Groupe pill + dots */
        const group = document.createElement('div');
        group.className = 'nav-pill-group';

        /* Pill niveau */
        const pill = document.createElement('button');
        pill.className  = 'nav-pill';
        pill.textContent = label;
        pill.setAttribute('aria-label', `Aller à : ${label}`);
        pill.addEventListener('click', () => {
          section.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });

        group.appendChild(pill);

        /* Rangée de dots (seulement si des cartes existent) */
        let dotsRow = null;
        const dots  = [];

        if (cards.length > 0) {
          dotsRow = document.createElement('div');
          dotsRow.className = 'nav-pill-dots';

          cards.forEach((card, i) => {
            const cardId    = card.id || null;
            const dotLabel  = cardId
              ? (opts.testLabels[cardId] || cardId)
              : (opts.testLabels[i]     || `Test ${i + 1}`);

            const dot = document.createElement('button');
            dot.className        = 'nav-dot';
            dot.dataset.label    = dotLabel;
            dot.setAttribute('aria-label', `Aller au test : ${dotLabel}`);
            dot.addEventListener('click', () => {
              card.scrollIntoView({ behavior: 'smooth', block: 'start' });
            });

            dots.push({ dot, card });
            dotsRow.appendChild(dot);
          });

          group.appendChild(dotsRow);
        }

        nav.appendChild(group);

        this._groups.push({ pill, dotsRow, group, section, cards, dots });
      });

      return nav;
    },


    /* ── Observer les sections (pour la pill active) ── */
    _observeSections(sections) {
      this._observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          const id = entry.target.id;
          this._groups.forEach(g => {
            const match = g.section.id === id;
            g.pill.classList.toggle('is-active', match);
            if (g.dotsRow) {
              g.group.classList.toggle('is-open', match);
            }
          });
        });
      }, {
        rootMargin : '-35% 0px -55% 0px',
        threshold  : 0
      });

      sections.forEach(s => this._observer.observe(s));
    },


    /* ── Observer les cartes (pour le dot actif) ── */
    _observeCards() {
      this._cardObs = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (!entry.isIntersecting) return;
          /* Trouver le groupe parent */
          this._groups.forEach(g => {
            g.dots.forEach(({ dot, card }) => {
              if (card === entry.target) {
                /* Désactiver tous les dots du groupe, activer celui-ci */
                g.dots.forEach(d => d.dot.classList.remove('is-active'));
                dot.classList.add('is-active');
              }
            });
          });
        });
      }, {
        rootMargin : '-20% 0px -70% 0px',
        threshold  : 0
      });

      this._groups.forEach(g => {
        g.cards.forEach(card => this._cardObs.observe(card));
      });
    },


    /* ── Compatibilité curseur custom ── */
    _hookCursor() {
      const ring = document.getElementById('cursorRing');
      if (!ring) return;

      const allInteractive = this._container.querySelectorAll('.nav-pill, .nav-dot');
      allInteractive.forEach(el => {
        el.addEventListener('mouseenter', () => {
          ring.style.width       = '48px';
          ring.style.height      = '48px';
          ring.style.borderColor = 'rgba(0,229,204,0.6)';
        });
        el.addEventListener('mouseleave', () => {
          ring.style.width       = '30px';
          ring.style.height      = '30px';
          ring.style.borderColor = 'rgba(255,0,204,0.5)';
        });
      });
    },


    /* ── Nettoyage ── */
    destroy() {
      if (this._observer)  this._observer.disconnect();
      if (this._cardObs)   this._cardObs.disconnect();
      if (this._container) this._container.remove();
      this._groups = [];
    }
  };

  global.NavPills = NavPills;

})(window);
