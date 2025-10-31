defmodule StarlingWeb.PostHTML do
  use StarlingWeb, :html

  embed_templates "post_html/*"

  @doc """
  Renders a post form.

  The form is defined in the template at
  post_html/post_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def post_form(assigns)

  @doc """
  Renders the blog section header.

  ## Examples

      <.blog_header>
        <:title>From the blog</:title>
        <:description>Latest posts and articles</:description>
      </.blog_header>
  """
  slot :title, required: true
  slot :description

  def blog_header(assigns) do
    ~H"""
    <div class="blog-header">
      <h2 class="blog-title">{render_slot(@title)}</h2>
      <p :if={@description != []} class="blog-description">{render_slot(@description)}</p>
    </div>
    """
  end

  @doc """
  Renders a blog post card.

  ## Examples

      <.blog_card
        post={@post}
        image_url="https://example.com/image.jpg"
        category="Article"
        author_name="John Doe"
        author_avatar="https://example.com/avatar.jpg"
      />
  """
  attr :post, :map, required: true

  attr :image_url, :string,
    default: "https://images.unsplash.com/photo-1496128858413-b36217c2ce36?w=800&q=80"

  attr :category, :string, default: "Article"
  attr :author_name, :string, default: "Anonymous"

  attr :author_avatar, :string,
    default: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=256&q=80"

  attr :read_time, :string, default: nil

  def blog_card(assigns) do
    # Calculate read time if not provided (assuming 200 words per minute)
    assigns =
      assign_new(assigns, :calculated_read_time, fn ->
        if assigns.read_time do
          assigns.read_time
        else
          word_count = String.split(assigns.post.body || "", ~r/\s+/) |> length()
          minutes = max(1, div(word_count, 200))
          "#{minutes} min read"
        end
      end)

    ~H"""
    <div class="blog-card">
      <div class="blog-card-image-wrapper">
        <.link navigate={~p"/posts/#{@post}"} class="blog-card-image">
          <img src={@image_url} alt="" class="blog-card-image" />
        </.link>
      </div>
      <div class="blog-card-content">
        <div class="blog-card-body">
          <p class="blog-card-category">
            <a href="#" class="blog-card-category">{@category}</a>
          </p>
          <.link navigate={~p"/posts/#{@post}"} class="blog-card-title-link">
            <h3 class="blog-card-title">
              {@post.title}
              <span :if={@post.draft} class="blog-card-draft-badge">Draft</span>
            </h3>
            <p class="blog-card-description">{@post.description}</p>
          </.link>
        </div>
        <div class="blog-card-footer">
          <div class="blog-card-author-avatar-wrapper">
            <a href="#" class="blog-card-author-link">
              <span class="sr-only">{@author_name}</span>
              <img src={@author_avatar} alt="" class="blog-card-author-avatar" />
            </a>
          </div>
          <div class="blog-card-author-info">
            <p>
              <a href="#" class="blog-card-author-name">{@author_name}</a>
            </p>
            <div class="blog-card-meta">
              <time datetime={@post.published_at}>
                {Calendar.strftime(@post.published_at, "%b %d, %Y")}
              </time>
              <span class="blog-card-meta-separator" aria-hidden="true">&middot;</span>
              <span>{@calculated_read_time}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a grid of blog post cards.

  ## Examples

      <.blog_grid posts={@posts} />
  """
  attr :posts, :list, required: true
  attr :class, :string, default: nil

  def blog_grid(assigns) do
    ~H"""
    <div class={["blog-grid", @class]}>
      <.blog_card :for={post <- @posts} post={post} />
    </div>
    """
  end
end
