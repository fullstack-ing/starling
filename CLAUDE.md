# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Starling** is a Phoenix 1.8 project that reimagines the Phoenix framework with a web standards-first approach. The project philosophy emphasizes progressive enhancement, web components via SSR Declarative Shadow DOM, and vanilla CSS over LiveView and Tailwind defaults.

See `AGENTS.md` for the complete project vision and philosophical foundation.

## Development Commands

### Initial Setup
```bash
mix setup  # Install deps, setup DB, setup and build assets
```

### Database
```bash
mix ecto.setup       # Create, migrate, and seed database
mix ecto.reset       # Drop and recreate database
mix ecto.create      # Create database only
mix ecto.migrate     # Run migrations
```

### Development Server
```bash
mix phx.server                    # Start Phoenix server
iex -S mix phx.server            # Start with interactive Elixir shell
docker compose up                # Start PostgreSQL database
```

The server runs at http://localhost:4000

### Testing
```bash
mix test                          # Run all tests
mix test test/path/to/test.exs   # Run specific test file
mix test --failed                # Run previously failed tests
```

### Asset Pipeline
```bash
mix assets.setup     # Install npm dependencies in assets folder
mix assets.build     # Build assets with source maps (development)
mix assets.deploy    # Build minified assets without source maps + digest (production)

# Or run directly in assets folder:
cd assets
npm install          # Install dependencies
npm run build        # Build assets once (with external source maps)
npm run watch        # Watch and rebuild on changes (inline source maps)
npm run deploy       # Build minified production assets (no source maps)
```

### Pre-commit Quality Checks
```bash
mix precommit  # Compile with warnings-as-errors, unlock unused deps, format, and test
```

**IMPORTANT**: Always run `mix precommit` when done with changes to ensure code quality.

## Architecture

### Application Structure

**Supervision Tree** (lib/starling/application.ex:10-18):
- Telemetry for metrics collection
- Ecto Repo for database access
- DNSCluster for service discovery
- PubSub for process communication
- Endpoint for HTTP request handling

**Web Layer** (StarlingWeb):
- Router defines URL routing with pipelines (`:browser`, `:api`)
- Controllers handle traditional HTTP requests (currently just PageController)
- Components provide reusable UI elements (CoreComponents)
- Layouts define page structure (root.html.heex)
- LiveView support included but not yet heavily utilized (aligns with project vision)

### Frontend Architecture

**Current State**:
- Native npm-based ESBuild for JavaScript bundling (no Mix wrapper)
- Lightning CSS for vanilla CSS processing with autoprefixing
- Phoenix LiveView disabled/commented out
- TypeScript configuration present (assets/tsconfig.json)
- Build process runs independently via Node.js
- Tailwind/DaisyUI completely removed

**Architecture** (aligns with AGENTS.md target):
- Web Components via SSR Declarative Shadow DOM (in progress)
- Vanilla CSS with proper encapsulation
- Separate asset pipelines: ESBuild for JS, Lightning CSS for styles ✓
- Strategic use of Channels for real-time features (not LiveView by default)

### Asset Pipeline Configuration

**Build System**:
- ESBuild for JavaScript bundling (native npm, no Mix wrapper)
- Lightning CSS for CSS processing with autoprefixing and modern CSS support
- Build script: `assets/build.js` - handles both JS and CSS compilation
- Package manager: npm with `assets/package.json`
- Outputs:
  - JavaScript: `priv/static/assets/js/app.js`
  - CSS: `priv/static/assets/css/app.css`

**Development Workflow**:
- Phoenix dev.exs watcher runs `npm run watch` automatically
- Build script watches both JS and CSS files
- ESBuild rebuilds on changes to `assets/js/**/*.js`
- Lightning CSS rebuilds on changes to `assets/css/**/*.css`
- Phoenix LiveReload monitors built assets via `phx-track-static` attributes
- Changes to `priv/static/assets/` trigger browser reload

**How Live Reload Works**:
1. Edit source file in `assets/js/` or `assets/css/`
2. Build script detects change and rebuilds (ESBuild for JS, Lightning CSS for CSS)
3. Phoenix LiveReload detects change to built file (via `phx-track-static` in layout)
4. Browser auto-reloads

**CSS Architecture**:
- Entry point: `assets/css/app.css`
- Lightning CSS provides:
  - Autoprefixing for browser compatibility
  - CSS bundling with `@import` support
  - Minification in production (`npm run deploy`)
  - Modern CSS syntax support (nesting, color functions, etc.)
  - Source maps in development (external `.css.map` files)

**Source Maps**:
- **Watch mode** (`npm run watch`): Inline source maps for JS, external for CSS
- **Build mode** (`npm run build`): External source maps for both JS and CSS (`.js.map`, `.css.map`)
- **Deploy mode** (`npm run deploy`): No source maps, minified output for production

### Database

**PostgreSQL** via Docker Compose:
- Development DB: `starling_dev` (port 5432)
- Test DB: `starling_test` (with MIX_TEST_PARTITION support)
- Credentials: postgres/postgres (dev), trust auth method

Ecto is configured with:
- Repo: `Starling.Repo`
- Migrations: `priv/repo/migrations/`
- Seeds: `priv/repo/seeds.exs`

## Project-Specific Guidelines

### Philosophy Alignment

This project deliberately moves away from Phoenix's LiveView-first and Tailwind-heavy defaults. When adding features:

1. **Question LiveView usage**: Consider if a traditional controller + JSON endpoint would suffice
2. **Use vanilla CSS and web components**: Tailwind/DaisyUI have been removed from the build
3. **Favor progressive enhancement**: Start with working HTML, enhance with JavaScript
4. **Use Phoenix Channels strategically**: Only for true real-time features, not as default

### HTTP Client

Use the included `:req` library for all HTTP requests. Avoid `:httpoison`, `:tesla`, and `:httpc`.

### CSS Architecture

The project uses a **layered CSS architecture** with design tokens and semantic composition, inspired by Kelp UI but adapted for our needs.

**Philosophy**:
- **Semantic class names** in HTML (`.site-nav`, `.button-primary`)
- **Design tokens** for consistent styling (`--color-primary-500`, `--space-md`)
- **Composition** over utility classes - components compose from reusable patterns
- **Modern CSS** features: nesting, layers, custom properties, container queries

**File Structure**:
```
assets/css/
├── layers.css                 # Cascade layer definitions
├── tokens/                    # Design system variables
│   ├── colors.css            # Color palette
│   ├── spacing.css           # Spacing scale
│   ├── typography.css        # Font families, sizes, weights
│   ├── sizing.css            # Border radius, shadows, z-index
│   └── breakpoints.css       # Media query breakpoints
├── base/                      # Foundation styles
│   ├── reset.css             # Modern CSS reset
│   └── elements.css          # Styled HTML elements
├── utilities/                 # Reusable patterns (for composition, not HTML)
│   ├── layout.css            # Layout patterns (:container, :stack, :grid)
│   └── patterns.css          # Common patterns (:focus-ring, :surface)
├── components/                # Semantic component styles
│   ├── navigation.css
│   ├── buttons.css
│   ├── forms.css
│   └── ...
└── app.css                    # Main stylesheet (imports everything)
```

**Cascade Layers** (lowest to highest priority):
1. `reset` - CSS reset
2. `tokens` - Design system variables
3. `base` - Base HTML element styles
4. `utilities` - Reusable patterns
5. `components` - Component styles
6. `overrides` - Project-specific overrides

**Using Design Tokens**:
```css
.my-component {
  color: var(--color-text-primary);
  padding: var(--space-md);
  border-radius: var(--radius-lg);
  font-size: var(--text-base);
}
```

**Composing from Utilities** (using CSS nesting):
```css
.my-component {
  /* Use utility patterns as building blocks */
  display: flex;
  flex-direction: column;
  gap: var(--space-md);

  & > * + * {
    /* Stack pattern */
    margin-top: var(--space-md);
  }

  &:focus-visible {
    /* Focus ring pattern */
    outline: var(--focus-ring-width) solid var(--focus-ring-color);
    outline-offset: var(--focus-ring-offset);
  }
}
```

**Modern CSS Support** (via Lightning CSS):
- CSS nesting (native syntax)
- Custom properties (CSS variables)
- `color-mix()` for transparency
- Container queries
- Modern selectors (`:has()`, `:is()`, `:where()`)
- Autoprefixing for browser compatibility
- `@layer` for cascade management

**Migration Status**:
- ✅ Architecture established with layers and tokens
- ✅ Base styles and reset complete
- ✅ Flash component converted to Declarative Shadow DOM web component
- ⏳ Other components need migration to new system
- ⏳ User auth templates still contain old classes

Refer to AGENTS.md section "Component Strategy" for the complete approach.

### Web Components Pattern Selection

The project uses **two patterns for web components** depending on the use case:

**Quick Reference**:

| Aspect | Light DOM (Default) | Shadow DOM (SEO Content) |
|--------|---------------------|--------------------------|
| **Use for** | Interactive UI components | Content that needs SEO |
| **Examples** | Flash, modals, tabs, forms | Blog posts, articles, products |
| **Styling** | External CSS + design tokens | Embedded `<style>` in template |
| **Theming** | ✅ Full design token support | ⚠️ Tokens inherit but optional |
| **Complexity** | ✅ Simple, maintainable | ⚠️ More complex |
| **SEO** | ✅ Good for UI | ✅ Critical for content |
| **When to use** | Default choice | Only when SEO matters |

---

### 1. Light DOM Pattern (Default for UI Components)

**Use for**: Interactive UI components (flash messages, modals, tabs, dropdowns, tooltips)

Inspired by [Kelp UI](https://github.com/cferdinandi/kelp), this is our **default pattern** for most components.

**Why Light DOM for UI components?**:
- ✅ **Design tokens accessible**: CSS custom properties inherit naturally
- ✅ **DRY CSS**: No hardcoded values, all styles use design tokens
- ✅ **Simpler architecture**: No shadow boundary complexity
- ✅ **Maintainable**: Change theme in one place, all components update
- ✅ **Progressive enhancement**: JavaScript optional for core functionality
- ✅ **CSS Layers for encapsulation**: Predictable cascade without shadow DOM

### 2. Declarative Shadow DOM (For SEO-Critical Content)

**Use for**: Content that needs to be crawled by search engines (blog posts, articles, product descriptions)

**Why Shadow DOM for content components?**:
- ✅ **SEO-critical content**: Search engines can index content in shadow DOM
- ✅ **Content encapsulation**: Prevents page styles from affecting article content
- ✅ **SSR compatible**: Content rendered server-side, no FOUC
- ✅ **Portable**: Article styles travel with the content

**When to use each pattern**:

| Pattern | Use For | Examples |
|---------|---------|----------|
| **Light DOM** | Interactive UI components | Flash messages, modals, tabs, dropdowns, forms |
| **Shadow DOM** | SEO content components | Blog posts, articles, product cards, content blocks |

**Rule of thumb**: If the component contains content that should be indexed by search engines (titles, body text, product descriptions), use Declarative Shadow DOM. For everything else, use Light DOM with design tokens.

---

## Light DOM Pattern (Default)

**Architecture**:
1. **HEEx template** renders semantic HTML inside `<custom-element>` tags
2. **External CSS** styles custom elements using design tokens
3. **CSS Layers** provide cascade control and "soft encapsulation"
4. **JavaScript** (optional) adds progressive enhancement
5. **Attribute-based state** (e.g., `data-kind="info"`) for variants

**Example Pattern** (Flash Component):

```heex
<!-- lib/starling_web/components/flash_component.ex -->
<flash-message data-kind={@kind} role="alert">
  <span class="flash-icon">ℹ</span>
  <div class="flash-content">
    <p class="flash-message">{@message}</p>
  </div>
  <button class="flash-close">×</button>
</flash-message>
```

```css
/* assets/css/components/flash.css */
@layer components {
  flash-message {
    display: flex;
    gap: var(--space-3);
    padding: var(--space-4);
    background-color: var(--color-surface-primary);
    border-radius: var(--radius-md);
  }

  flash-message[data-kind="info"] {
    border-left-color: var(--color-primary-500);
    background-color: var(--color-primary-50);
  }

  .flash-close {
    color: var(--color-text-secondary);
    transition: color var(--transition-fast);
  }
}
```

**JavaScript Enhancement** (`assets/js/components/flash-message.js`):
```javascript
// Progressive enhancement - component works without this!
export function initFlashMessages() {
  document.querySelectorAll("flash-message").forEach((flash) => {
    // Query light DOM directly
    const closeBtn = flash.querySelector(".flash-close");
    closeBtn?.addEventListener("click", () => dismissFlash(flash));
  });
}
```

**Key Benefits**:
- 🎨 **All colors/spacing/typography use design tokens** - change theme in one place
- 📦 **Styles live in CSS files** - not embedded in templates
- 🔄 **CSS hot reload works** - change styles without reloading components
- 🎯 **Specificity managed by layers** - predictable cascade order
- ♿ **Accessibility simpler** - no shadow boundary ARIA complications

**File Organization**:
```
lib/starling_web/components/
├── core_components.ex          # Main component module (delegates to others)
└── flash_component.ex          # Flash message web component

assets/
├── css/
│   ├── tokens/                 # Design system tokens
│   └── components/
│       └── flash.css          # All flash styles using tokens
└── js/components/
    └── flash-message.js       # Progressive enhancement
```

**Component Module Pattern**:

Extract web components to separate files to keep `core_components.ex` manageable:

```elixir
# lib/starling_web/components/flash_component.ex
defmodule StarlingWeb.FlashComponent do
  use Phoenix.Component
  use Gettext, backend: StarlingWeb.Gettext

  def flash(assigns) do
    ~H"""
    <flash-message data-kind={@kind} role="alert">
      <span class="flash-icon"><!-- icon --></span>
      <div class="flash-content">
        <p class="flash-message">{@message}</p>
      </div>
      <button class="flash-close">×</button>
    </flash-message>
    """
  end
end

# lib/starling_web/components/core_components.ex
defmodule StarlingWeb.CoreComponents do
  # Delegate to separate component modules
  defdelegate flash(assigns), to: StarlingWeb.FlashComponent

  # Other components...
end
```

**Migration Checklist** for creating web components:
1. ✅ Create `lib/starling_web/components/{component}_component.ex`
2. ✅ Use custom element tag (`<flash-message>`, `<modal-dialog>`, etc.)
3. ✅ Create semantic HTML structure with BEM-style classes (`flash-icon`, `flash-content`)
4. ✅ Create CSS file in `assets/css/components/{component}.css`
5. ✅ Use `@layer components` in CSS file
6. ✅ Style using design tokens only (no hardcoded colors/spacing)
7. ✅ Use attribute selectors for variants (`[data-kind="info"]`, `[aria-selected]`)
8. ✅ Create optional JS file in `assets/js/components/{component}.js`
9. ✅ Import CSS in `app.css` and JS in `app.js`
10. ✅ Add `defdelegate` in `core_components.ex`
11. ✅ Test without JS - component should display correctly

**Styling Guidelines**:
- Target custom elements: `flash-message { /* styles */ }`
- Use attribute selectors for state: `flash-message[data-kind="info"]`
- Descendant selectors for children: `flash-message .flash-close`
- Always use design tokens: `var(--color-primary-500)` not `#0066cc`
- Group related properties with CSS comments

---

## Declarative Shadow DOM Pattern (SEO Content)

**Architecture**:
1. **HEEx template** renders `<custom-element>` with `<template shadowrootmode="open">`
2. **Styles** embedded in `<style>` tag inside shadow root
3. **Content** (titles, body text) rendered server-side for SEO
4. **JavaScript** (optional) adds progressive enhancement

**Example Pattern** (Blog Post Component):

```heex
<!-- lib/starling_web/components/blog_post_component.ex -->
<blog-post data-category={@category}>
  <template shadowrootmode="open">
    <style>
      /* Scoped styles that won't leak or be affected by page CSS */
      article {
        max-width: 65ch;
        margin: 0 auto;
        font-family: Georgia, serif;
        line-height: 1.6;
      }

      h1 {
        font-size: 2.5rem;
        font-weight: 700;
        margin-bottom: 1rem;
        color: #1a1a1a;
      }

      .post-meta {
        color: #666;
        font-size: 0.875rem;
        margin-bottom: 2rem;
      }

      .post-content {
        font-size: 1.125rem;
      }

      /* Dark mode */
      @media (prefers-color-scheme: dark) {
        h1 { color: #f0f0f0; }
        .post-meta { color: #999; }
      }
    </style>

    <article>
      <h1>{@title}</h1>
      <div class="post-meta">
        <time datetime={@published_at}>{format_date(@published_at)}</time>
        <span> · </span>
        <span>{@read_time} min read</span>
      </div>
      <div class="post-content">
        {raw(@body_html)}
      </div>
    </article>
  </template>
</blog-post>
```

**Key Differences from Light DOM**:
- ✅ **SEO-friendly**: Search engines index content in `<template shadowrootmode="open">`
- ✅ **Style isolation**: Page CSS won't interfere with article typography
- ✅ **Content-specific styles**: Typography/layout specific to this content type
- ⚠️ **Hardcoded styles acceptable**: Since content components aren't themed
- ⚠️ **Complexity trade-off**: Use only when SEO is critical

**Note on Theming Shadow DOM Components**:

CSS custom properties (design tokens) **DO inherit** through shadow boundaries. If you need theming support in a Shadow DOM component, you can reference tokens:

```css
/* Inside shadow DOM <style> tag */
h1 {
  color: var(--color-text-primary); /* ✅ Inherits from light DOM */
  font-family: var(--font-sans);    /* ✅ Works! */
}
```

However, this creates dependency on external tokens being defined. For pure content components, hardcoded values are often simpler and more portable.

**When to Use Shadow DOM**:
- Blog posts with titles, body content, metadata
- Article previews/cards with excerpts
- Product descriptions that need SEO
- Any content where search ranking matters

**When NOT to Use Shadow DOM**:
- Interactive UI components (use Light DOM + design tokens)
- Components that need theming (use Light DOM + design tokens)
- Simple components without SEO needs (use Light DOM)

**File Organization for Shadow DOM Components**:
```
lib/starling_web/components/
└── blog_post_component.ex     # DSD component with embedded styles

assets/
└── css/components/
    └── blog-post.css          # Optional: Light DOM positioning only
```

**Migration Checklist** for SEO content components:
1. ✅ Identify content that needs SEO (titles, descriptions, body text)
2. ✅ Create `lib/starling_web/components/{component}_component.ex`
3. ✅ Use custom element tag (`<blog-post>`, `<article-card>`, etc.)
4. ✅ Add `<template shadowrootmode="open">` wrapper
5. ✅ Embed content-specific styles in `<style>` tag
6. ✅ Render semantic HTML inside shadow root
7. ✅ Use hardcoded styles (or CSS custom properties if theming needed)
8. ✅ Keep light DOM CSS minimal (positioning/layout only)
9. ✅ Test that content is visible without JS
10. ✅ Verify search engines can index the content

### Build System & Live Reload

**Asset Build**: npm-based build system (configured in `assets/build.js`)
- ESBuild for JavaScript bundling
- Lightning CSS for CSS processing ✓
- Phoenix watcher in dev.exs runs `npm run watch` in assets folder
- Single build script handles both JS and CSS compilation
- Layouts use `phx-track-static` attributes for automatic browser reload

**Adding New CSS Files**:
- Create CSS files in `assets/css/`
- Import them in `assets/css/app.css` with `@import "./path/to/file.css"`
- Lightning CSS will bundle them automatically
- Organized by component: `assets/css/components/buttons.css`, etc.

**Phoenix LiveReload watches**:
- Built static assets: `priv/static/assets/` (via phx-track-static)
- Templates: `lib/starling_web/` (.ex, .heex files)
- Translations: `priv/gettext/`

### Comprehensive Guidelines

**IMPORTANT**: The AGENTS.md file contains extensive Phoenix, Elixir, Ecto, LiveView, and HTML guidelines (lines 130-462). Always reference these guidelines when working with:
- Elixir language features and idioms
- Phoenix routing, controllers, and components
- Ecto schemas, changesets, and queries
- LiveView streams, forms, and testing
- HEEx template syntax and best practices

Key highlights from AGENTS.md:
- Elixir lists don't support index-based access syntax (`list[i]` is invalid)
- Always use `to_form/2` for forms, never raw changesets in templates
- Use LiveView streams for collections to avoid memory issues
- Router scopes include optional aliases - avoid duplicate prefixes
- Never use `@apply` in CSS (general best practice)
- HEEx templates use `{...}` for attribute interpolation, `<%= %>` for body content
