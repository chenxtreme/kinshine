defmodule KinshineWeb.UserLive.Login do
  use KinshineWeb, :live_view

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
              <%= if @current_scope do %>
                <h1 class="card-title text-2xl justify-center">You need to reauthenticate</h1>
                <p class="text-base-content/60 text-sm mt-1">
                  Please confirm your credentials to continue.
                </p>
              <% else %>
                <h1 class="card-title text-2xl justify-center">Welcome back</h1>
                <p class="text-base-content/60 text-sm mt-1">
                  Don't have an account?
                  <.link navigate={~p"/users/register"} class="link link-primary font-semibold">
                    Sign up
                  </.link>
                </p>
              <% end %>
            </div>

            <.form
              :let={f}
              for={@form}
              id="login_form"
              action={~p"/users/log-in"}
              phx-submit="submit"
              phx-trigger-action={@trigger_submit}
            >
              <div class="form-control mb-3">
                <.input
                  readonly={!!@current_scope}
                  field={f[:emails]}
                  type="email"
                  label="Log in with email"
                  autocomplete="username"
                  spellcheck="false"
                  required
                  phx-mounted={JS.focus()}
                />
              </div>
              <div class="form-control mb-5">
                <.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  autocomplete="current-password"
                  spellcheck="false"
                />
              </div>

              <.button class="btn btn-primary w-full" name={@form[:remember_me].name} value="true">
                Log in <span aria-hidden="true">→</span>
              </.button>
              <div class="divider text-xs text-base-content/30">or</div>
              <.button class="btn btn-ghost btn-sm w-full">
                Log in for this session only
              </.button>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:emails)])

    form = to_form(%{"emails" => email}, as: "user")
    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit", %{"user" => %{"password" => password}}, socket)
      when password != "" do
    # Password provided — trigger form POST to controller
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit", %{"user" => %{"emails" => email}}, socket) do
    # Email only — send magic link
    if user = Kinshine.Accounts.get_user_by_email(email) do
      Kinshine.Accounts.deliver_login_instructions(
        user,
        fn token -> url(~p"/users/log-in/#{token}") end
      )
    end

    info = "If your email is in our system, you will receive a login link in your inbox shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end
end
