defmodule Starling.PostsTest do
  use Starling.DataCase

  alias Starling.Posts

  describe "posts" do
    alias Starling.Posts.Post

    import Starling.AccountsFixtures, only: [user_scope_fixture: 0]
    import Starling.PostsFixtures

    @invalid_attrs %{description: nil, title: nil, body: nil, slug: nil, published_at: nil, draft: nil}

    test "list_posts/1 returns all scoped posts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope)
      other_post = post_fixture(other_scope)
      assert Posts.list_posts(scope) == [post]
      assert Posts.list_posts(other_scope) == [other_post]
    end

    test "get_post!/2 returns the post with given id" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      other_scope = user_scope_fixture()
      assert Posts.get_post!(scope, post.id) == post
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(other_scope, post.id) end
    end

    test "create_post/2 with valid data creates a post" do
      valid_attrs = %{description: "some description", title: "some title", body: "some body", slug: "some slug", published_at: ~D[2025-10-27], draft: true}
      scope = user_scope_fixture()

      assert {:ok, %Post{} = post} = Posts.create_post(scope, valid_attrs)
      assert post.description == "some description"
      assert post.title == "some title"
      assert post.body == "some body"
      assert post.slug == "some slug"
      assert post.published_at == ~D[2025-10-27]
      assert post.draft == true
      assert post.user_id == scope.user.id
    end

    test "create_post/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(scope, @invalid_attrs)
    end

    test "update_post/3 with valid data updates the post" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      update_attrs = %{description: "some updated description", title: "some updated title", body: "some updated body", slug: "some updated slug", published_at: ~D[2025-10-28], draft: false}

      assert {:ok, %Post{} = post} = Posts.update_post(scope, post, update_attrs)
      assert post.description == "some updated description"
      assert post.title == "some updated title"
      assert post.body == "some updated body"
      assert post.slug == "some updated slug"
      assert post.published_at == ~D[2025-10-28]
      assert post.draft == false
    end

    test "update_post/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope)

      assert_raise MatchError, fn ->
        Posts.update_post(other_scope, post, %{})
      end
    end

    test "update_post/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(scope, post, @invalid_attrs)
      assert post == Posts.get_post!(scope, post.id)
    end

    test "delete_post/2 deletes the post" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert {:ok, %Post{}} = Posts.delete_post(scope, post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(scope, post.id) end
    end

    test "delete_post/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      post = post_fixture(scope)
      assert_raise MatchError, fn -> Posts.delete_post(other_scope, post) end
    end

    test "change_post/2 returns a post changeset" do
      scope = user_scope_fixture()
      post = post_fixture(scope)
      assert %Ecto.Changeset{} = Posts.change_post(scope, post)
    end
  end
end
