defmodule Starling.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :body, :string
    field :published_at, :date
    field :draft, :boolean, default: false
    field :user_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs, user_scope) do
    post
    |> cast(attrs, [:title, :slug, :description, :body, :published_at, :draft])
    |> validate_required([:title, :slug, :description, :body, :published_at, :draft])
    |> put_change(:user_id, user_scope.user.id)
  end
end
