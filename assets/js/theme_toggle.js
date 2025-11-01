/**
 * Theme Toggle Web Component
 *
 * Cycles through theme preferences: system → light → dark → system
 * Syncs with localStorage and dispatches events for the theme script.
 */
class ThemeToggle extends HTMLElement {
  constructor() {
    super();
    this.themes = ['system', 'light', 'dark'];
  }

  connectedCallback() {
    this.currentTheme = this.getCurrentTheme();
    this.render();
    this.attachEventListeners();

    // Listen for storage changes from other tabs
    window.addEventListener('storage', (e) => {
      if (e.key === 'phx:theme') {
        this.currentTheme = e.newValue || 'system';
        this.updateIcon();
      }
    });
  }

  getCurrentTheme() {
    const stored = localStorage.getItem('phx:theme');
    return stored || 'system';
  }

  getNextTheme() {
    const currentIndex = this.themes.indexOf(this.currentTheme);
    const nextIndex = (currentIndex + 1) % this.themes.length;
    return this.themes[nextIndex];
  }

  getThemeIcon(theme) {
    const icons = {
      light: `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
          <path d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      `,
      dark: `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
          <path d="M21.752 15.002A9.72 9.72 0 0 1 18 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0 0 3 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 0 0 9.002-5.998Z" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      `,
      system: `
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
          <path d="M9 17.25v1.007a3 3 0 0 1-.879 2.122L7.5 21h9l-.621-.621A3 3 0 0 1 15 18.257V17.25m6-12V15a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 15V5.25m18 0A2.25 2.25 0 0 0 18.75 3H5.25A2.25 2.25 0 0 0 3 5.25m18 0V12a2.25 2.25 0 0 1-2.25 2.25H5.25A2.25 2.25 0 0 1 3 12V5.25" stroke-linecap="round" stroke-linejoin="round" />
        </svg>
      `
    };
    return icons[theme];
  }

  getThemeLabel(theme) {
    const labels = {
      light: 'Light',
      dark: 'Dark',
      system: 'System'
    };
    return labels[theme];
  }

  render() {
    const label = this.getThemeLabel(this.currentTheme);
    const icon = this.getThemeIcon(this.currentTheme);

    this.innerHTML = `
      <button
        type="button"
        class="theme-toggle"
        aria-label="Toggle theme (current: ${label})"
        title="Current theme: ${label}"
      >
        <span class="theme-toggle-inset"></span>
        <span class="theme-toggle-icon">${icon}</span>
      </button>
    `;
  }

  updateIcon() {
    const iconContainer = this.querySelector('.theme-toggle-icon');
    const button = this.querySelector('button');
    const label = this.getThemeLabel(this.currentTheme);

    if (iconContainer) {
      iconContainer.innerHTML = this.getThemeIcon(this.currentTheme);
    }
    if (button) {
      button.setAttribute('aria-label', `Toggle theme (current: ${label})`);
      button.setAttribute('title', `Current theme: ${label}`);
    }
  }

  attachEventListeners() {
    const button = this.querySelector('button');
    button.addEventListener('click', () => this.toggleTheme());
  }

  toggleTheme() {
    const nextTheme = this.getNextTheme();
    this.currentTheme = nextTheme;

    // Update the icon immediately for visual feedback
    this.updateIcon();

    // Dispatch the theme change event
    window.dispatchEvent(new CustomEvent('phx:set-theme', {
      detail: { theme: nextTheme },
      target: { dataset: { phxTheme: nextTheme } }
    }));
  }
}

customElements.define('theme-toggle', ThemeToggle);
