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
                <li><span class="font-semibold">Add Menu</span></li>
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
          <%!-- Left: Add Menu Form --%>
          <div class="lg:col-span-1">
            <div class="card bg-base-100 shadow">
              <div class="card-body">
                <h2 class="card-title text-lg">
                  <.icon name="hero-plus-circle" class="size-5" />
                  Add New Menu
                </h2>

                <.form
                  :let={f}
                  for={@form}
                  phx-change="validate"
                  phx-submit="save"
                  class="space-y-4"
                >
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
                    <.error :for={err <- @form.errors[:mennam]}>
                      {translate_error(err)}
                    </.error>
                  </div>

                  <%!-- Parent Menu Selection --%>
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

                  <%!-- Page Link (Optional) --%>
                  <div class="form-control">
                    <label class="label">
                      <span class="label-text font-medium">Linked Page (Optional)</span>
                    </label>
                    <.input
                      field={f[:pageid]}
                      type="select"
                      prompt="-- No Link --"
                      options={@page_options}
                    />
                    <p class="label-text-alt text-base-content/60 mt-1">
                      Select a page this menu should navigate to
                    </p>
                  </div>

                  <%!-- Submit Button --%>
                  <div class="form-control mt-6">
                    <button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
                      <.icon name="hero-plus" class="size-4" />
                      Add Menu
                    </button>
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
                  <.icon name="hero-list-tree" class="size-5" />
                  Menu Structure
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
    pages = Basis.list_pages()

    parent_menu_options =
      Enum.map(menus, fn m -> {m.mennam, m.menuid} end)

    page_options =
      Enum.map(pages, fn p -> {p.pagtit, p.pageid} end)

    form =
      to_form(Basis.change_menu(%Menu{}), as: "menu")

    {:ok,
     assign(socket,
       page_title: "Menu Management",
       menus: menus,
       root_menus: root_menus,
       parent_menu_options: [{nil, "-- Top Level Menu --"}] ++ parent_menu_options,
       page_options: [{nil, "-- No Link --"}] ++ page_options,
       form: form
     )}
  end

  @impl true
  def handle_event("validate", %{"menu" => params}, socket) do
    changeset =
      %Menu{}
      |> Basis.change_menu(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset, as: "menu"))}
  end

  @impl true
  def handle_event("save", %{"menu" => params}, socket) do
    # Convert empty strings to nil
    params =
      params
      |> Map.update("menpar", nil, fn val -> if val == "", do: nil, else: val end)
      |> Map.update("pageid", nil, fn val -> if val == "", do: nil, else: val end)
      |> Map.update("mensrt", nil, fn val -> if val == "" or is_nil(val), do: 0, else: String.to_integer(val) end)

    case Basis.create_menu(params) do
      {:ok, _menu} ->
        # Refresh data
        menus = Basis.list_menus()
        root_menus = Basis.list_root_menus()

        parent_menu_options =
          Enum.map(menus, fn m -> {m.mennam, m.menuid} end)

        form =
          to_form(Basis.change_menu(%Menu{}), as: "menu")

        socket =
          socket
          |> assign(
            menus: menus,
            root_menus: root_menus,
            parent_menu_options: [{nil, "-- Top Level Menu --"}] ++ parent_menu_options,
            form: form
          )
          |> put_flash(:info, "Menu added successfully!")

        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "menu"))}
    end
  end

  # Recursive component to render menu tree
  attr :menu, Menu, required: true
  attr :all_menus, :list, required: true
  attr :level, :integer, default: 0

  def menu_tree_item(assigns) do
    ~H"""
    <div class="ml-{@level * 4}">
      <div class="flex items-center gap-2 p-2 rounded-lg hover:bg-base-200 transition-colors">
        <%= if @level == 0 do %>
          <.icon name="hero-folder" class="size-4 text-primary" />
        <% else %>
          <.icon name="hero-document" class="size-4 text-secondary ml-2" />
        <% end %>
        
        <span class="flex-1 font-medium"><%= @menu.mennam %></span>
        
        <span class="text-xs text-base-content/60">
          Order: {@menu.mensrt}
        </span>

        <%= if @menu.page do %>
          <span class="badge badge-sm badge-outline">
            {@menu.page.pagtit}
          </span>
        <% end %>
      </div>

      <%= if has_children?(@menu, @all_menus) do %>
        <div class="border-l-2 border-base-300 ml-3">
          <%= for child <- get_children(@menu, @all_menus) do %>
            <.menu_tree_item
              menu={child}
              all_menus={@all_menus}
              level={@level + 1}
            />
          <% end %>
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
end
