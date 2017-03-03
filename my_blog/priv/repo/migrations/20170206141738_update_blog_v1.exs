defmodule MyBlog.Repo.Migrations.UpdateBlogV1 do
  use Ecto.Migration

  def change do
    alter table(:blogs) do
      add :counter, :integer
    end
  end
end
