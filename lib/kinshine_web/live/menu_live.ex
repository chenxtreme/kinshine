defmodule KinshineWeb.MenuLive do
  use KinshineWeb, :live_view

  alias Kinshine.Basis
  alias Kinshine.Basis.Menu

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <%!-- Page header --%>
        <div class="flex justify-between items-start">
          <div>
            <div class="text-sm breadcrumbs text-base-content/60 mb-2">
              <ul>
                <li><a>Configuration</a></li>
                <li><a>Menus</a></li>
                <li>
                  <span class="font-semibold">{if @editing_menu, do: "Edit Menu", else: "Add Menu"}</span>
                </li>
              </ul>
            </div>
            <h1 class="text-2xl font-bold">Menu Management</h1>
            <p class="text-base-content/60 mt-1">
              Create and organize menu items in a hierarchical structure
            </p>
          </div>
        </div>

        <%!-- Two column layout --%>
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <%!-- Left: Add/Edit Menu Form --%>
          <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow">
              <div class="card-body">
                <h2 class="card-title text-lg">
                  <.icon
                    name={if @editing_menu, do: "hero-pencil-square", else: "hero-plus-circle"}
                    class="size-5"
                  />
                  {if @editing_menu, do: "Edit Menu", else: "Add New Menu"}
                </h2>

                <.form
                  :let={f}
                  for={@form}
                  phx-change="validate"
                  phx-submit="save"
                  class="space-y-4"
                >
                  <%!-- Parent Menu Selection (top) --%>
                  <div class="form-control">
                    <label class="label">
                      <span class="label-text font-medium">Parent Menu</span>
                    </label>
                    <.input
                      field={f[:menpar]}
                      type="select"
                      prompt="-- Top Level Menu --"
                      options={@parent_menu_options}
                    />
                    <p class="label-text-alt text-base-content/60 mt-1">
                      Leave empty to create a top-level menu
                    </p>
                  </div>

                  <%!-- Menu Name --%>
                  <div class="form-control">
                    <label class="label">
                      <span class="label-text font-medium">Menu Name</span>
                    </label>
                    <.input
                      field={f[:mennam]}
                      type="text"
                      placeholder="e.g., Dashboard, Reports, Settings"
                      required
                    />
                    <p :for={{msg, _opts} <- f[:mennam].errors} class="mt-1 text-sm text-error">
                      {msg}
                    </p>
                  </div>

                  <%!-- Sort Order --%>
                  <div class="form-control">
                    <label class="label">
                      <span class="label-text font-medium">Sort Order</span>
                    </label>
                    <.input
                      field={f[:mensrt]}
                      type="number"
                      min="0"
                      placeholder="0"
                    />
                    <p class="label-text-alt text-base-content/60 mt-1">
                      Lower numbers appear first
                    </p>
                  </div>

                  <%!-- Has Link? checkbox (only for new menu) --%>
                  <%= if is_nil(@editing_menu) do %>
                    <div class="form-control">
                      <label class="label cursor-pointer justify-start gap-3">
                        <input
                          type="checkbox"
                          checked={@has_link}
                          phx-click="toggle-link"
                          class="checkbox checkbox-primary"
                        />
                        <span class="label-text font-medium">Has Link?</span>
                      </label>
                      <p class="label-text-alt text-base-content/60 mt-1">
                        Enable to set a URL path for this menu item
                      </p>
                    </div>

                    <%!-- Menu Link (shown only when has_link is true) --%>
                    <%= if @has_link do %>
                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Menu Link</span>
                        </label>
                        <.input
                          field={f[:mnlink]}
                          type="text"
                          placeholder="e.g., /dashboard"
                        />
                        <p class="label-text-alt text-base-content/60 mt-1">
                          Auto-filled from menu name. Edit if needed.
                        </p>
                      </div>
                    <% end %>
                  <% else %>
                    <%!-- Show existing link as read-only when editing --%>
                    <%= if @editing_menu.mnlink do %>
                      <div class="form-control">
                        <label class="label">
                          <span class="label-text font-medium">Menu Link</span>
                        </label>
                        <div class="input input-bordered bg-base-200 text-base-content/70 flex items-center">
                          {@editing_menu.mnlink}
                        </div>
                        <p class="label-text-alt text-base-content/60 mt-1">
                          Link cannot be changed
                        </p>
                      </div>
                    <% end %>
                  <% end %>

                  <%!-- Action Buttons --%>
                  <div class="form-control mt-6 flex flex-row gap-2">
                    <%= if @editing_menu do %>
                      <button
                        type="submit"
                        class="btn btn-primary flex-1"
                        phx-disable-with="Saving..."
                      >
                        <.icon name="hero-check" class="size-4" /> Update Menu
                      </button>
                      <button type="button" phx-click="cancel-edit" class="btn btn-ghost">
                        Cancel
                      </button>
                    <% else %>
                      <button
                        type="submit"
                        class="btn btn-primary flex-1"
                        phx-disable-with="Saving..."
                      >
                        <.icon name="hero-plus" class="size-4" /> Add Menu
                      </button>
                    <% end %>
                  </div>
                </.form>
              </div>
            </div>
          </div>

          <%!-- Right: Menu Tree Preview --%>
          <div class="lg:col-span-2">
            <div class="card bg-base-100 shadow">
              <div class="card-body">
                <h2 class="card-title text-lg">
                  <.icon name="hero-list-tree" class="size-5" /> Menu Structure
                </h2>

                <div class="mt-4">
                  <%= if @menus == [] do %>
                    <div class="text-center py-8 text-base-content/60">
                      <.icon name="hero-folder-plus" class="size-12 mx-auto opacity-50" />
                      <p class="mt-2">No menus yet. Add your first menu!</p>
                    </div>
                  <% else %>
                    <div class="space-y-2">
                      <%= for root_menu <- @root_menus do %>
                        <.menu_tree_item
                          menu={root_menu}
                          all_menus={@menus}
                          level={0}
                          editing_menu_id={@editing_menu_id}
                        />
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    menus = Basis.list_menus()
    root_menus = Basis.list_root_menus()

    parent_menu_options = build_parent_menu_options(menus)

    form =
      to_form(Basis.change_menu(%Menu{}), as: "menu")

    {:ok,
     assign(socket,
       page_title: "Menu Management",
       menus: menus,
       root_menus: root_menus,
       parent_menu_options: parent_menu_options,
       has_link: false,
       editing_menu: nil,
       editing_menu_id: nil,
       form: form
     )}
  end

  @impl true
  def handle_event("validate", %{"menu" => params}, socket) do
    # Auto-fill mnlink from mennam when has_link is enabled (only for new menu)
    params =
      if is_nil(socket.assigns.editing_menu) and socket.assigns.has_link do
        mennam = params["mennam"] || ""
        Map.put(params, "mnlink", generate_mnlink(mennam))
      else
        params
      end

    changeset =
      if editing_menu = socket.assigns.editing_menu do
        editing_menu
        |> Basis.change_menu(params)
        |> Map.put(:action, :validate)
      else
        %Menu{}
        |> Basis.change_menu(params)
        |> Map.put(:action, :validate)
      end

    {:noreply, assign(socket, form: to_form(changeset, as: "menu"))}
  end

  @impl true
  def handle_event("toggle-link", _params, socket) do
    has_link = !socket.assigns.has_link
    mennam = Phoenix.HTML.Form.input_value(socket.assigns.form, :mennam)

    mnlink =
      if has_link and mennam do
        generate_mnlink(mennam)
      else
        nil
      end

    # Build params from current form values
    current_params =
      for field <- [:mennam, :menpar, :mensrt, :mnlink],
          do: {Atom.to_string(field), Phoenix.HTML.Form.input_value(socket.assigns.form, field)},
          into: %{}

    params = Map.put(current_params, "mnlink", mnlink)

    changeset =
      %Menu{}
      |> Basis.change_menu(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(has_link: has_link, form: to_form(changeset, as: "menu"))}
  end

  @impl true
  def handle_event("edit-menu", %{"menuid" => menuid}, socket) do
    menu = Basis.get_menu!(menuid)

    # Build params from the menu for the form
    params = %{
      "mennam" => menu.mennam,
      "mensrt" => menu.mensrt,
      "menpar" => menu.menpar,
      "mnlink" => menu.mnlink
    }

    changeset =
      menu
      |> Basis.change_menu(params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(
       editing_menu: menu,
       editing_menu_id: menuid,
       form: to_form(changeset, as: "menu")
     )}
  end

  @impl true
  def handle_event("cancel-edit", _params, socket) do
    form =
      to_form(Basis.change_menu(%Menu{}), as: "menu")

    {:noreply,
     socket
     |> assign(
       editing_menu: nil,
       editing_menu_id: nil,
       has_link: false,
       form: form
     )}
  end

  @impl true
  def handle_event("save", %{"menu" => params}, socket) do
    # Convert empty strings to nil
    params =
      params
      |> Map.update("menpar", nil, fn val -> if val == "", do: nil, else: val end)
      |> Map.update("mnlink", nil, fn val -> if val == "", do: nil, else: val end)
      |> Map.update("mensrt", nil, fn val ->
        if val == "" or is_nil(val), do: 0, else: String.to_integer(val)
      end)

    if editing_menu = socket.assigns.editing_menu do
      # Update existing menu
      case Basis.update_menu(editing_menu, params) do
        {:ok, _menu} ->
          socket = refresh_data(socket)
          {:noreply, put_flash(socket, :info, "Menu updated successfully!")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset, as: "menu"))}
      end
    else
      # Create new menu
      case Basis.create_menu(params) do
        {:ok, _menu} ->
          socket = refresh_data(socket)
          {:noreply, put_flash(socket, :info, "Menu added successfully!")}

        {:error, changeset} ->
          {:noreply, assign(socket, form: to_form(changeset, as: "menu"))}
      end
    end
  end

  # Recursive component to render menu tree with expand/collapse
  attr :menu, Menu, required: true
  attr :all_menus, :list, required: true
  attr :level, :integer, default: 0
  attr :editing_menu_id, :string, default: nil

  def menu_tree_item(assigns) do
    ~H"""
    <div class="ml-{@level * 4}">
      <%= if has_children?(@menu, @all_menus) do %>
        <%!-- Folder node with expand/collapse --%>
        <details class="group" open>
          <summary class={[
            "flex items-center gap-2 p-2 rounded-lg transition-colors cursor-pointer list-none hover:bg-base-200",
            "[&::-webkit-details-marker]:hidden [&::marker]:hidden",
            if(@menu.menuid == @editing_menu_id, do: "bg-primary/10 ring-1 ring-primary/30")
          ]}>
            <%!-- Expand/collapse chevron --%>
            <span class="transition-transform duration-200 group-open:rotate-90 text-base-content/40">
              <.icon name="hero-chevron-right" class="size-3" />
            </span>

            <%= if @level == 0 do %>
              <.icon name="hero-folder" class="size-4 text-primary" />
            <% else %>
              <.icon name="hero-folder-open" class="size-4 text-secondary" />
            <% end %>

            <span class="flex-1 font-medium">{@menu.mennam}</span>

            <span class="text-xs text-base-content/60">
              Order: {@menu.mensrt}
            </span>

            <%= if @menu.mnlink do %>
              <span class="badge badge-sm badge-outline badge-info">
                {@menu.mnlink}
              </span>
            <% end %>

            <%!-- Edit button --%>
            <button
              phx-click="edit-menu"
              phx-value-menuid={@menu.menuid}
              class="btn btn-outline btn-primary btn-xs btn-square"
              title="Edit menu"
            >
              <.icon name="hero-pencil-square" class="size-4" />
            </button>
          </summary>

          <div class="border-l-2 border-base-300 ml-3 mt-1">
            <%= for child <- get_children(@menu, @all_menus) do %>
              <.menu_tree_item
                menu={child}
                all_menus={@all_menus}
                level={@level + 1}
                editing_menu_id={@editing_menu_id}
              />
            <% end %>
          </div>
        </details>
      <% else %>
        <%!-- Leaf node (no children) --%>
        <div class={[
          "flex items-center gap-2 p-2 rounded-lg transition-colors",
          if(@menu.menuid == @editing_menu_id,
            do: "bg-primary/10 ring-1 ring-primary/30",
            else: "hover:bg-base-200"
          )
        ]}>
          <%!-- Spacer to align with folder items that have chevron --%>
          <span class="w-3"></span>

          <%= if @level == 0 do %>
            <.icon name="hero-document-text" class="size-4 text-primary" />
          <% else %>
            <.icon name="hero-document" class="size-4 text-base-content/60 ml-2" />
          <% end %>

          <span class="flex-1 font-medium">{@menu.mennam}</span>

          <span class="text-xs text-base-content/60">
            Order: {@menu.mensrt}
          </span>

          <%= if @menu.mnlink do %>
            <span class="badge badge-sm badge-outline badge-info">
              {@menu.mnlink}
            </span>
          <% end %>

          <%!-- Edit button --%>
          <button
            phx-click="edit-menu"
            phx-value-menuid={@menu.menuid}
            class="btn btn-outline btn-primary btn-xs btn-square"
            title="Edit menu"
          >
            <.icon name="hero-pencil-square" class="size-4" />
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp has_children?(menu, all_menus) do
    Enum.any?(all_menus, &(&1.menpar == menu.menuid))
  end

  defp get_children(menu, all_menus) do
    all_menus
    |> Enum.filter(&(&1.menpar == menu.menuid))
    |> Enum.sort_by(& &1.mensrt)
  end

  defp generate_mnlink(mennam) do
    mennam
    |> String.downcase()
    |> String.replace(~r/\s+/, "")
    |> then(&"/#{&1}")
  end

  defp build_parent_menu_options(menus) do
    options =
      menus
      |> Enum.filter(fn m -> is_nil(m.mnlink) and is_nil(m.pageid) end)
      |> Enum.map(fn m -> {m.mennam, m.menuid} end)

    [{nil, "-- Top Level Menu --"}] ++ options
  end

  defp refresh_data(socket) do
    menus = Basis.list_menus()
    root_menus = Basis.list_root_menus()
    parent_menu_options = build_parent_menu_options(menus)

    form =
      to_form(Basis.change_menu(%Menu{}), as: "menu")

    socket
    |> assign(
      menus: menus,
      root_menus: root_menus,
      parent_menu_options: parent_menu_options,
      editing_menu: nil,
      editing_menu_id: nil,
      has_link: false,
      form: form
    )
  end
end
