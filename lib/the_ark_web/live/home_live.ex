defmodule TheArkWeb.Home do
  use TheArkWeb, :live_view

  alias TheArk.Classes

  @impl true
  def mount(_, _, socket) do

    socket
    |> ok
  end

  @impl true
  def handle_event("terms_announcement", %{"term_name" => term_name, "type" => type}, socket) do
    type = if type == "true", do: true, else: false

    Classes.term_announcement(term_name, type)

    socket
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
        <h1 class="font-bold text-3xl mb-5">Home</h1>
        <div class="grid grid-cols-6 gap-2">
          <.button phx-click="terms_announcement" phx-value-term_name="first_term" phx-value-type="true">Announce First Term</.button>
          <.button phx-click="terms_announcement" phx-value-term_name="first_term" phx-value-type="false">Finish First Term</.button>
          <.button phx-click="terms_announcement" phx-value-term_name="second_term" phx-value-type="true">Announce Second Term</.button>
          <.button phx-click="terms_announcement" phx-value-term_name="second_term" phx-value-type="false">Finish Second Term</.button>
          <.button phx-click="terms_announcement" phx-value-term_name="third_term" phx-value-type="true">Announce Third Term</.button>
          <.button phx-click="terms_announcement" phx-value-term_name="third_term" phx-value-type="false">Finish Third Term</.button>
        </div>


      </div>
    """
  end


end
