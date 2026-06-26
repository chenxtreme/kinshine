import Ecto.Query, only: [from: 2]
alias Kinshine.Repo
alias Kinshine.Basis.Menu

menus = Repo.all(from m in Menu, order_by: [asc: m.insdat])

IO.puts("=== MENU LIST ===")

Enum.each(menus, fn m ->
  parent_info = if m.menpar, do: " (parent: #{m.menpar})", else: ""
  IO.puts("#{m.menuid} | #{m.mennam} | link: #{m.mnlink || "-"}#{parent_info}")
end)
