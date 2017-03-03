defmodule MyBlog.Blog do
  use MyBlog.Web, :model

  schema "blogs" do
    field :title, :string
    field :content, :string
    field :counter, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content, :counter])
    |> validate_required([:title, :content])
  end
end
