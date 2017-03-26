defmodule Rumbl.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller
  alias Rumbl.Router.Helpers

  def init(opts) do
    Keyword.fetch!(opts, :repo) # extract repo from the given opts; raise exception if repo doesn't exist
  end

  def call(conn, repo) do # recieves repo from init
    user_id = get_session(conn, :user_id) # check if user_id is stored in the session
    user = user_id && repo.get(Rumbl.User, user_id) # look up user_id
    assign(conn, :current_user, user) # assign user in connection, avail as `current_user`
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user) # stores given user as `:current_user` assign
    |> put_session(:user_id, user.id) # puts user in the session
    |> configure_session(renew: true) # configures session & protects from session fixation attacks
  end

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn # return the conn unchanged if there is a current_user
    else # no current_user
      conn
      |> put_flash(:error, "You must be logged in to access that page") # flash error msg
      |> redirect(to: Helpers.page_path(conn, :index)) # redirect to index
      |> halt() # stop any downstream transformations
    end
  end
end
