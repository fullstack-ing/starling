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
mix assets.setup     # Install Tailwind and esbuild if missing
mix assets.build     # Compile assets
mix assets.deploy    # Minify and digest assets for production
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

**Current State** (transitioning from defaults):
- Tailwind CSS v4 with DaisyUI components (planned migration to vanilla CSS + web components)
- ESBuild for JavaScript bundling
- Phoenix LiveView with colocated hooks pattern
- TypeScript configuration present (assets/tsconfig.json)

**Target State** (per AGENTS.md):
- Web Components via SSR Declarative Shadow DOM
- Vanilla CSS with proper encapsulation
- Separate asset pipelines: ESBuild for JS, Lightning CSS for styles
- Strategic use of Channels for real-time features (not LiveView by default)

### Asset Pipeline Configuration

The project uses Tailwind CSS v4 import syntax in `assets/css/app.css`:
```css
@import "tailwindcss" source(none);
@source "../css";
@source "../js";
@source "../../lib/starling_web";
```

Watchers run automatically in development:
- ESBuild watches JavaScript files
- Tailwind watches CSS files
- Phoenix LiveReload watches templates and static assets

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
2. **Avoid Tailwind classes in new components**: Plan migration path to vanilla CSS and web components
3. **Favor progressive enhancement**: Start with working HTML, enhance with JavaScript
4. **Use Phoenix Channels strategically**: Only for true real-time features, not as default

### HTTP Client

Use the included `:req` library for all HTTP requests. Avoid `:httpoison`, `:tesla`, and `:httpc`.

### Component Development

Current components use Tailwind/DaisyUI (see `lib/starling_web/components/core_components.ex`). The goal is to convert these to:
- Web components with Declarative Shadow DOM
- Baseline CSS styles without framework dependencies
- Server-side rendering capabilities maintained

Refer to AGENTS.md section "Component Strategy" for the conversion approach.

### Live Reload Integration

When modifying the build system (future Lightning CSS integration), ensure Phoenix's live reload is informed of file changes. The current configuration watches:
- Static assets: `priv/static/`
- Gettext translations: `priv/gettext/`
- Web modules: `lib/starling_web/` (controllers, live, components, router)

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
- Tailwind v4 uses new `@import` syntax (no tailwind.config.js)
- Never use `@apply` in raw CSS
- Router scopes include optional aliases - avoid duplicate prefixes
