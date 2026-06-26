defmodule KinshineWeb.AccountGroupLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.AccountGroup

  @impl true
  def mount(_params, _session, socket) do
    groups = Finance.list_account_groups()

    {:ok,
     socket
     |> assign(:page_title, "Account Group")
     |> assign(:groups_empty?, groups == [])
     |> stream_configure(:groups, dom_id: &"account-group-#{&1.acgid}")
     |> stream(:groups, groups)
     |> assign(:form, nil)
     |> assign(:editing_id, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Account Group")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_account_group(%AccountGroup{}, %{})

    socket
    |> assign(:page_title, "New Account Group")
    |> assign(:form, to_form(changeset, as: "account_group"))
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    group = Finance.get_account_group!(id)
    changeset = Finance.change_account_group(group, %{})

    socket
    |> assign(:page_title, "Edit Account Group")
    |> assign(:form, to_form(changeset, as: "account_group"))
    |> assign(:editing_id, id)
  end

  @impl true
  def handle_event("validate", %{"account_group" => params}, socket) do
    changeset =
      %AccountGroup{}
      |> Finance.change_account_group(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "account_group"))}
  end

  @impl true
  def handle_event("save", %{"account_group" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_account_group(params) do
          {:ok, group} ->
            socket =
              socket
              |> stream(:groups, [group])
              |> put_flash(:info, "Account Group created successfully!")
              |> push_navigate(to: ~p"/finance/accountgroup")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "account_group"))}
        end

      id ->
        group = Finance.get_account_group!(id)

        case Finance.update_account_group(group, params) do
          {:ok, _group} ->
            socket =
              socket
              |> stream(:groups, Finance.list_account_groups(), reset: true)
              |> put_flash(:info, "Account Group updated successfully!")
              |> push_navigate(to: ~p"/finance/accountgroup")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "account_group"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    group = Finance.get_account_group!(id)

    case Finance.delete_account_group(group) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:groups, Finance.list_account_groups(), reset: true)
         |> put_flash(:info, "Account Group deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Cannot delete Account Group. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/accountgroup")}
  end
end
