# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Mnemo.Repo.insert!(%Mnemo.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Mnemo.Resources.Postgres.Repo.insert!(%Mnemo.Access.Schemas.Student{
  id: "dd48cfda-5f8d-4c9e-8968-04a75ec08df4",
  email: "nikokozak@gmail.com"
})
