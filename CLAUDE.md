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

### Component Development

The project has transitioned away from Tailwind/DaisyUI. When building new components:
- Use vanilla CSS for styling
- Target web components with Declarative Shadow DOM (see AGENTS.md)
- Maintain server-side rendering capabilities with Phoenix function components
- Existing core_components.ex will need CSS migration from Tailwind classes

Refer to AGENTS.md section "Component Strategy" for the complete approach.

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
