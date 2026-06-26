defmodule KinshineWeb.Router do
  use KinshineWeb, :router

  import KinshineWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KinshineWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KinshineWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # JSON API scope – ready for mobile app integration
  scope "/api", KinshineWeb do
    pipe_through :api
    # API routes will be added here
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:kinshine, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KinshineWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", KinshineWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{KinshineWeb.UserAuth, :require_authenticated}] do
      live "/dashboard", DashboardLive, :index
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      # Configuration > Menus
      live "/configuration/menus", MenuLive, :index
      live "/configuration/menus/new", MenuLive, :new

      # Finance > Master > Company Code
      live "/finance/companycode", CompanyCodeLive.Index, :index
      live "/finance/companycode/new", CompanyCodeLive.Index, :new
      live "/finance/companycode/:id/edit", CompanyCodeLive.Index, :edit

      # Finance > Master > Fiscal Year Variant
      live "/finance/fiscalyearvariant", FiscalYearVariantLive.Index, :index
      live "/finance/fiscalyearvariant/new", FiscalYearVariantLive.Index, :new
      live "/finance/fiscalyearvariant/:id/edit", FiscalYearVariantLive.Index, :edit

      # Finance > Master > Posting Period Variant
      live "/finance/postingperiodvariant", PostingPeriodVariantLive.Index, :index
      live "/finance/postingperiodvariant/new", PostingPeriodVariantLive.Index, :new
      live "/finance/postingperiodvariant/:id/edit", PostingPeriodVariantLive.Index, :edit

      # Finance > Master > Period Control
      live "/finance/periodcontrol", PeriodControlLive.Index, :index
      live "/finance/periodcontrol/new", PeriodControlLive.Index, :new
      live "/finance/periodcontrol/:id/edit", PeriodControlLive.Index, :edit

      # Finance > Master > Account Group
      live "/finance/accountgroup", AccountGroupLive.Index, :index
      live "/finance/accountgroup/new", AccountGroupLive.Index, :new
      live "/finance/accountgroup/:id/edit", AccountGroupLive.Index, :edit

      # Finance > Master > GL Account Master
      live "/finance/glaccountmaster", GLAccountMasterLive.Index, :index
      live "/finance/glaccountmaster/new", GLAccountMasterLive.Index, :new
      live "/finance/glaccountmaster/:id/edit", GLAccountMasterLive.Index, :edit

      # Finance > Master > COA GL Account
      live "/finance/companycodeglaccount", CompanyCodeGLAccountLive.Index, :index
      live "/finance/companycodeglaccount/new", CompanyCodeGLAccountLive.Index, :new

      live "/finance/companycodeglaccount/:coaid/:acnum/edit",
           CompanyCodeGLAccountLive.Index,
           :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", KinshineWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{KinshineWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
