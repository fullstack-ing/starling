defmodule StarlingWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use StarlingWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true
  slot :admin_bar

  def app(assigns) do
    ~H"""
    <header class="site-header">
      <nav class="site-nav">
        <div class="nav-container">
          <div class="nav-content">
            <div class="mobile-menu-button">
              <button
                type="button"
                command="--toggle"
                commandfor="mobile-menu"
                class="nav-toggle"
              >
                <span class="nav-toggle-inset"></span>
                <span class="sr-only">Open main menu</span>
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="1.5"
                  aria-hidden="true"
                  class="nav-icon nav-icon-menu in-aria-expanded:hidden"
                >
                  <path
                    d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  />
                </svg>
                <svg
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  stroke-width="1.5"
                  aria-hidden="true"
                  class="nav-icon nav-icon-close not-in-aria-expanded:hidden"
                >
                  <path d="M6 18 18 6M6 6l12 12" stroke-linecap="round" stroke-linejoin="round" />
                </svg>
              </button>
            </div>
            <div class="nav-left">
              <div class="nav-logo">
                <.link href={~p"/"}>
                  <img
                    src={~p"/images/logo.svg"}
                    alt="Starling"
                    class="nav-logo-img"
                  />
                </.link>
              </div>
              <div class="nav-links-desktop">
                <div class="nav-links">
                  <.link href={~p"/"} class="nav-link nav-link-active" aria-current="page">
                    Home
                  </.link>
                  <.link href={~p"/posts"} class="nav-link nav-link-active" aria-current="page">
                    Posts
                  </.link>
                </div>
              </div>
            </div>
            <div class="nav-right">
              <theme-toggle></theme-toggle>
              <%= if @current_scope do %>
                <button type="button" class="nav-notification">
                  <span class="nav-notification-inset"></span>
                  <span class="sr-only">View notifications</span>
                  <svg
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    stroke-width="1.5"
                    aria-hidden="true"
                    class="nav-icon"
                  >
                    <path
                      d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0"
                      stroke-linecap="round"
                      stroke-linejoin="round"
                    />
                  </svg>
                </button>

                <el-dropdown class="nav-profile-dropdown">
                  <button class="nav-profile-button">
                    <span class="nav-profile-inset"></span>
                    <span class="sr-only">Open user menu</span>
                    <span class="nav-profile-avatar">{String.first(@current_scope.user.email)}</span>
                  </button>

                  <el-menu
                    anchor="bottom end"
                    popover
                    hidden
                    class="nav-dropdown-menu"
                  >
                    <span class="nav-dropdown-item nav-dropdown-item-email">
                      {@current_scope.user.email}
                    </span>
                    <.link href={~p"/users/settings"} class="nav-dropdown-item">
                      Settings
                    </.link>
                    <.link href={~p"/users/log-out"} method="delete" class="nav-dropdown-item">
                      Sign out
                    </.link>
                  </el-menu>
                </el-dropdown>
              <% else %>
                <div class="nav-auth-links">
                  <.link href={~p"/users/log-in"} class="nav-link">
                    Log in
                  </.link>
                  <.link href={~p"/users/register"} class="button button-primary">
                    Register
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <el-disclosure id="mobile-menu" hidden class="nav-mobile-menu">
          <div class="nav-mobile-content">
            <div class="nav-mobile-theme">
              <span class="nav-mobile-theme-label">Theme</span>
              <theme-toggle></theme-toggle>
            </div>
            <%= if @current_scope do %>
              <.link href={~p"/"} class="nav-mobile-link nav-mobile-link-active" aria-current="page">
                Home
              </.link>
              <.link
                href={~p"/posts"}
                class="nav-mobile-link nav-mobile-link-active"
                aria-current="page"
              >
                Posts
              </.link>
              <.link href={~p"/users/settings"} class="nav-mobile-link">
                Settings
              </.link>
              <.link href={~p"/users/log-out"} method="delete" class="nav-mobile-link">
                Sign out
              </.link>
            <% else %>
              <.link href={~p"/"} class="nav-mobile-link nav-mobile-link-active" aria-current="page">
                Home
              </.link>
              <.link href={~p"/users/log-in"} class="nav-mobile-link">
                Log in
              </.link>
              <.link href={~p"/users/register"} class="nav-mobile-link">
                Register
              </.link>
            <% end %>
          </div>
        </el-disclosure>
      </nav>
      <%= if @current_scope && @current_scope.user && @current_scope.user.admin && @admin_bar != [] do %>
        <div class="admin-bar">
          <div class="admin-bar-container">
            <div class="admin-bar-content">
              <div class="admin-bar-label">
                <svg
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                  class="admin-bar-icon"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.857-9.809a.75.75 0 00-1.214-.882l-3.483 4.79-1.88-1.88a.75.75 0 10-1.06 1.061l2.5 2.5a.75.75 0 001.137-.089l4-5.5z"
                    clip-rule="evenodd"
                  />
                </svg>
                <span>Admin Mode</span>
              </div>
              <div class="admin-bar-actions">
                {render_slot(@admin_bar)}
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </header>

    <main class="main-content">
      <div class="content-container">
        {render_slot(@inner_block)}
      </div>
    </main>

    <footer class="site-footer">
      <div class="footer-container">
        <div class="footer-content">
          <div class="footer-social">
            <a href="#" class="footer-social-link">
              <span class="sr-only">Facebook</span>
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="footer-icon">
                <path
                  d="M22 12c0-5.523-4.477-10-10-10S2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.878v-6.987h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.988C18.343 21.128 22 16.991 22 12z"
                  clip-rule="evenodd"
                  fill-rule="evenodd"
                />
              </svg>
            </a>
            <a href="#" class="footer-social-link">
              <span class="sr-only">Instagram</span>
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="footer-icon">
                <path
                  d="M12.315 2c2.43 0 2.784.013 3.808.06 1.064.049 1.791.218 2.427.465a4.902 4.902 0 011.772 1.153 4.902 4.902 0 011.153 1.772c.247.636.416 1.363.465 2.427.048 1.067.06 1.407.06 4.123v.08c0 2.643-.012 2.987-.06 4.043-.049 1.064-.218 1.791-.465 2.427a4.902 4.902 0 01-1.153 1.772 4.902 4.902 0 01-1.772 1.153c-.636.247-1.363.416-2.427.465-1.067.048-1.407.06-4.123.06h-.08c-2.643 0-2.987-.012-4.043-.06-1.064-.049-1.791-.218-2.427-.465a4.902 4.902 0 01-1.772-1.153 4.902 4.902 0 01-1.153-1.772c-.247-.636-.416-1.363-.465-2.427-.047-1.024-.06-1.379-.06-3.808v-.63c0-2.43.013-2.784.06-3.808.049-1.064.218-1.791.465-2.427a4.902 4.902 0 011.153-1.772A4.902 4.902 0 015.45 2.525c.636-.247 1.363-.416 2.427-.465C8.901 2.013 9.256 2 11.685 2h.63zm-.081 1.802h-.468c-2.456 0-2.784.011-3.807.058-.975.045-1.504.207-1.857.344-.467.182-.8.398-1.15.748-.35.35-.566.683-.748 1.15-.137.353-.3.882-.344 1.857-.047 1.023-.058 1.351-.058 3.807v.468c0 2.456.011 2.784.058 3.807.045.975.207 1.504.344 1.857.182.466.399.8.748 1.15.35.35.683.566 1.15.748.353.137.882.3 1.857.344 1.054.048 1.37.058 4.041.058h.08c2.597 0 2.917-.01 3.96-.058.976-.045 1.505-.207 1.858-.344.466-.182.8-.398 1.15-.748.35-.35.566-.683.748-1.15.137-.353.3-.882.344-1.857.048-1.055.058-1.37.058-4.041v-.08c0-2.597-.01-2.917-.058-3.96-.045-.976-.207-1.505-.344-1.858a3.097 3.097 0 00-.748-1.15 3.098 3.098 0 00-1.15-.748c-.353-.137-.882-.3-1.857-.344-1.023-.047-1.351-.058-3.807-.058zM12 6.865a5.135 5.135 0 110 10.27 5.135 5.135 0 010-10.27zm0 1.802a3.333 3.333 0 100 6.666 3.333 3.333 0 000-6.666zm5.338-3.205a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4z"
                  clip-rule="evenodd"
                  fill-rule="evenodd"
                />
              </svg>
            </a>
            <a href="#" class="footer-social-link">
              <span class="sr-only">X</span>
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="footer-icon">
                <path d="M13.6823 10.6218L20.2391 3H18.6854L12.9921 9.61788L8.44486 3H3.2002L10.0765 13.0074L3.2002 21H4.75404L10.7663 14.0113L15.5685 21H20.8131L13.6819 10.6218H13.6823ZM11.5541 13.0956L10.8574 12.0991L5.31391 4.16971H7.70053L12.1742 10.5689L12.8709 11.5655L18.6861 19.8835H16.2995L11.5541 13.096V13.0956Z" />
              </svg>
            </a>
            <a href="#" class="footer-social-link">
              <span class="sr-only">GitHub</span>
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="footer-icon">
                <path
                  d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                  clip-rule="evenodd"
                  fill-rule="evenodd"
                />
              </svg>
            </a>
            <a href="#" class="footer-social-link">
              <span class="sr-only">YouTube</span>
              <svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" class="footer-icon">
                <path
                  d="M19.812 5.418c.861.23 1.538.907 1.768 1.768C21.998 8.746 22 12 22 12s0 3.255-.418 4.814a2.504 2.504 0 0 1-1.768 1.768c-1.56.419-7.814.419-7.814.419s-6.255 0-7.814-.419a2.505 2.505 0 0 1-1.768-1.768C2 15.255 2 12 2 12s0-3.255.417-4.814a2.507 2.507 0 0 1 1.768-1.768C5.744 5 11.998 5 11.998 5s6.255 0 7.814.418ZM15.194 12 10 15V9l5.194 3Z"
                  clip-rule="evenodd"
                  fill-rule="evenodd"
                />
              </svg>
            </a>
          </div>
          <p class="footer-copyright">
            &copy; 2024 Your Company, Inc. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
    </div>
    """
  end
end
