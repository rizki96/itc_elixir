defmodule MyBlog.Repo.Migrations.CreateBlog do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :title, :string
      add :content, :string

      timestamps()
    end

  end
end
