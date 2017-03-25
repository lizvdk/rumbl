defmodule Rumbl.Auth do
  import Plug.Conn

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
end
