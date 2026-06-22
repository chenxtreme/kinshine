defmodule Kinshine.Basis do
  @moduledoc """
  The Basis context — ERP foundation module.

  Manages Profiles (BPROF), Pages (BPAGE), Menu structure (BMENU),
  and their Many-to-Many relationships via pivot tables BUSPR and BPRPG.
  """

  import Ecto.Query, warn: false
  alias Kinshine.Repo

  alias Kinshine.Basis.{Profile, Page, Menu, UserProfile, ProfilePage}

  # ---------------------------------------------------------------------------
  # Profile (BPROF)
  # ---------------------------------------------------------------------------

  def list_profiles do
    Repo.all(Profile)
  end

  def get_profile!(profid), do: Repo.get!(Profile, profid)

  def create_profile(attrs \\ %{}) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  # ---------------------------------------------------------------------------
  # Page (BPAGE)
  # ---------------------------------------------------------------------------

  def list_pages do
    Repo.all(Page)
  end

  def get_page!(pageid), do: Repo.get!(Page, pageid)

  def create_page(attrs \\ %{}) do
    %Page{}
    |> Page.changeset(attrs)
    |> Repo.insert()
  end

  def update_page(%Page{} = page, attrs) do
    page
    |> Page.changeset(attrs)
    |> Repo.update()
  end

  def delete_page(%Page{} = page) do
    Repo.delete(page)
  end

  def change_page(%Page{} = page, attrs \\ %{}) do
    Page.changeset(page, attrs)
  end

  # ---------------------------------------------------------------------------
  # Menu (BMENU)
  # ---------------------------------------------------------------------------

  def list_menus do
    Repo.all(Menu)
  end

  def list_root_menus do
    Repo.all(from m in Menu, where: is_nil(m.menpar), order_by: m.mensrt)
  end

  def list_child_menus(parent_menuid) do
    Repo.all(from m in Menu, where: m.menpar == ^parent_menuid, order_by: m.mensrt)
  end

  def get_menu!(menuid), do: Repo.get!(Menu, menuid)

  def create_menu(attrs \\ %{}) do
    %Menu{}
    |> Menu.changeset(attrs)
    |> Repo.insert()
  end

  def update_menu(%Menu{} = menu, attrs) do
    menu
    |> Menu.changeset(attrs)
    |> Repo.update()
  end

  def delete_menu(%Menu{} = menu) do
    Repo.delete(menu)
  end

  def change_menu(%Menu{} = menu, attrs \\ %{}) do
    Menu.changeset(menu, attrs)
  end

  # ---------------------------------------------------------------------------
  # BUSPR — User <-> Profile assignments
  # ---------------------------------------------------------------------------

  def assign_profile_to_user(userid, profid) do
    %UserProfile{}
    |> UserProfile.changeset(%{userid: userid, profid: profid})
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove_profile_from_user(userid, profid) do
    Repo.delete_all(from up in UserProfile, where: up.userid == ^userid and up.profid == ^profid)
    :ok
  end

  def list_profiles_for_user(userid) do
    Repo.all(
      from p in Profile,
        join: up in UserProfile,
        on: up.profid == p.profid,
        where: up.userid == ^userid
    )
  end

  # ---------------------------------------------------------------------------
  # BPRPG — Profile <-> Page assignments
  # ---------------------------------------------------------------------------

  def assign_page_to_profile(profid, pageid) do
    %ProfilePage{}
    |> ProfilePage.changeset(%{profid: profid, pageid: pageid})
    |> Repo.insert(on_conflict: :nothing)
  end

  def remove_page_from_profile(profid, pageid) do
    Repo.delete_all(from pp in ProfilePage, where: pp.profid == ^profid and pp.pageid == ^pageid)
    :ok
  end

  def list_pages_for_profile(profid) do
    Repo.all(
      from p in Page,
        join: pp in ProfilePage,
        on: pp.pageid == p.pageid,
        where: pp.profid == ^profid
    )
  end

  def list_pages_for_user(userid) do
    Repo.all(
      from p in Page,
        join: pp in ProfilePage,
        on: pp.pageid == p.pageid,
        join: up in UserProfile,
        on: up.profid == pp.profid,
        where: up.userid == ^userid,
        distinct: true
    )
  end
end
