defmodule Kinshine.Finance.Process.PeriodOpenClose do
  @moduledoc """
  Business process for opening and closing posting periods.
  Validates period transitions and ensures no transactions are posted to closed periods.
  """
  import Ecto.Query, only: [from: 2]

  alias Kinshine.Repo
  alias Kinshine.Finance.Organizational.PostingPeriodControl

  @doc """
  Opens a posting period for a given company code, year, and period.
  Returns {:ok, control} or {:error, changeset}.
  """
  def open_period(comcod, fyear, perid) do
    case find_period_control(comcod, fyear, perid) do
      nil ->
        {:error, :not_found, "Period control not found"}

      control ->
        if control.persta == "X" do
          {:error, :already_open, "Period is already open"}
        else
          control
          |> PostingPeriodControl.changeset(%{persta: "X", peropn: Date.utc_today()})
          |> Repo.update()
        end
    end
  end

  @doc """
  Closes a posting period for a given company code, year, and period.
  Validates that all previous periods are closed before closing the current one.
  Returns {:ok, control} or {:error, reason}.
  """
  def close_period(comcod, fyear, perid) do
    case find_period_control(comcod, fyear, perid) do
      nil ->
        {:error, :not_found, "Period control not found"}

      control ->
        if control.persta == "C" do
          {:error, :already_closed, "Period is already closed"}
        else
          # Validate previous periods are closed
          case validate_previous_periods_closed(comcod, fyear, perid) do
            :ok ->
              control
              |> PostingPeriodControl.changeset(%{persta: "C", percls: Date.utc_today()})
              |> Repo.update()

            {:error, reason} ->
              {:error, :previous_periods_open, reason}
          end
        end
    end
  end

  @doc """
  Checks if a period is open for posting.
  Returns true if the period exists and is open, false otherwise.
  """
  def period_open?(comcod, fyear, perid) do
    case find_period_control(comcod, fyear, perid) do
      nil -> false
      control -> control.persta == "X"
    end
  end

  defp find_period_control(comcod, fyear, perid) do
    Repo.one(
      from p in PostingPeriodControl,
        where: p.comcod == ^comcod and p.fyear == ^fyear and p.perid == ^perid
    )
  end

  defp validate_previous_periods_closed(comcod, fyear, perid) do
    open_previous =
      Repo.all(
        from p in PostingPeriodControl,
          where:
            p.comcod == ^comcod and p.fyear == ^fyear and p.perid < ^perid and p.persta == "X"
      )

    if open_previous == [] do
      :ok
    else
      open_periods = Enum.map(open_previous, & &1.perid) |> Enum.join(", ")
      {:error, "Previous periods must be closed first: #{open_periods}"}
    end
  end
end
