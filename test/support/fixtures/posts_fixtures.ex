defmodule Starling.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Starling.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        body: "some body",
        description: "some description",
        draft: true,
        published_at: ~D[2025-10-27],
        slug: "some slug",
        title: "some title"
      })

    {:ok, post} = Starling.Posts.create_post(scope, attrs)
    post
  end
end
