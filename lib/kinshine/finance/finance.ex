defmodule Kinshine.Finance do
  @moduledoc """
  Public API for the Finance module.
  Delegates to sub-context modules (Organizational, etc).
  This is the ONLY entry point for external modules to access Finance data.
  """
  alias Kinshine.Finance.Organizational

  # ============================================================
  # DELEGATE TO ORGANIZATIONAL CONTEXT
  # ============================================================

  # Company Code
  defdelegate list_company_codes, to: Organizational
  defdelegate get_company_code!(comcod), to: Organizational
  defdelegate create_company_code(attrs), to: Organizational
  defdelegate update_company_code(company_code, attrs), to: Organizational
  defdelegate delete_company_code(company_code), to: Organizational
  defdelegate change_company_code(company_code, attrs), to: Organizational

  # Fiscal Year Variant
  defdelegate list_fiscal_year_variants, to: Organizational
  defdelegate get_fiscal_year_variant!(fyyid), to: Organizational
  defdelegate create_fiscal_year_variant(attrs), to: Organizational
  defdelegate update_fiscal_year_variant(variant, attrs), to: Organizational
  defdelegate delete_fiscal_year_variant(variant), to: Organizational
  defdelegate change_fiscal_year_variant(variant, attrs), to: Organizational

  # Posting Period Variant
  defdelegate list_posting_period_variants, to: Organizational
  defdelegate get_posting_period_variant!(ppvid), to: Organizational
  defdelegate create_posting_period_variant(attrs), to: Organizational
  defdelegate update_posting_period_variant(variant, attrs), to: Organizational
  defdelegate delete_posting_period_variant(variant), to: Organizational
  defdelegate change_posting_period_variant(variant, attrs), to: Organizational

  # Posting Period Control
  defdelegate list_posting_period_controls, to: Organizational
  defdelegate list_posting_period_controls_by_company(comcod), to: Organizational
  defdelegate get_posting_period_control!(ppcid), to: Organizational
  defdelegate create_posting_period_control(attrs), to: Organizational
  defdelegate update_posting_period_control(control, attrs), to: Organizational
  defdelegate delete_posting_period_control(control), to: Organizational
  defdelegate change_posting_period_control(control, attrs), to: Organizational

  # Account Group
  defdelegate list_account_groups, to: Organizational
  defdelegate get_account_group!(acgid), to: Organizational
  defdelegate create_account_group(attrs), to: Organizational
  defdelegate update_account_group(account_group, attrs), to: Organizational
  defdelegate delete_account_group(account_group), to: Organizational
  defdelegate change_account_group(account_group, attrs), to: Organizational

  # GL Account Master
  defdelegate list_gl_account_masters, to: Organizational
  defdelegate get_gl_account_master!(acnum), to: Organizational
  defdelegate create_gl_account_master(attrs), to: Organizational
  defdelegate update_gl_account_master(account, attrs), to: Organizational
  defdelegate delete_gl_account_master(account), to: Organizational
  defdelegate change_gl_account_master(account, attrs), to: Organizational

  # Chart of Account
  defdelegate list_chart_of_accounts, to: Organizational
  defdelegate get_chart_of_account!(coaid), to: Organizational
  defdelegate create_chart_of_account(attrs), to: Organizational
  defdelegate update_chart_of_account(coa, attrs), to: Organizational
  defdelegate delete_chart_of_account(coa), to: Organizational
  defdelegate change_chart_of_account(coa, attrs), to: Organizational

  # COA GL Account
  defdelegate list_coa_gl_accounts, to: Organizational
  defdelegate list_coa_gl_accounts_by_coa(coaid), to: Organizational
  defdelegate get_coa_gl_account!(coaid, acnum), to: Organizational
  defdelegate create_coa_gl_account(attrs), to: Organizational
  defdelegate delete_coa_gl_account(coa_gl), to: Organizational
  defdelegate change_coa_gl_account(coa_gl, attrs), to: Organizational
end
