defmodule TheArkWeb.GroupsLive do
  use TheArkWeb, :live_view

  alias TheArk.Groups

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(groups: Groups.list_groups())
    |> ok
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center gap-5">
        <h1 class="font-bold text-3xl mb-5">The Ark Groups</h1>
      </div>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-lg mb-2">
        <div>
          Name
        </div>
        <div>
          No. of Students
        </div>
        <div class="col-span-2">
          Students
        </div>
        <div>
          Monthly Fee
        </div>
        <div>
          Status
        </div>
        <div class="">
          Actions
        </div>
      </div>
      <%= for group <- @groups do %>
        <div
          phx-click="show_student"
          phx-value-student_id={nil}
          class="grid grid-cols-7 items-center border-b py-2 cursor-pointer"
        >
          <div class="">
            <div class="flex items-center">
              <a><%= group.name %></a>
              <span :if={false} class="ml-2 text-xs p-0.5 px-1 border bg-red-200 rounded-lg">
                non-active
              </span>
            </div>
          </div>
          <div>
            <%= Enum.count(group.students) %>
          </div>
          <div class="col-span-2">
            <%= for student <- group.students do %>
              <div><%= student.name <> " " <> student.father_name %>,</div>
            <% end %>
          </div>
          <div>
            <%= group.monthly_fee %>
          </div>
          <div>
            <%= "Status" %>
          </div>
          <div class="">
            Actions
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
