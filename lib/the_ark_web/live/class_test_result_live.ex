defmodule TheArkWeb.ClassTestResultLive do
  use TheArkWeb, :live_view

  def mount(%{"id" => class_id, "test_id" => test_id}, _session, socket) do

    socket
    |> ok()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        div






      </div>
    """
  end
end
