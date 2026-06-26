defmodule KinshineWeb.CompanyCodeGLAccountLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.CoaGLAccount

  @impl true
  def mount(_params, _session, socket) do
    coa_gl_accounts = Finance.list_coa_gl_accounts()
    chart_of_accounts = Finance.list_chart_of_accounts()
    gl_accounts = Finance.list_gl_account_masters()

    {:ok,
     socket
     |> assign(:page_title, "COA GL Account")
     |> assign(:coa_gl_accounts_empty?, coa_gl_accounts == [])
     |> assign(:chart_of_accounts, chart_of_accounts)
     |> assign(:gl_accounts, gl_accounts)
     |> stream_configure(:coa_gl_accounts, dom_id: &"coa-gl-account-#{&1.coaid}-#{&1.acnum}")
     |> stream(:coa_gl_accounts, coa_gl_accounts)
     |> assign(:form, nil)
     |> assign(:editing_coaid, nil)
     |> assign(:editing_acnum, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "COA GL Account")
    |> assign(:form, nil)
    |> assign(:editing_coaid, nil)
    |> assign(:editing_acnum, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_coa_gl_account(%CoaGLAccount{}, %{})

    socket
    |> assign(:page_title, "New COA GL Account")
    |> assign(:form, to_form(changeset, as: "coa_gl_account"))
    |> assign(:editing_coaid, nil)
    |> assign(:editing_acnum, nil)
  end

  defp apply_action(socket, :edit, %{"coaid" => coaid, "acnum" => acnum}) do
    coa_gl = Finance.get_coa_gl_account!(coaid, acnum)
    changeset = Finance.change_coa_gl_account(coa_gl, %{})

    socket
    |> assign(:page_title, "Edit COA GL Account")
    |> assign(:form, to_form(changeset, as: "coa_gl_account"))
    |> assign(:editing_coaid, coaid)
    |> assign(:editing_acnum, acnum)
  end

  @impl true
  def handle_event("validate", %{"coa_gl_account" => params}, socket) do
    changeset =
      %CoaGLAccount{}
      |> Finance.change_coa_gl_account(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "coa_gl_account"))}
  end

  @impl true
  def handle_event("save", %{"coa_gl_account" => params}, socket) do
    case socket.assigns.editing_coaid do
      nil ->
        case Finance.create_coa_gl_account(params) do
          {:ok, coa_gl} ->
            socket =
              socket
              |> stream(:coa_gl_accounts, [coa_gl])
              |> put_flash(:info, "COA GL Account created successfully!")
              |> push_navigate(to: ~p"/finance/companycodeglaccount")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "coa_gl_account"))}
        end

      coaid ->
        coa_gl = Finance.get_coa_gl_account!(coaid, socket.assigns.editing_acnum)

        # CoaGLAccount has no update (composite key), so we delete + re-create
        Finance.delete_coa_gl_account(coa_gl)

        case Finance.create_coa_gl_account(params) do
          {:ok, _coa_gl} ->
            socket =
              socket
              |> stream(:coa_gl_accounts, Finance.list_coa_gl_accounts(), reset: true)
              |> put_flash(:info, "COA GL Account updated successfully!")
              |> push_navigate(to: ~p"/finance/companycodeglaccount")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "coa_gl_account"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"coaid" => coaid, "acnum" => acnum}, socket) do
    coa_gl = Finance.get_coa_gl_account!(coaid, acnum)

    case Finance.delete_coa_gl_account(coa_gl) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:coa_gl_accounts, Finance.list_coa_gl_accounts(), reset: true)
         |> put_flash(:info, "COA GL Account deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Cannot delete COA GL Account. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/companycodeglaccount")}
  end
end
