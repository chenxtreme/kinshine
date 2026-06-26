# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Kinshine.Repo.insert!(%Kinshine.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Kinshine.Repo
alias Kinshine.Finance.Organizational.AccountGroup
alias Kinshine.Finance.Organizational.GLAccountMaster
alias Kinshine.Finance.Organizational.ChartOfAccount
alias Kinshine.Finance.Organizational.CoaGLAccount

IO.puts("=== Seeding Account Groups (FCAGR) ===")

account_groups = [
  %{acgid: "ASET", acgnam: "Aktiva Lancar", acgtyp: "A"},
  %{acgid: "ATET", acgnam: "Aktiva Tetap", acgtyp: "A"},
  %{acgid: "LIAB", acgnam: "Kewajiban Lancar", acgtyp: "L"},
  %{acgid: "LJPP", acgnam: "Kewajiban Jangka Panjang", acgtyp: "L"},
  %{acgid: "EQTY", acgnam: "Ekuitas", acgtyp: "E"},
  %{acgid: "REV", acgnam: "Pendapatan", acgtyp: "R"},
  %{acgid: "REV2", acgnam: "Pendapatan Lain-lain", acgtyp: "R"},
  %{acgid: "COGS", acgnam: "Harga Pokok Penjualan", acgtyp: "C"},
  %{acgid: "BOP", acgnam: "Beban Operasional", acgtyp: "C"},
  %{acgid: "BLN", acgnam: "Beban Lain-lain", acgtyp: "C"}
]

for attrs <- account_groups do
  %AccountGroup{}
  |> AccountGroup.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :acgid)
end

IO.puts("✓ #{length(account_groups)} account groups seeded successfully!")

IO.puts("")
IO.puts("=== Seeding GL Account Masters (FCGLM) ===")

gl_account_masters = [
  # ASET - Aktiva Lancar
  %{
    acnum: "110000",
    acnam: "Kas Kecil",
    acgid: "ASET",
    acdesc: "Uang tunai untuk operasional harian"
  },
  %{
    acnum: "110100",
    acnam: "Kas di Bank",
    acgid: "ASET",
    acdesc: "Saldo rekening giro perusahaan"
  },
  %{
    acnum: "120000",
    acnam: "Piutang Usaha",
    acgid: "ASET",
    acdesc: "Piutang dari pelanggan atas penjualan kredit"
  },
  %{
    acnum: "130000",
    acnam: "Persediaan Barang",
    acgid: "ASET",
    acdesc: "Nilai persediaan barang dagang"
  },
  %{
    acnum: "140000",
    acnam: "Perlengkapan Kantor",
    acgid: "ASET",
    acdesc: "Perlengkapan ATK dan alat tulis kantor"
  },

  # ATET - Aktiva Tetap
  %{acnum: "150000", acnam: "Tanah", acgid: "ATET", acdesc: "Tanah milik perusahaan"},
  %{acnum: "151000", acnam: "Bangunan", acgid: "ATET", acdesc: "Gedung kantor dan fasilitas"},
  %{
    acnum: "152000",
    acnam: "Kendaraan",
    acgid: "ATET",
    acdesc: "Kendaraan operasional perusahaan"
  },
  %{
    acnum: "153000",
    acnam: "Mesin & Peralatan",
    acgid: "ATET",
    acdesc: "Mesin produksi dan peralatan operasional"
  },

  # LIAB - Kewajiban Lancar
  %{
    acnum: "210000",
    acnam: "Hutang Usaha",
    acgid: "LIAB",
    acdesc: "Hutang kepada pemasok atas pembelian kredit"
  },
  %{
    acnum: "211000",
    acnam: "Hutang Gaji",
    acgid: "LIAB",
    acdesc: "Gaji karyawan yang masih harus dibayar"
  },
  %{
    acnum: "212000",
    acnam: "Hutang Pajak",
    acgid: "LIAB",
    acdesc: "Pajak yang masih harus disetor ke negara"
  },

  # LJPP - Kewajiban Jangka Panjang
  %{
    acnum: "220000",
    acnam: "Hutang Bank",
    acgid: "LJPP",
    acdesc: "Pinjaman jangka panjang dari bank"
  },
  %{
    acnum: "221000",
    acnam: "Hutang Obligasi",
    acgid: "LJPP",
    acdesc: "Obligasi yang diterbitkan perusahaan"
  },

  # EQTY - Ekuitas
  %{
    acnum: "310000",
    acnam: "Modal Disetor",
    acgid: "EQTY",
    acdesc: "Modal yang disetor oleh pemegang saham"
  },
  %{
    acnum: "311000",
    acnam: "Laba Ditahan",
    acgid: "EQTY",
    acdesc: "Akumulasi laba yang tidak dibagikan"
  },

  # REV - Pendapatan
  %{
    acnum: "410000",
    acnam: "Penjualan Barang",
    acgid: "REV",
    acdesc: "Pendapatan dari penjualan barang dagang"
  },
  %{
    acnum: "411000",
    acnam: "Penjualan Jasa",
    acgid: "REV",
    acdesc: "Pendapatan dari penjualan jasa"
  },

  # REV2 - Pendapatan Lain-lain
  %{
    acnum: "710000",
    acnam: "Pendapatan Bunga",
    acgid: "REV2",
    acdesc: "Bunga dari deposito dan rekening bank"
  },
  %{
    acnum: "711000",
    acnam: "Pendapatan Sewa",
    acgid: "REV2",
    acdesc: "Pendapatan dari sewa aset perusahaan"
  },

  # COGS - Harga Pokok Penjualan
  %{
    acnum: "510000",
    acnam: "HPP Barang Dagang",
    acgid: "COGS",
    acdesc: "Harga pokok penjualan barang dagang"
  },
  %{acnum: "511000", acnam: "HPP Jasa", acgid: "COGS", acdesc: "Harga pokok penjualan jasa"},

  # BOP - Beban Operasional
  %{acnum: "610000", acnam: "Gaji Karyawan", acgid: "BOP", acdesc: "Gaji dan tunjangan karyawan"},
  %{acnum: "611000", acnam: "Sewa Gedung", acgid: "BOP", acdesc: "Biaya sewa gedung kantor"},
  %{
    acnum: "612000",
    acnam: "Listrik & Air",
    acgid: "BOP",
    acdesc: "Biaya listrik, air, dan utilitas"
  },
  %{
    acnum: "613000",
    acnam: "Transportasi",
    acgid: "BOP",
    acdesc: "Biaya transportasi dan perjalanan dinas"
  },
  %{
    acnum: "614000",
    acnam: "ATK & Perlengkapan",
    acgid: "BOP",
    acdesc: "Alat tulis kantor dan perlengkapan"
  },

  # BLN - Beban Lain-lain
  %{
    acnum: "810000",
    acnam: "Beban Adm. Bank",
    acgid: "BLN",
    acdesc: "Biaya administrasi rekening bank"
  },
  %{acnum: "811000", acnam: "Beban Denda", acgid: "BLN", acdesc: "Denda pajak dan denda lainnya"}
]

for attrs <- gl_account_masters do
  %GLAccountMaster{}
  |> GLAccountMaster.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :acnum)
end

IO.puts("✓ #{length(gl_account_masters)} GL account masters seeded successfully!")

IO.puts("")
IO.puts("=== Seeding Chart of Accounts (FCCOA) ===")

chart_of_accounts = [
  %{coaid: "COAI", coanam: "Chart of Account Indonesia (PSAK)"},
  %{coaid: "COA2", coanam: "Chart of Account US GAAP"}
]

for attrs <- chart_of_accounts do
  %ChartOfAccount{}
  |> ChartOfAccount.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: :coaid)
end

IO.puts("✓ #{length(chart_of_accounts)} chart of accounts seeded successfully!")

IO.puts("")
IO.puts("=== Seeding COA GL Account (FCCGL) ===")

coa_gl_accounts = [
  # COAI - Indonesia PSAK
  %{coaid: "COAI", acnum: "110000"},
  %{coaid: "COAI", acnum: "110100"},
  %{coaid: "COAI", acnum: "120000"},
  %{coaid: "COAI", acnum: "130000"},
  %{coaid: "COAI", acnum: "140000"},
  %{coaid: "COAI", acnum: "150000"},
  %{coaid: "COAI", acnum: "151000"},
  %{coaid: "COAI", acnum: "152000"},
  %{coaid: "COAI", acnum: "153000"},
  %{coaid: "COAI", acnum: "210000"},
  %{coaid: "COAI", acnum: "211000"},
  %{coaid: "COAI", acnum: "212000"},
  %{coaid: "COAI", acnum: "220000"},
  %{coaid: "COAI", acnum: "221000"},
  %{coaid: "COAI", acnum: "310000"},
  %{coaid: "COAI", acnum: "311000"},
  %{coaid: "COAI", acnum: "410000"},
  %{coaid: "COAI", acnum: "411000"},
  %{coaid: "COAI", acnum: "510000"},
  %{coaid: "COAI", acnum: "511000"},
  %{coaid: "COAI", acnum: "610000"},
  %{coaid: "COAI", acnum: "611000"},
  %{coaid: "COAI", acnum: "612000"},
  %{coaid: "COAI", acnum: "613000"},
  %{coaid: "COAI", acnum: "614000"},
  %{coaid: "COAI", acnum: "710000"},
  %{coaid: "COAI", acnum: "711000"},
  %{coaid: "COAI", acnum: "810000"},
  %{coaid: "COAI", acnum: "811000"},

  # COA2 - US GAAP (subset)
  %{coaid: "COA2", acnum: "110000"},
  %{coaid: "COA2", acnum: "110100"},
  %{coaid: "COA2", acnum: "120000"},
  %{coaid: "COA2", acnum: "210000"},
  %{coaid: "COA2", acnum: "310000"},
  %{coaid: "COA2", acnum: "410000"},
  %{coaid: "COA2", acnum: "510000"},
  %{coaid: "COA2", acnum: "610000"}
]

for attrs <- coa_gl_accounts do
  %CoaGLAccount{}
  |> CoaGLAccount.changeset(attrs)
  |> Repo.insert!(on_conflict: :nothing, conflict_target: [:coaid, :acnum])
end

IO.puts("✓ #{length(coa_gl_accounts)} COA GL account assignments seeded successfully!")
