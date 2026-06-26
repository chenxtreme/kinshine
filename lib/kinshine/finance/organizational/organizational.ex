defmodule Kinshine.Finance.Organizational do
  @moduledoc """
  Context module for Organizational Structure (Fase 0) and Chart of Accounts (Fase 1).
  Handles CRUD operations for Company Code, Fiscal Year Variant, Posting Period,
  Account Groups, GL Accounts, and Company Code GL Account assignments.
  """
  import Ecto.Query, only: [from: 2]

  alias Kinshine.Repo

  alias Kinshine.Finance.Organizational.{
    CompanyCode,
    FiscalYearVariant,
    PostingPeriodVariant,
    PostingPeriodControl,
    AccountGroup,
    GLAccountMaster,
    ChartOfAccount,
    CoaGLAccount
  }

  # ============================================================
  # COMPANY CODE (FCCOD)
  # ============================================================

  def list_company_codes do
    Repo.all(CompanyCode)
  end

  def get_company_code!(comcod) do
    Repo.get!(CompanyCode, comcod)
  end

  def create_company_code(attrs \\ %{}) do
    %CompanyCode{}
    |> CompanyCode.changeset(attrs)
    |> Repo.insert()
  end

  def update_company_code(%CompanyCode{} = company_code, attrs) do
    company_code
    |> CompanyCode.changeset(attrs)
    |> Repo.update()
  end

  def delete_company_code(%CompanyCode{} = company_code) do
    Repo.delete(company_code)
  end

  def change_company_code(%CompanyCode{} = company_code, attrs \\ %{}) do
    CompanyCode.changeset(company_code, attrs)
  end

  # Helper function to get all chart of accounts for dropdown
  def list_chart_of_accounts_for_select do
    Repo.all(ChartOfAccount)
    |> Enum.map(fn coa -> {coa.coanam, coa.coaid} end)
  end

  # ============================================================
  # FISCAL YEAR VARIANT (FFYVR)
  # ============================================================

  def list_fiscal_year_variants do
    Repo.all(FiscalYearVariant)
  end

  def get_fiscal_year_variant!(fyyid) do
    Repo.get!(FiscalYearVariant, fyyid)
  end

  def create_fiscal_year_variant(attrs \\ %{}) do
    %FiscalYearVariant{}
    |> FiscalYearVariant.changeset(attrs)
    |> Repo.insert()
  end

  def update_fiscal_year_variant(%FiscalYearVariant{} = variant, attrs) do
    variant
    |> FiscalYearVariant.changeset(attrs)
    |> Repo.update()
  end

  def delete_fiscal_year_variant(%FiscalYearVariant{} = variant) do
    Repo.delete(variant)
  end

  def change_fiscal_year_variant(%FiscalYearVariant{} = variant, attrs \\ %{}) do
    FiscalYearVariant.changeset(variant, attrs)
  end

  # ============================================================
  # POSTING PERIOD VARIANT (FPPVR)
  # ============================================================

  def list_posting_period_variants do
    Repo.all(PostingPeriodVariant)
  end

  def get_posting_period_variant!(ppvid) do
    Repo.get!(PostingPeriodVariant, ppvid)
  end

  def create_posting_period_variant(attrs \\ %{}) do
    %PostingPeriodVariant{}
    |> PostingPeriodVariant.changeset(attrs)
    |> Repo.insert()
  end

  def update_posting_period_variant(%PostingPeriodVariant{} = variant, attrs) do
    variant
    |> PostingPeriodVariant.changeset(attrs)
    |> Repo.update()
  end

  def delete_posting_period_variant(%PostingPeriodVariant{} = variant) do
    Repo.delete(variant)
  end

  def change_posting_period_variant(%PostingPeriodVariant{} = variant, attrs \\ %{}) do
    PostingPeriodVariant.changeset(variant, attrs)
  end

  # ============================================================
  # POSTING PERIOD CONTROL (FPPCN)
  # ============================================================

  def list_posting_period_controls do
    Repo.all(PostingPeriodControl)
  end

  def list_posting_period_controls_by_company(comcod) do
    Repo.all(
      from p in PostingPeriodControl,
        where: p.comcod == ^comcod,
        order_by: [desc: p.fyear, asc: p.perid]
    )
  end

  def get_posting_period_control!(ppcid) do
    Repo.get!(PostingPeriodControl, ppcid)
  end

  def create_posting_period_control(attrs \\ %{}) do
    %PostingPeriodControl{}
    |> PostingPeriodControl.changeset(attrs)
    |> Repo.insert()
  end

  def update_posting_period_control(%PostingPeriodControl{} = control, attrs) do
    control
    |> PostingPeriodControl.changeset(attrs)
    |> Repo.update()
  end

  def delete_posting_period_control(%PostingPeriodControl{} = control) do
    Repo.delete(control)
  end

  def change_posting_period_control(%PostingPeriodControl{} = control, attrs \\ %{}) do
    PostingPeriodControl.changeset(control, attrs)
  end

  # ============================================================
  # ACCOUNT GROUP (FCAGR)
  # ============================================================

  def list_account_groups do
    Repo.all(AccountGroup)
  end

  def get_account_group!(acgid) do
    Repo.get!(AccountGroup, acgid)
  end

  def create_account_group(attrs \\ %{}) do
    %AccountGroup{}
    |> AccountGroup.changeset(attrs)
    |> Repo.insert()
  end

  def update_account_group(%AccountGroup{} = account_group, attrs) do
    account_group
    |> AccountGroup.changeset(attrs)
    |> Repo.update()
  end

  def delete_account_group(%AccountGroup{} = account_group) do
    Repo.delete(account_group)
  end

  def change_account_group(%AccountGroup{} = account_group, attrs \\ %{}) do
    AccountGroup.changeset(account_group, attrs)
  end

  # ============================================================
  # GL ACCOUNT MASTER (FCGLM)
  # ============================================================

  def list_gl_account_masters do
    Repo.all(GLAccountMaster)
  end

  def get_gl_account_master!(acnum) do
    Repo.get!(GLAccountMaster, acnum)
  end

  def create_gl_account_master(attrs \\ %{}) do
    %GLAccountMaster{}
    |> GLAccountMaster.changeset(attrs)
    |> Repo.insert()
  end

  def update_gl_account_master(%GLAccountMaster{} = account, attrs) do
    account
    |> GLAccountMaster.changeset(attrs)
    |> Repo.update()
  end

  def delete_gl_account_master(%GLAccountMaster{} = account) do
    Repo.delete(account)
  end

  def change_gl_account_master(%GLAccountMaster{} = account, attrs \\ %{}) do
    GLAccountMaster.changeset(account, attrs)
  end

  # ============================================================
  # CHART OF ACCOUNT (FCCOA)
  # ============================================================

  def list_chart_of_accounts do
    Repo.all(ChartOfAccount)
  end

  def get_chart_of_account!(coaid) do
    Repo.get!(ChartOfAccount, coaid)
  end

  def create_chart_of_account(attrs \\ %{}) do
    %ChartOfAccount{}
    |> ChartOfAccount.changeset(attrs)
    |> Repo.insert()
  end

  def update_chart_of_account(%ChartOfAccount{} = coa, attrs) do
    coa
    |> ChartOfAccount.changeset(attrs)
    |> Repo.update()
  end

  def delete_chart_of_account(%ChartOfAccount{} = coa) do
    Repo.delete(coa)
  end

  def change_chart_of_account(%ChartOfAccount{} = coa, attrs \\ %{}) do
    ChartOfAccount.changeset(coa, attrs)
  end

  # ============================================================
  # COA GL ACCOUNT (FCCGL)
  # ============================================================

  def list_coa_gl_accounts do
    Repo.all(CoaGLAccount)
  end

  def list_coa_gl_accounts_by_coa(coaid) do
    Repo.all(
      from c in CoaGLAccount,
        where: c.coaid == ^coaid,
        order_by: c.acnum
    )
  end

  def get_coa_gl_account!(coaid, acnum) do
    Repo.get_by!(CoaGLAccount, coaid: coaid, acnum: acnum)
  end

  def create_coa_gl_account(attrs \\ %{}) do
    %CoaGLAccount{}
    |> CoaGLAccount.changeset(attrs)
    |> Repo.insert()
  end

  def delete_coa_gl_account(%CoaGLAccount{} = coa_gl) do
    import Ecto.Query

    Repo.delete_all(
      from c in CoaGLAccount,
        where: c.coaid == ^coa_gl.coaid and c.acnum == ^coa_gl.acnum
    )
    |> case do
      {1, _} -> {:ok, coa_gl}
      {0, _} -> {:error, :not_found}
    end
  end

  def change_coa_gl_account(%CoaGLAccount{} = coa_gl, attrs \\ %{}) do
    CoaGLAccount.changeset(coa_gl, attrs)
  end
end
