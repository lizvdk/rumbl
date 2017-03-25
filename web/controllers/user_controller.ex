defmodule Rumbl.UserController do
  use Rumbl.Web, :controller
  alias Rumbl.User
  plug :authenticate when action in [:index, :show]

  def index(conn, _params) do
    users = Repo.all(Rumbl.User)
    render conn, "index.html", users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(Rumbl.User, id)
    render conn, "show.html", user: user
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp authenticate(conn, _opts) do
    if conn.assigns.current_user do
      conn # return the conn unchanged if there is a current_user
    else # no current_user
      conn
      |> put_flash(:error, "You must be logged in to access that page") # flash error msg
      |> redirect(to: page_path(conn, :index)) # redirect to index
      |> halt() # stop any downstream transformations
    end
  end
end
