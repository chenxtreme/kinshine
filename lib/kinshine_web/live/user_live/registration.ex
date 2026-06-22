defmodule KinshineWeb.UserLive.Registration do
  use KinshineWeb, :live_view

  alias Kinshine.Accounts
  alias Kinshine.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="w-full max-w-sm mx-auto">
        <div class="text-center mb-6">
          <h2 class="text-3xl font-extrabold text-primary tracking-tight">Kinshine</h2>
          <p class="text-base-content/40 text-xs mt-1">App Management Platform</p>
        </div>
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body gap-4">
            <div class="text-center">
              <h1 class="card-title text-2xl justify-center">Create Account</h1>
              <p class="text-base-content/60 text-sm mt-1">
                Already have an account?
                <.link navigate={~p"/users/log-in"} class="link link-primary font-semibold">
                  Log in
                </.link>
              </p>
            </div>

            <.form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
              <div class="form-control mb-3">
                <.input
                  field={@form[:emails]}
                  type="email"
                  label="Email"
                  autocomplete="username"
                  spellcheck="false"
                  required
                  phx-mounted={JS.focus()}
                />
              </div>
              <div class="form-control mb-3">
                <.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  autocomplete="new-password"
                  spellcheck="false"
                  required
                />
                <div class="label">
                  <span class="label-text-alt text-base-content/50">Minimum 12 characters</span>
                </div>
              </div>
              <div class="form-control mb-5">
                <.input
                  field={@form[:password_confirmation]}
                  type="password"
                  label="Confirm Password"
                  autocomplete="new-password"
                  spellcheck="false"
                  required
                />
              </div>

              <.button phx-disable-with="Creating account…" class="btn btn-primary w-full">
                Create Account
              </.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: KinshineWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "An email was sent to #{user.emails}, please access it to confirm your account."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
