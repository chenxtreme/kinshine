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
    Repo.all(from m in Menu, preload: :page)
  end

  def list_root_menus do
    Repo.all(from m in Menu, where: is_nil(m.menpar), order_by: m.mensrt, preload: :page)
  end

  def list_accessible_menus_for_user(userid) do
    accessible_page_ids = list_accessible_page_ids_for_user(userid)

    menus =
      Repo.all(
        from m in Menu,
          order_by: [asc: m.mensrt, asc: m.mennam],
          preload: :page
      )

    visible_menu_ids = visible_menu_ids(menus, accessible_page_ids)

    Enum.filter(menus, &MapSet.member?(visible_menu_ids, &1.menuid))
  end

  def list_accessible_root_menus_for_user(userid) do
    userid
    |> list_accessible_menus_for_user()
    |> Enum.filter(&is_nil(&1.menpar))
    |> Enum.sort_by(&{&1.mensrt, &1.mennam})
  end

  def list_child_menus(parent_menuid) do
    Repo.all(from m in Menu, where: m.menpar == ^parent_menuid, order_by: m.mensrt)
  end

  def get_menu!(menuid), do: Repo.get!(Menu, menuid)

  def create_menu(attrs \\ %{}) do
    %Menu{}
    |> change_menu(attrs)
    |> Repo.insert()
  end

  def update_menu(%Menu{} = menu, attrs) do
    menu
    |> change_menu(attrs)
    |> Repo.update()
  end

  def delete_menu(%Menu{} = menu) do
    Repo.delete(menu)
  end

  def change_menu(%Menu{} = menu, attrs \\ %{}) do
    menu
    |> Menu.changeset(attrs)
    |> validate_parent_menu(changeset_parent_menu_id(attrs, menu))
    |> validate_linked_menu_leaf(menu)
    |> validate_unique_sort_order(menu)
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

  def list_accessible_page_ids_for_user(userid) do
    userid
    |> list_pages_for_user()
    |> Enum.map(& &1.pageid)
    |> MapSet.new()
  end

  def menu_has_children?(menuid) when is_binary(menuid) do
    Repo.exists?(from m in Menu, where: m.menpar == ^menuid)
  end

  defp visible_menu_ids(menus, accessible_page_ids) do
    children_by_parent = Enum.group_by(menus, & &1.menpar)

    {visible_ids, _} =
      collect_visible_menu_ids(
        children_by_parent[nil] || [],
        children_by_parent,
        accessible_page_ids
      )

    visible_ids
  end

  defp collect_visible_menu_ids(menus, children_by_parent, accessible_page_ids) do
    Enum.reduce(menus, {MapSet.new(), false}, fn menu, {visible_ids, any_visible?} ->
      child_menus = Map.get(children_by_parent, menu.menuid, [])

      {child_visible_ids, child_visible?} =
        collect_visible_menu_ids(child_menus, children_by_parent, accessible_page_ids)

      # Menu is visible if:
      # 1. It has a linked page AND user has access to that page, OR
      # 2. It has a direct link (mnlink) — always visible, OR
      # 3. It has no pageid and no mnlink (folder) — visible if any child is visible
      menu_visible? =
        cond do
          menu.mnlink -> true
          menu.pageid -> MapSet.member?(accessible_page_ids, menu.pageid) or child_visible?
          true -> child_visible?
        end

      visible_ids = MapSet.union(visible_ids, child_visible_ids)

      if menu_visible? do
        {MapSet.put(visible_ids, menu.menuid), true}
      else
        {visible_ids, any_visible?}
      end
    end)
  end

  defp changeset_parent_menu_id(attrs, menu) do
    case attrs do
      %{} ->
        menpar = Map.get(attrs, "menpar") || Map.get(attrs, :menpar, menu.menpar)

        if menpar == "", do: nil, else: menpar

      _ ->
        menu.menpar
    end
  end

  defp validate_parent_menu(changeset, nil), do: changeset

  defp validate_parent_menu(changeset, parent_menu_id) do
    case Repo.get(Menu, parent_menu_id) do
      %Menu{pageid: pageid} when not is_nil(pageid) ->
        Ecto.Changeset.add_error(
          changeset,
          :menpar,
          "cannot be added under a menu that already has a linked page"
        )

      %Menu{mnlink: mnlink} when not is_nil(mnlink) ->
        Ecto.Changeset.add_error(
          changeset,
          :menpar,
          "cannot be added under a menu that already has a link"
        )

      _ ->
        changeset
    end
  end

  defp validate_linked_menu_leaf(changeset, %Menu{menuid: nil}), do: changeset

  defp validate_linked_menu_leaf(changeset, %Menu{} = menu) do
    case Ecto.Changeset.get_field(changeset, :pageid) do
      nil ->
        changeset

      pageid when pageid == menu.pageid ->
        changeset

      _pageid ->
        if menu_has_children?(menu.menuid) do
          Ecto.Changeset.add_error(
            changeset,
            :pageid,
            "cannot be linked while the menu still has child items"
          )
        else
          changeset
        end
    end
  end

  defp validate_unique_sort_order(changeset, %Menu{} = menu) do
    mensrt = Ecto.Changeset.get_field(changeset, :mensrt)
    menpar = Ecto.Changeset.get_field(changeset, :menpar)

    cond do
      is_nil(mensrt) ->
        changeset

      is_nil(menu.menuid) ->
        # New record: check if any existing menu with same parent has this sort order
        if sort_order_exists?(mensrt, menpar, nil) do
          Ecto.Changeset.add_error(
            changeset,
            :mensrt,
            "has already been taken for this parent menu"
          )
        else
          changeset
        end

      true ->
        # Existing record: exclude self when checking
        if sort_order_exists?(mensrt, menpar, menu.menuid) do
          Ecto.Changeset.add_error(
            changeset,
            :mensrt,
            "has already been taken for this parent menu"
          )
        else
          changeset
        end
    end
  end

  defp sort_order_exists?(mensrt, menpar, exclude_menuid) do
    query =
      if is_nil(menpar) do
        from m in Menu, where: m.mensrt == ^mensrt and is_nil(m.menpar)
      else
        from m in Menu, where: m.mensrt == ^mensrt and m.menpar == ^menpar
      end

    if exclude_menuid do
      Repo.exists?(from m in query, where: m.menuid != ^exclude_menuid)
    else
      Repo.exists?(query)
    end
  end
end
