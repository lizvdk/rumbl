defmodule Rumbl.User do
  use Rumbl.Web, :model

  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video
    has_many :annotations, Rumbl.Annotation

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name username), [])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end

  def registration_changeset(model, params) do
    model
    |> changeset(params) # call first changeset
    |> cast(params, ~w(password), []) # cast first changeset to accept pw param
    |> validate_length(:password, min: 6, max: 100) # validate pw
    |> put_pass_hash() # hash pw and add it to results
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} -> # check if changeset is valid
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass)) # hash pw and put the result into changeset as password_hash
      _ ->
        changeset # return invalid changesets to caller
    end
  end
end
