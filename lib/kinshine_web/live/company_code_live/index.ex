defmodule KinshineWeb.CompanyCodeLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.CompanyCode

  @impl true
  def mount(_params, _session, socket) do
    company_codes = Finance.list_company_codes()

    {:ok,
     socket
     |> assign(:page_title, "Company Code")
     |> assign(:company_codes_empty?, company_codes == [])
     |> stream_configure(:company_codes, dom_id: &"company-code-#{&1.comcod}")
     |> stream(:company_codes, company_codes)
     |> assign(:form, nil)
     |> assign(:editing_id, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    chart_of_accounts = Finance.list_chart_of_accounts_for_select()

    socket
    |> assign(:page_title, "Company Code")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
    |> assign(:chart_of_accounts, chart_of_accounts)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_company_code(%CompanyCode{}, %{})
    chart_of_accounts = Finance.list_chart_of_accounts_for_select()

    socket
    |> assign(:page_title, "New Company Code")
    |> assign(:form, to_form(changeset, as: "company_code"))
    |> assign(:editing_id, nil)
    |> assign(:chart_of_accounts, chart_of_accounts)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    company_code = Finance.get_company_code!(id)
    changeset = Finance.change_company_code(company_code, %{})
    chart_of_accounts = Finance.list_chart_of_accounts_for_select()

    socket
    |> assign(:page_title, "Edit Company Code")
    |> assign(:form, to_form(changeset, as: "company_code"))
    |> assign(:editing_id, id)
    |> assign(:chart_of_accounts, chart_of_accounts)
  end

  @impl true
  def handle_event("validate", %{"company_code" => params}, socket) do
    changeset =
      %CompanyCode{}
      |> Finance.change_company_code(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "company_code"))}
  end

  @impl true
  def handle_event("save", %{"company_code" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_company_code(params) do
          {:ok, company_code} ->
            socket =
              socket
              |> stream(:company_codes, [company_code])
              |> put_flash(:info, "Company Code created successfully!")
              |> push_navigate(to: ~p"/finance/companycode")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "company_code"))}
        end

      id ->
        company_code = Finance.get_company_code!(id)

        case Finance.update_company_code(company_code, params) do
          {:ok, _company_code} ->
            socket =
              socket
              |> stream(:company_codes, Finance.list_company_codes(), reset: true)
              |> put_flash(:info, "Company Code updated successfully!")
              |> push_navigate(to: ~p"/finance/companycode")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "company_code"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    company_code = Finance.get_company_code!(id)

    case Finance.delete_company_code(company_code) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:company_codes, Finance.list_company_codes(), reset: true)
         |> put_flash(:info, "Company Code deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Cannot delete Company Code. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/companycode")}
  end
end
