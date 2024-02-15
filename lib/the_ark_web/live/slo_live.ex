defmodule TheArkWeb.SloLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    class = Classes.get_class_for_slos(id)

    socket
    |> assign(class: class)
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      SLOs
    </div>
    """
  end
end
