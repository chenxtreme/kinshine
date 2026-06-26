defmodule Kinshine.Finance.Process.FiscalYearGenerator do
  @moduledoc """
  Business process for generating posting periods automatically
  based on Fiscal Year Variant and Posting Period Variant.
  """
  import Ecto.Query, only: [from: 2]

  alias Kinshine.Repo

  alias Kinshine.Finance.Organizational.{
    PostingPeriodVariant,
    PostingPeriodControl
  }

  @doc """
  Generates posting period controls for a company code for a given fiscal year.
  Uses the company's assigned Fiscal Year Variant and Posting Period Variant.

  Returns {:ok, [controls]} or {:error, reason}.
  """
  def generate_periods(comcod, fyear, ppvid) do
    with {:ok, variant} <- get_posting_period_variant(ppvid) do
      existing =
        Repo.all(
          from p in PostingPeriodControl,
            where: p.comcod == ^comcod and p.fyear == ^fyear
        )

      if existing != [] do
        {:error, :already_exists, "Periods already generated for company #{comcod} year #{fyear}"}
      else
        total_periods = variant.numper + variant.numspe

        period_records =
          Enum.map(1..total_periods, fn perid ->
            %PostingPeriodControl{
              comcod: comcod,
              ppvid: ppvid,
              fyear: fyear,
              perid: perid,
              persta: if(perid == 1, do: "X", else: "C"),
              peropn: if(perid == 1, do: Date.utc_today(), else: nil),
              percls: nil
            }
          end)

        Repo.insert_all(PostingPeriodControl, period_records)
        {:ok, period_records}
      end
    end
  end

  defp get_posting_period_variant(ppvid) do
    case Repo.get(PostingPeriodVariant, ppvid) do
      nil -> {:error, :not_found, "Posting Period Variant #{ppvid} not found"}
      variant -> {:ok, variant}
    end
  end
end
