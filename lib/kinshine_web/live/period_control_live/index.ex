defmodule KinshineWeb.PeriodControlLive.Index do
  use KinshineWeb, :live_view

  alias Kinshine.Finance
  alias Kinshine.Finance.Organizational.PostingPeriodControl

  @impl true
  def mount(_params, _session, socket) do
    controls = Finance.list_posting_period_controls()
    company_codes = Finance.list_company_codes()
    period_variants = Finance.list_posting_period_variants()

    {:ok,
     socket
     |> assign(:page_title, "Period Control")
     |> assign(:controls_empty?, controls == [])
     |> assign(:company_codes, company_codes)
     |> assign(:period_variants, period_variants)
     |> stream_configure(:controls, dom_id: &"period-control-#{&1.ppcid}")
     |> stream(:controls, controls)
     |> assign(:form, nil)
     |> assign(:editing_id, nil)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Period Control")
    |> assign(:form, nil)
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :new, _params) do
    changeset = Finance.change_posting_period_control(%PostingPeriodControl{}, %{})

    socket
    |> assign(:page_title, "New Period Control")
    |> assign(:form, to_form(changeset, as: "posting_period_control"))
    |> assign(:editing_id, nil)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    control = Finance.get_posting_period_control!(id)
    changeset = Finance.change_posting_period_control(control, %{})

    socket
    |> assign(:page_title, "Edit Period Control")
    |> assign(:form, to_form(changeset, as: "posting_period_control"))
    |> assign(:editing_id, id)
  end

  @impl true
  def handle_event("validate", %{"posting_period_control" => params}, socket) do
    changeset =
      %PostingPeriodControl{}
      |> Finance.change_posting_period_control(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_control"))}
  end

  @impl true
  def handle_event("save", %{"posting_period_control" => params}, socket) do
    case socket.assigns.editing_id do
      nil ->
        case Finance.create_posting_period_control(params) do
          {:ok, control} ->
            socket =
              socket
              |> stream(:controls, [control])
              |> put_flash(:info, "Period Control created successfully!")
              |> push_navigate(to: ~p"/finance/periodcontrol")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_control"))}
        end

      id ->
        control = Finance.get_posting_period_control!(id)

        case Finance.update_posting_period_control(control, params) do
          {:ok, _control} ->
            socket =
              socket
              |> stream(:controls, Finance.list_posting_period_controls(), reset: true)
              |> put_flash(:info, "Period Control updated successfully!")
              |> push_navigate(to: ~p"/finance/periodcontrol")

            {:noreply, socket}

          {:error, changeset} ->
            {:noreply, assign(socket, :form, to_form(changeset, as: "posting_period_control"))}
        end
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    control = Finance.get_posting_period_control!(id)

    case Finance.delete_posting_period_control(control) do
      {:ok, _} ->
        {:noreply,
         socket
         |> stream(:controls, Finance.list_posting_period_controls(), reset: true)
         |> put_flash(:info, "Period Control deleted successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Cannot delete Period Control. It may be in use.")}
    end
  end

  @impl true
  def handle_event("cancel", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/finance/periodcontrol")}
  end
end
