defmodule StarlingWeb.PageController do
  use StarlingWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
