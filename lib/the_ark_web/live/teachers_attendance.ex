defmodule TheArkWeb.TeachersAttendanceLive do
  use TheArkWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""

    """
  end
end
