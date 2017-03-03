defmodule MyBlog.BlogController do
  use MyBlog.Web, :controller

  #import Logger
  alias MyBlog.Blog
  alias MyBlog.Counter

  def index(conn, %{"test" => test}) when test != "", do: render(conn, "index.html", test: test)

  def index(conn, %{"keyword" => keyword} = _params) when keyword != nil and keyword != "" do
    query = from(b in Blog,
                where: like(b.title, ^("%#{keyword}%")))
    blogs = Repo.all(query)
    render(conn, "index.html", blogs: blogs)
  end

  def index(conn, _params) do
    blogs = Repo.all(Blog)
    render(conn, "index.html", blogs: blogs)
  end

  def new(conn, _params) do
    changeset = Blog.changeset(%Blog{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"blog" => blog_params}) do
    changeset = Blog.changeset(%Blog{}, blog_params)

    case Repo.insert(changeset) do
      {:ok, _blog} ->
        conn
        |> put_flash(:info, "Blog created successfully.")
        |> redirect(to: blog_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    blog = Repo.get!(Blog, id)
    counter = Counter.increment(id, 1)

    render(conn, "show.html", blog: blog, counter: counter)
  end

  def edit(conn, %{"id" => id}) do
    blog = Repo.get!(Blog, id)
    changeset = Blog.changeset(blog)
    render(conn, "edit.html", blog: blog, changeset: changeset)
  end

  def update(conn, %{"id" => id, "blog" => blog_params}) do
    blog = Repo.get!(Blog, id)
    changeset = Blog.changeset(blog, blog_params)

    case Repo.update(changeset) do
      {:ok, blog} ->
        conn
        |> put_flash(:info, "Blog updated successfully.")
        |> redirect(to: blog_path(conn, :show, blog))
      {:error, changeset} ->
        render(conn, "edit.html", blog: blog, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    blog = Repo.get!(Blog, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(blog)

    conn
    |> put_flash(:info, "Blog deleted successfully.")
    |> redirect(to: blog_path(conn, :index))
  end
end
