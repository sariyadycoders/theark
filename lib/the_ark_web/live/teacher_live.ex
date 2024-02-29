defmodule TheArkWeb.TeacherLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Teachers
  }

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(teachers: Teachers.list_teachers())
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h1 class="font-bold text-3xl mb-5">Teachers</h1>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          Education
        </div>
        <div>
          Service
        </div>
        <div>
          Contact
        </div>
        <div class="col-span-3">
          Time Table
        </div>
      </div>
      <%= for teacher <- @teachers do %>
        <div class="grid grid-cols-7 items-center pb-2">
          <div class="">
            <div class="flex items-center">
              <a href={"teachers/#{teacher.id}"}><%= teacher.name %></a>
              <span
                :if={teacher.is_leaving}
                class="ml-2 text-xs p-0.5 px-1 border bg-red-200 rounded-lg"
              >
                non-active
              </span>
            </div>
          </div>
          <div>
            <%= teacher.education %>
          </div>
          <div>
            <%= get_service(teacher.registration_date) %>
          </div>
          <div>
            <div><b>W: </b><%= teacher.whatsapp_number %></div>
            <div><b>S: </b><%= teacher.sim_number %></div>
          </div>
          <div class="col-span-3 flex flex-wrap">
            <%= for period <- teacher.periods do %>
              <div class="border flex flex-col items-center justify-center px-2 py-1 w-28">
                <div class="font-bold"><%= period.period_number %></div>
                <div><%= period.class.name %></div>
                <div><%= period.subject %></div>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def get_service(registration_date) do
    days_till_joining = Date.diff(Date.utc_today(), registration_date)

    if days_till_joining > 365 do
      number_of_years = (days_till_joining / 365) |> floor()
      extra_days = rem(days_till_joining, 365)
      number_of_months = (extra_days / 30) |> floor()

      "#{number_of_years} Years #{if number_of_months > 0, do: "and #{number_of_months} Months"}"
    else
      number_of_months = (days_till_joining / 30) |> floor()

      "#{number_of_months} Months"
    end
  end
end
