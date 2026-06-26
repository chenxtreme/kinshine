alias Kinshine.Repo
alias Kinshine.Accounts.User
alias Kinshine.Basis.Menu

# Tampilkan semua user yang ada
users = Repo.all(User)
IO.puts("=== Semua User di Database ===")
Enum.each(users, fn u ->
  IO.puts("  Email: #{u.emails} | ID: #{u.userid} | Confirmed: #{u.confirmed_at} | Hash: #{u.passwd}")
end)

# Tampilkan semua menu yang ada
menus = Repo.all(Menu)
IO.puts("")
IO.puts("=== Semua Menu di Database ===")
IO.puts("Total: #{length(menus)}")
Enum.each(menus, fn m ->
  IO.puts("  #{m.mennam} | Link: #{m.mnlink} | Parent: #{m.menpar} | PageID: #{m.pageid}")
end)
