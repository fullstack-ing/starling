# Theme Toggle

A web component-based theme toggle that allows users to cycle through light, dark, and system theme preferences.

## Features

- **Three Theme Options:**
  - 🌞 **Light**: Force light mode
  - 🌙 **Dark**: Force dark mode
  - 💻 **System**: Follow OS preference (default)

- **Persistent State**: Theme preference saved to localStorage
- **Cross-tab Sync**: Theme changes sync across open tabs
- **Smooth Transitions**: Icon changes with smooth visual feedback
- **Accessible**: Proper ARIA labels and keyboard navigation

## How It Works

### 1. Web Component (`theme-toggle`)

Location: `/assets/js/theme_toggle.js`

Custom element that:
- Renders a button with theme-appropriate icon
- Cycles through themes on click: system → light → dark → system
- Updates localStorage and dispatches events
- Syncs across tabs via storage events

### 2. Theme Script

Location: `/lib/starling_web/components/layouts/root.html.heex`

Inline script that:
- Initializes theme on page load (before flash of wrong theme)
- Listens for `phx:set-theme` events from the toggle
- Applies `data-theme` attribute to `<html>` element
- Syncs with localStorage

### 3. CSS Integration

Your CSS can target themes using:

```css
/* Light mode (default) */
.my-element {
  background: white;
}

/* Dark mode via media query */
@media (prefers-color-scheme: dark) {
  .my-element {
    background: black;
  }
}

/* Dark mode via data attribute (overrides system preference) */
[data-theme="dark"] .my-element {
  background: black;
}

/* Light mode via data attribute (overrides system preference) */
[data-theme="light"] .my-element {
  background: white;
}
```

## Usage

The theme toggle is automatically included in:

**Desktop Navigation:**
```heex
<div class="nav-right">
  <theme-toggle></theme-toggle>
  <!-- notification and profile buttons -->
</div>
```

**Mobile Navigation:**
```heex
<div class="nav-mobile-theme">
  <span class="nav-mobile-theme-label">Theme</span>
  <theme-toggle></theme-toggle>
</div>
```

## Theme States

### 1. System (Default)
- No `data-theme` attribute on `<html>`
- Nothing in localStorage
- Respects `@media (prefers-color-scheme: dark)`
- Icon: 💻 Computer/monitor

### 2. Light Mode
- `data-theme="light"` on `<html>`
- `localStorage['phx:theme'] = 'light'`
- Overrides system dark mode
- Icon: 🌞 Sun

### 3. Dark Mode
- `data-theme="dark"` on `<html>`
- `localStorage['phx:theme'] = 'dark'`
- Overrides system light mode
- Icon: 🌙 Moon

## Event Flow

```
User clicks toggle
    ↓
Web component updates icon
    ↓
Dispatches 'phx:set-theme' event
    ↓
Theme script receives event
    ↓
Updates localStorage
    ↓
Sets data-theme attribute
    ↓
CSS applies theme styles
    ↓
Storage event fires
    ↓
Other tabs sync theme
```

## Styling the Toggle

The toggle button styles match the navigation pattern:

```css
.theme-toggle {
  /* Round button with icon */
  padding: var(--space-1);
  border-radius: var(--radius-full);
  color: var(--color-gray-400);

  /* Hover effect */
  &:hover {
    background: rgba(255, 255, 255, 0.05);
    color: white;
  }

  /* Focus ring */
  &:focus-visible {
    outline: 2px solid var(--color-primary-500);
  }
}
```

## Browser Support

- **Web Components**: All modern browsers (Chrome, Firefox, Safari, Edge)
- **LocalStorage**: Universal support
- **Storage Events**: Universal support for cross-tab sync
- **Prefers Color Scheme**: All modern browsers

## Adding to New Layouts

To add the theme toggle to other parts of your app:

1. **Add the component:**
   ```heex
   <theme-toggle></theme-toggle>
   ```

2. **Ensure theme script is loaded:**
   The script in `root.html.heex` runs on every page automatically.

3. **Style as needed:**
   Add custom CSS for positioning/sizing in your layout.

## Testing

Test the theme toggle:

1. **Toggle functionality:**
   - Click button to cycle: system → light → dark → system
   - Icon should change immediately
   - Page theme should update

2. **Persistence:**
   - Set to "light", refresh page
   - Should remain in light mode

3. **Cross-tab sync:**
   - Open two tabs
   - Change theme in one tab
   - Other tab should update automatically

4. **System preference:**
   - Set to "system"
   - Change OS theme setting
   - Page should follow OS preference

## Files

- **Component:** `assets/js/theme_toggle.js`
- **Theme script:** `lib/starling_web/components/layouts/root.html.heex`
- **Styles:** `assets/css/components/navigation.css`
- **Integration:** `lib/starling_web/components/layouts.ex`
