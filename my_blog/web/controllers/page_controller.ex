defmodule MyBlog.PageController do
  use MyBlog.Web, :controller

  alias MyBlog.Repo
  alias MyBlog.Blog

  def index(conn, _params) do
    popular_blogs_query = from(b in blog_query(3, false))
    popular_blogs = Repo.all(popular_blogs_query)

    commented_blogs_query = from(b in blog_query(3))
    commented_blogs = Repo.all(commented_blogs_query)

    conn
    |> assign(:popular_blogs, popular_blogs)
    |> assign(:commented_blogs, commented_blogs)
    |> render("index.html")
  end

  defp blog_query(limit, is_asc \\ true) do
    if is_asc == true do
      from(b in Blog, limit: ^limit, order_by: [asc: b.inserted_at])
    else
      from(b in Blog, limit: ^limit, order_by: [desc: b.inserted_at])
    end
  end
end
