defmodule KinshineWeb.DashboardLive do
  use KinshineWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="space-y-6">
        <%!-- Page header --%>
        <div>
          <h1 class="text-2xl font-bold">Dashboard</h1>
          
          <p class="text-base-content/60 mt-1">
            Welcome back, <span class="font-semibold text-primary">{@current_scope.user.emails}</span>
          </p>
        </div>
         <%!-- Stats cards --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div class="stat bg-base-100 rounded-box shadow">
            <div class="stat-figure text-primary">
              <.icon name="hero-users" class="size-8" />
            </div>
            
            <div class="stat-title">Total Users</div>
            
            <div class="stat-value text-primary">{@user_count}</div>
            
            <div class="stat-desc">Registered accounts</div>
          </div>
          
          <div class="stat bg-base-100 rounded-box shadow">
            <div class="stat-figure text-secondary">
              <.icon name="hero-chart-bar" class="size-8" />
            </div>
            
            <div class="stat-title">Reports</div>
            
            <div class="stat-value text-secondary">0</div>
            
            <div class="stat-desc">Coming soon</div>
          </div>
          
          <div class="stat bg-base-100 rounded-box shadow">
            <div class="stat-figure text-accent">
              <.icon name="hero-clock" class="size-8" />
            </div>
            
            <div class="stat-title">Server Time</div>
            
            <div class="stat-value text-accent text-2xl">{@current_time}</div>
            
            <div class="stat-desc">Live</div>
          </div>
        </div>
         <%!-- Quick actions --%>
        <div class="card bg-base-100 shadow">
          <div class="card-body">
            <h2 class="card-title">Quick Actions</h2>
            
            <div class="flex flex-wrap gap-2 mt-2">
              <.link navigate={~p"/users/settings"} class="btn btn-outline btn-sm">
                <.icon name="hero-cog-6-tooth" class="size-4" /> Account Settings
              </.link>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    user_count = Kinshine.Accounts.count_users()

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       current_time: format_time(DateTime.utc_now()),
       user_count: user_count
     )}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, current_time: format_time(DateTime.utc_now()))}
  end

  defp format_time(dt) do
    dt
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%H:%M:%S UTC")
  end
end
