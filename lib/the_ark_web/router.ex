defmodule TheArkWeb.Router do
  use TheArkWeb, :router

  import TheArkWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TheArkWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TheArkWeb do
    pipe_through [:browser]

    # get "/", PageController, :home
    live "/", Home
    live "/home", Home
    live "/classes", ClassLive
    live "/classes/:id/results", ClassResultLive
    live "/classes/:id/tests", ClassTestsLive
    live "/classes/:id/tests/:test_id/result", ClassTestResultLive
    live "/classes/:id/results/:subject_name", ClassSubjectResultLive
    live "/classes/:id/result-sheet/:term", ClassTermResultLive
    live "/classes/:id/students", StudentLive
    live "/classes/:id/add_result", AddResultLive
    live "/classes/:id/slos", SloLive
    live "/classes/:id/attendance", ClassAttendanceLive
    live "/classes/:id/submit-fine", ClassSubmitFineLive
    live "/students", StudentIndexLive
    live "/students/:id", StudentsShowLive
    live "/students/:id/performance", StudentPerformanceLive
    live "/students/:id/attendance", StudentAttendanceLive
    live "/students/:id/result-sheet/:term", StudentTermResultLive
    live "/groups/:id/finances", StudentFinanceLive
    live "/groups", GroupsLive
    live "/teachers", TeacherLive
    live "/teachers/:id", TeacherShowLive
    live "/teachers/:id/result", TeacherResultLive
    live "/admissions", AdmissionLive
    live "/finances", FinanceLive
    live "/receipt/:id", ReceiptPrint
    live "/results", ResultLive
    live "/time_table", TimeTableLive
    live "/papers", PaperLive
    live "/about_us", AboutUs
  end

  # Other scopes may use custom stacks.
  # scope "/api", TheArkWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:the_ark, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TheArkWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", TheArkWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{TheArkWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TheArkWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TheArkWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", TheArkWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{TheArkWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
