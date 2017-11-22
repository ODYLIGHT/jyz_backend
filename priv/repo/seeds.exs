# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     JyzBackend.Repo.insert!(%JyzBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias JyzBackend.{Repo,User}

admin = 
  %User{
    username: "admin",
    password_hash: Comeonin.Pbkdf2.hashpwsalt("admin123"),
    email: "admin@phx.com",
    fullname: "WangLei",
    position: "Administrator",
    permissions: 255,
    active: true,
    is_admin: true
  }

user01 = 
  %User{
    username: "user01",
    password_hash: Comeonin.Pbkdf2.hashpwsalt("user01"),
    email: "user01@phx.com",
    fullname: "LiMing",
    permissions: 240,
    active: true,
    is_admin: false
  }

Repo.insert(admin)
Repo.insert(user01)
