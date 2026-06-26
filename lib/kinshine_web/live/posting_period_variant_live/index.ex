defmodule KinshineWeb.PostingPeriodVariantLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.PostingPeriodVariant

  @impl true
  def mount(_params, _session, socket) do
    variants = Finance.list_posting_period_variants()

    {:ok,
     socket
     |> assign(:page_title, "Posting Period Variant")
     |> assign(:variants_empty?, variants == [])
     |> stream_configure(:variants, dom_id: &"posting-period-variant-#{&1.ppvid}")
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
    |> assign(:page_title, "Posting Period Variant")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_posting_period_variant(%PostingPeriodVariant{}, %{})

    socket
    |> assign(:page_title, "New Posting Period Variant")
    |> assign(:form, to_form(changeset, as: "posting_period_variant"))
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    variant = Finance.get_posting_period_variant!(id)
    changeset = Finance.change_posting_period_variant(variant, %{})

    socket
    |> assign(:page_title, "Edit Posting Period Variant")
    |> assign(:form, to_form(changeset, as: "posting_period_variant"))
    |> assign(:editing_id, id)
  end

  @impl true
  def handle_event("validate", %{"posting_period_variant" => params}, socket) do
    changeset =
      %PostingPeriodVariant{}
      |> Finance.change_posting_period_variant(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_variant"))}
  end

  @impl true
  def handle_event("save", %{"posting_period_variant" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_posting_period_variant(params) do
          {:ok, variant} ->
            socket =
              socket
              |> stream(:variants, [variant])
              |> put_flash(:info, "Posting Period Variant created successfully!")
              |> push_navigate(to: ~p"/finance/postingperiodvariant")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_variant"))}
        end

      id ->
        variant = Finance.get_posting_period_variant!(id)

        case Finance.update_posting_period_variant(variant, params) do
          {:ok, _variant} ->
            socket =
              socket
              |> stream(:variants, Finance.list_posting_period_variants(), reset: true)
              |> put_flash(:info, "Posting Period Variant updated successfully!")
              |> push_navigate(to: ~p"/finance/postingperiodvariant")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_variant"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    variant = Finance.get_posting_period_variant!(id)

    case Finance.delete_posting_period_variant(variant) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:variants, Finance.list_posting_period_variants(), reset: true)
         |> put_flash(:info, "Posting Period Variant deleted successfully!")}

      {:error, _changeset} ->
        {:noreply,
         put_flash(socket, :error, "Cannot delete Posting Period Variant. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/postingperiodvariant")}
  end
end
