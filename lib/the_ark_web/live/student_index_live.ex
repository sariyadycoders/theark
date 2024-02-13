defmodule TheArkWeb.StudentIndexLive do
  use TheArkWeb, :live_view

  alias TheArk.Students

  @impl true
  def mount(_params, _session, socket) do

    socket
    |> assign(students: Students.list_students_for_index())
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div>
      <h1 class="font-bold text-3xl mb-5">The Ark Students</h1>
      <div class="grid grid-cols-6 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          Father's Name
        </div>
        <div>
          Age
        </div>
        <div>
          Class
        </div>
        <div class="">
          Contact
        </div>
        <div>
          Active?
        </div>
      </div>
      <%= for student <- @students do %>
      <div class="grid grid-cols-6 items-center border-b mb-2">
        <div>
          <%= student.name %>
        </div>
        <div>
          <%= student.father_name %>
        </div>
        <div>
          <%= calculate_age(student.date_of_birth) %>
        </div>
        <div>
          <%= student.class.name %>
        </div>
        <div class="">
          <%= student.whatsapp_number %>
          <%= student.sim_number %>
        </div>
        <div>
          <%=
            if !(student.is_leaving), do: "Yes", else: "No"
          %>
        </div>
      </div>




      <% end %>




      </div>
    """
  end

  def calculate_age(date_of_birth) do
    days_till_birth = Date.diff(Date.utc_today(), date_of_birth)
    (days_till_birth/365) |> round()
  end
end
