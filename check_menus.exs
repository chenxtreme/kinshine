# Cek user yang ada
users = Kinshine.Repo.all(Kinshine.Accounts.User)
IO.inspect(users, label: "Users")

# Coba list accessible menus untuk user pertama (jika ada)
if user = List.first(users) do
  IO.puts("\n--- Accessible menus for user: #{user.userid} (#{user.emails}) ---")
  menus = Kinshine.Basis.list_accessible_menus_for_user(user.userid)
  IO.inspect(menus, label: "Accessible Menus")

  IO.puts("\n--- Accessible root menus ---")
  root_menus = Kinshine.Basis.list_accessible_root_menus_for_user(user.userid)
  IO.inspect(root_menus, label: "Root Menus")
else
  IO.puts("No users found!")
end
