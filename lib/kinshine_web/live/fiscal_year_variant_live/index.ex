defmodule KinshineWeb.FiscalYearVariantLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.FiscalYearVariant

  @impl true
  def mount(_params, _session, socket) do
    variants = Finance.list_fiscal_year_variants()

    {:ok,
     socket
     |> assign(:page_title, "Fiscal Year Variant")
     |> assign(:variants_empty?, variants == [])
     |> stream_configure(:variants, dom_id: &"fiscal-year-variant-#{&1.fyyid}")
     |> stream(:variants, variants)
     |> assign(:form, nil)
     |> assign(:editing_id, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Fiscal Year Variant")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_fiscal_year_variant(%FiscalYearVariant{}, %{})

    socket
    |> assign(:page_title, "New Fiscal Year Variant")
    |> assign(:form, to_form(changeset, as: "fiscal_year_variant"))
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    variant = Finance.get_fiscal_year_variant!(id)
    changeset = Finance.change_fiscal_year_variant(variant, %{})

    socket
    |> assign(:page_title, "Edit Fiscal Year Variant")
    |> assign(:form, to_form(changeset, as: "fiscal_year_variant"))
    |> assign(:editing_id, id)
  end

  @impl true
  def handle_event("validate", %{"fiscal_year_variant" => params}, socket) do
    changeset =
      %FiscalYearVariant{}
      |> Finance.change_fiscal_year_variant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "fiscal_year_variant"))}
  end

  @impl true
  def handle_event("save", %{"fiscal_year_variant" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_fiscal_year_variant(params) do
          {:ok, variant} ->
            socket =
              socket
              |> stream(:variants, [variant])
              |> put_flash(:info, "Fiscal Year Variant created successfully!")
              |> push_navigate(to: ~p"/finance/fiscalyearvariant")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "fiscal_year_variant"))}
        end

      id ->
        variant = Finance.get_fiscal_year_variant!(id)

        case Finance.update_fiscal_year_variant(variant, params) do
          {:ok, _variant} ->
            socket =
              socket
              |> stream(:variants, Finance.list_fiscal_year_variants(), reset: true)
              |> put_flash(:info, "Fiscal Year Variant updated successfully!")
              |> push_navigate(to: ~p"/finance/fiscalyearvariant")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "fiscal_year_variant"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    variant = Finance.get_fiscal_year_variant!(id)

    case Finance.delete_fiscal_year_variant(variant) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:variants, Finance.list_fiscal_year_variants(), reset: true)
         |> put_flash(:info, "Fiscal Year Variant deleted successfully!")}

      {:error, _changeset} ->
        {:noreply,
         put_flash(socket, :error, "Cannot delete Fiscal Year Variant. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/fiscalyearvariant")}
  end
end
