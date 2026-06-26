defmodule Kinshine.BasisTest do
  use Kinshine.DataCase

  import Kinshine.AccountsFixtures

  alias Kinshine.Basis

  test "list_accessible_menus_for_user returns union of pages across profiles" do
    user = user_fixture()

    {:ok, profile_a} = Basis.create_profile(%{pronam: "Profile A"})
    {:ok, profile_b} = Basis.create_profile(%{pronam: "Profile B"})

    {:ok, dashboard_page} =
      Basis.create_page(%{pagtit: "Dashboard", pagurl: "/dashboard"})

    {:ok, reports_page} =
      Basis.create_page(%{pagtit: "Reports", pagurl: "/reports"})

    {:ok, hidden_page} =
      Basis.create_page(%{pagtit: "Hidden", pagurl: "/hidden"})

    assert {:ok, _} = Basis.assign_profile_to_user(user.userid, profile_a.profid)
    assert {:ok, _} = Basis.assign_profile_to_user(user.userid, profile_b.profid)

    assert {:ok, _} = Basis.assign_page_to_profile(profile_a.profid, dashboard_page.pageid)
    assert {:ok, _} = Basis.assign_page_to_profile(profile_a.profid, dashboard_page.pageid)
    assert {:ok, _} = Basis.assign_page_to_profile(profile_b.profid, dashboard_page.pageid)
    assert {:ok, _} = Basis.assign_page_to_profile(profile_b.profid, reports_page.pageid)

    {:ok, configuration_menu} = Basis.create_menu(%{mennam: "Configuration", mensrt: 10})
    {:ok, admin_menu} = Basis.create_menu(%{mennam: "Admin", mensrt: 20})

    {:ok, dashboard_menu} =
      Basis.create_menu(%{mennam: "Dashboard", mensrt: 5, pageid: dashboard_page.pageid})

    {:ok, reports_menu} =
      Basis.create_menu(%{
        mennam: "Reports",
        mensrt: 10,
        menpar: configuration_menu.menuid,
        pageid: reports_page.pageid
      })

    {:ok, hidden_menu} =
      Basis.create_menu(%{
        mennam: "Hidden",
        mensrt: 10,
        menpar: admin_menu.menuid,
        pageid: hidden_page.pageid
      })

    accessible_page_ids = Basis.list_accessible_page_ids_for_user(user.userid)

    assert MapSet.equal?(
             accessible_page_ids,
             MapSet.new([dashboard_page.pageid, reports_page.pageid])
           )

    menus = Basis.list_accessible_menus_for_user(user.userid)
    menu_ids = MapSet.new(Enum.map(menus, & &1.menuid))

    assert MapSet.member?(menu_ids, dashboard_menu.menuid)
    assert MapSet.member?(menu_ids, configuration_menu.menuid)
    assert MapSet.member?(menu_ids, reports_menu.menuid)
    refute MapSet.member?(menu_ids, admin_menu.menuid)
    refute MapSet.member?(menu_ids, hidden_menu.menuid)

    root_menus = Basis.list_accessible_root_menus_for_user(user.userid)

    assert Enum.map(root_menus, & &1.menuid) == [dashboard_menu.menuid, configuration_menu.menuid]
  end

  test "create_menu rejects children under a linked parent menu" do
    {:ok, linked_page} = Basis.create_page(%{pagtit: "Dashboard", pagurl: "/dashboard"})

    {:ok, parent_menu} =
      Basis.create_menu(%{mennam: "Dashboard", mensrt: 1, pageid: linked_page.pageid})

    assert {:error, changeset} =
             Basis.create_menu(%{
               mennam: "Forbidden Child",
               mensrt: 2,
               menpar: parent_menu.menuid
             })

    assert "cannot be added under a menu that already has a linked page" in errors_on(changeset).menpar
  end

  test "update_menu rejects linking a menu that already has child items" do
    {:ok, parent_menu} = Basis.create_menu(%{mennam: "Configuration", mensrt: 1})

    {:ok, _child_menu} =
      Basis.create_menu(%{mennam: "Reports", mensrt: 2, menpar: parent_menu.menuid})

    {:ok, linked_page} = Basis.create_page(%{pagtit: "Configuration", pagurl: "/configuration"})

    assert {:error, changeset} = Basis.update_menu(parent_menu, %{pageid: linked_page.pageid})

    assert "cannot be linked while the menu still has child items" in errors_on(changeset).pageid
  end
end
