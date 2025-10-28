defmodule StarlingWeb.PostController do
  use StarlingWeb, :controller

  alias Starling.Posts
  alias Starling.Posts.Post

  def index(conn, _params) do
    posts = Posts.list_posts(conn.assigns.current_scope)
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset =
      Posts.change_post(conn.assigns.current_scope, %Post{
        user_id: conn.assigns.current_scope.user.id
      })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(conn.assigns.current_scope, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(conn.assigns.current_scope, id)
    render(conn, :show, post: post)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(conn.assigns.current_scope, id)
    changeset = Posts.change_post(conn.assigns.current_scope, post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(conn.assigns.current_scope, id)

    case Posts.update_post(conn.assigns.current_scope, post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(conn.assigns.current_scope, id)
    {:ok, _post} = Posts.delete_post(conn.assigns.current_scope, post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end
end
