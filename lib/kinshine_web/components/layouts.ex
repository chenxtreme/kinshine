defmodule KinshineWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use KinshineWeb, :html

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
    doc: "the current [scope](https://phoenix.hexdocs.pm/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <%= if @current_scope do %>
      <%!-- Authenticated layout: sidebar drawer --%>
      <div class="drawer lg:drawer-open min-h-screen">
        <input id="sidebar-drawer" type="checkbox" class="drawer-toggle" />
        <div class="drawer-content flex flex-col">
          <%!-- Topbar --%>
          <div class="navbar bg-base-100 shadow-sm px-4 lg:px-6 sticky top-0 z-10">
            <div class="flex-none lg:hidden">
              <label for="sidebar-drawer" class="btn btn-square btn-ghost" aria-label="Open menu">
                <.icon name="hero-bars-3" class="size-5" />
              </label>
            </div>
            <div class="flex-1" />
            <div class="flex-none flex items-center gap-2">
              <span class="text-sm text-base-content/60 hidden sm:block">
                {@current_scope.user.emails}
              </span>
              <.link navigate={~p"/users/settings"} class="btn btn-ghost btn-sm">
                <.icon name="hero-cog-6-tooth" class="size-4" /> Settings
              </.link>
              <.link
                href={~p"/users/log-out"}
                method="delete"
                class="btn btn-ghost btn-sm text-error"
              >
                <.icon name="hero-arrow-right-on-rectangle" class="size-4" /> Log out
              </.link>
              <.theme_toggle />
            </div>
          </div>
          <%!-- Page content --%>
          <main class="flex-1 p-4 lg:p-6">
            {render_slot(@inner_block)}
          </main>
        </div>
        <%!-- Sidebar --%>
        <div class="drawer-side z-20">
          <label for="sidebar-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
          <aside class="bg-base-200 min-h-full w-64 flex flex-col">
            <div class="px-5 py-5 border-b border-base-300">
              <a href="/dashboard" class="text-xl font-bold text-primary">Kinshine</a>
            </div>
            <ul class="menu menu-md flex-1 px-3 pt-3 gap-1">
              <li>
                <.link navigate={~p"/dashboard"} class="gap-3">
                  <.icon name="hero-home" class="size-5" /> Dashboard
                </.link>
              </li>
              <li>
                <details open>
                  <summary class="gap-3">
                    <.icon name="hero-cog-6-tooth" class="size-5" /> Configuration
                  </summary>
                  <ul>
                    <li>
                      <.link navigate={~p"/configuration/menus"}>Menus</.link>
                    </li>
                  </ul>
                </details>
              </li>
              <li>
                <details open>
                  <summary class="gap-3">
                    <.icon name="hero-users" class="size-5" /> User Management
                  </summary>
                  <ul>
                    <li>
                      <.link navigate={~p"/users/settings"}>My Settings</.link>
                    </li>
                  </ul>
                </details>
              </li>
              <li>
                <details>
                  <summary class="gap-3">
                    <.icon name="hero-chart-bar" class="size-5" /> Reports
                  </summary>
                  <ul>
                    <li>
                      <a class="opacity-50 cursor-default">Coming soon…</a>
                    </li>
                  </ul>
                </details>
              </li>
            </ul>
          </aside>
        </div>
      </div>
    <% else %>
      <%!-- Guest layout: centered card --%>
      <div class="min-h-screen bg-gradient-to-br from-base-200 via-base-100 to-base-200 flex flex-col">
        <div class="navbar px-4 max-w-5xl mx-auto w-full">
          <div class="flex-1" />
          <div class="flex-none">
            <.theme_toggle />
          </div>
        </div>
        <main class="flex-1 flex items-center justify-center p-4">
          {render_slot(@inner_block)}
        </main>
        <footer class="text-center text-xs text-base-content/30 py-4">
          © {Date.utc_today().year} Kinshine
        </footer>
      </div>
    <% end %>
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

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={
          show(".phx-client-error #client-error")
          |> JS.remove_attribute("hidden", to: ".phx-client-error #client-error")
        }
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={
          show(".phx-server-error #server-error")
          |> JS.remove_attribute("hidden", to: ".phx-server-error #server-error")
        }
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 [[data-theme-source=system]_&]:!left-0 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
