defmodule Starling.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias Starling.Repo

  alias Starling.Posts.Post
  alias Starling.Accounts.Scope

  @doc """
  Returns the list of posts.

  For admins: returns all posts
  For non-admins: returns only published posts (not drafts) with published_at <= today

  ## Examples

      iex> list_posts(scope)
      [%Post{}, ...]

  """
  def list_posts(%Scope{user: %{admin: true}}) do
    Post
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  def list_posts(_) do
    today = Date.utc_today()

    Post
    |> where([p], p.draft == false)
    |> where([p], p.published_at <= ^today)
    |> order_by([p], desc: p.published_at)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  For admins: returns any post
  For non-admins: returns only published posts (not drafts) with published_at <= today

  Raises `Ecto.NoResultsError` if the Post does not exist or is not accessible.

  ## Examples

      iex> get_post!(scope, 123)
      %Post{}

      iex> get_post!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(%Scope{user: %{admin: true}}, id) do
    Repo.get_by!(Post, id: id)
  end

  def get_post!(_, id) do
    today = Date.utc_today()

    Post
    |> where([p], p.id == ^id)
    |> where([p], p.draft == false)
    |> where([p], p.published_at <= ^today)
    |> Repo.one!()
  end

  @doc """
  Creates a post.

  Only admins can create posts.

  ## Examples

      iex> create_post(scope, %{field: value})
      {:ok, %Post{}}

      iex> create_post(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Scope{user: %{admin: true}} = scope, attrs) do
    with {:ok, post = %Post{}} <-
           %Post{}
           |> Post.changeset(attrs, scope)
           |> Repo.insert() do
      {:ok, post}
    end
  end

  @doc """
  Updates a post.

  Only admins who own the post can update it.

  ## Examples

      iex> update_post(scope, post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(scope, post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Scope{user: %{admin: true}} = scope, %Post{} = post, attrs) do
    true = post.user_id == scope.user.id

    with {:ok, post = %Post{}} <-
           post
           |> Post.changeset(attrs, scope)
           |> Repo.update() do
      {:ok, post}
    end
  end

  @doc """
  Deletes a post.

  Only admins who own the post can delete it.

  ## Examples

      iex> delete_post(scope, post)
      {:ok, %Post{}}

      iex> delete_post(scope, post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Scope{user: %{admin: true}} = scope, %Post{} = post) do
    true = post.user_id == scope.user.id

    with {:ok, post = %Post{}} <-
           Repo.delete(post) do
      {:ok, post}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  Only admins who own the post can change it.

  ## Examples

      iex> change_post(scope, post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Scope{user: %{admin: true}} = scope, %Post{} = post, attrs \\ %{}) do
    true = post.user_id == scope.user.id

    Post.changeset(post, attrs, scope)
  end
end
