defmodule Kinshine.Finance.Process.AccountValidation do
  @moduledoc """
  Business process for validating GL Account creation and maintenance.
  Ensures account number format, uniqueness, and proper grouping.
  """
  import Ecto.Query, only: [from: 2]

  alias Kinshine.Repo

  @doc """
  Validates if an account number follows the standard format.
  SAP-style: accounts typically start with specific ranges based on type.
  """
  def validate_account_number(acnum, acgtyp) do
    cond do
      String.length(acnum) < 4 ->
        {:error, "Account number must be at least 4 characters"}

      String.length(acnum) > 10 ->
        {:error, "Account number must not exceed 10 characters"}

      not String.match?(acnum, ~r/^[0-9]+$/) ->
        {:error, "Account number must be numeric"}

      not valid_account_range?(acnum, acgtyp) ->
        {:error, "Account number range not valid for account type #{acgtyp}"}

      true ->
        :ok
    end
  end

  @doc """
  Checks if an account exists in the Chart of Accounts assigned to a company.
  """
  def account_in_coa?(comcod, acnum) do
    import Ecto.Query

    # Get the company's COA first, then check if account exists in that COA
    company = Kinshine.Finance.get_company_code!(comcod)

    if company.coaid do
      Repo.exists?(
        from c in Kinshine.Finance.Organizational.CoaGLAccount,
          where: c.coaid == ^company.coaid and c.acnum == ^acnum
      )
    else
      false
    end
  end

  defp valid_account_range?(acnum, acgtyp) do
    first_digit = String.first(acnum)

    case acgtyp do
      # Asset: 1xxxxx
      "A" -> first_digit in ["1"]
      # Liability: 2xxxxx
      "L" -> first_digit in ["2"]
      # Equity: 3xxxxx
      "E" -> first_digit in ["3"]
      # Revenue: 4xxxxx
      "R" -> first_digit in ["4"]
      # Cost: 5-9xxxxx
      "C" -> first_digit in ["5", "6", "7", "8", "9"]
      _ -> true
    end
  end
end
