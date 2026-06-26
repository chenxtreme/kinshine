defmodule KinshineWeb.GLAccountMasterLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.GLAccountMaster

  @impl true
  def mount(_params, _session, socket) do
    accounts = Finance.list_gl_account_masters()
    groups = Finance.list_account_groups()

    {:ok,
     socket
     |> assign(:page_title, "GL Account Master")
     |> assign(:accounts_empty?, accounts == [])
     |> assign(:groups, groups)
     |> stream_configure(:accounts, dom_id: &"gl-account-#{&1.acnum}")
     |> stream(:accounts, accounts)
     |> assign(:form, nil)
     |> assign(:editing_id, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "GL Account Master")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_gl_account_master(%GLAccountMaster{}, %{})

    socket
    |> assign(:page_title, "New GL Account")
    |> assign(:form, to_form(changeset, as: "gl_account_master"))
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    account = Finance.get_gl_account_master!(id)
    changeset = Finance.change_gl_account_master(account, %{})

    socket
    |> assign(:page_title, "Edit GL Account")
    |> assign(:form, to_form(changeset, as: "gl_account_master"))
    |> assign(:editing_id, id)
  end

  @impl true
  def handle_event("validate", %{"gl_account_master" => params}, socket) do
    changeset =
      %GLAccountMaster{}
      |> Finance.change_gl_account_master(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "gl_account_master"))}
  end

  @impl true
  def handle_event("save", %{"gl_account_master" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_gl_account_master(params) do
          {:ok, account} ->
            socket =
              socket
              |> stream(:accounts, [account])
              |> put_flash(:info, "GL Account created successfully!")
              |> push_navigate(to: ~p"/finance/glaccountmaster")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "gl_account_master"))}
        end

      id ->
        account = Finance.get_gl_account_master!(id)

        case Finance.update_gl_account_master(account, params) do
          {:ok, _account} ->
            socket =
              socket
              |> stream(:accounts, Finance.list_gl_account_masters(), reset: true)
              |> put_flash(:info, "GL Account updated successfully!")
              |> push_navigate(to: ~p"/finance/glaccountmaster")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "gl_account_master"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    account = Finance.get_gl_account_master!(id)

    case Finance.delete_gl_account_master(account) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:accounts, Finance.list_gl_account_masters(), reset: true)
         |> put_flash(:info, "GL Account deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Cannot delete GL Account. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/glaccountmaster")}
  end
end
