defmodule TheArkWeb.TimeTableLive do
  use TheArkWeb, :live_view

  @impl true
  def mount(_, _, socket) do

    socket
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <h1 class="font-bold text-3xl mb-5">Time Table</h1>



      </div>
    """
  end
end
