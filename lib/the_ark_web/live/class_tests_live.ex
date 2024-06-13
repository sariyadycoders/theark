defmodule TheArkWeb.ClassTestsLive do
  use TheArkWeb, :live_view

  alias TheArk.Classes
  alias TheArk.Tests

  @impl true
  def mount(%{"id" => class_id}, _session, socket) do
    class = Classes.get_class_for_tests_page(String.to_integer(class_id))

    socket
    |> assign(class: class)
    |> assign(changesets: [])
    |> assign(total_marks: "")
    |> assign(edit_test_id: 0)
    |> assign(selected_test_subject: nil)
    |> assign(selected_test_date: nil)
    |> ok()
  end

  @impl true
  def handle_event("assign_changesets", %{"id" => test_id}, socket) do
    test = Tests.get_test!(test_id)

    socket
    |> assign_changesets(test)
    |> noreply()
  end

  @impl true
  def handle_event("validate", %{"test" => params, "test_id" => test_id}, %{assigns: %{changesets: changesets}} =  socket) do
    test = Tests.get_test!(test_id)

    IO.inspect test
    IO.inspect Tests.student_submit_test_change(test, params) |> Map.put(:action, :insert)

    changesets =
      Enum.map(changesets, fn map ->
        if map.test_id == test.id do
          Map.put(map, :changeset, Tests.student_submit_test_change(test, params) |> Map.put(:action, :insert))
        else
          map
        end
      end)


    socket
    |> assign(changesets: changesets)
    |> noreply()
  end

  @impl true
  def handle_event("submit", %{"test" => params, "test_id" => test_id}, %{assigns: %{changesets: changesets}} =  socket) do
    test = Tests.get_test!(test_id)


    socket
    |> noreply()
  end

  def assign_changesets(%{assigns: %{class: class}} = socket, test) do
    changesets =
      Enum.map(class.students, fn student ->
        test = Tests.get_single_test(test.subject, student.id, test.date_of_test)

        %{test_id: test.id, name: student.name, changeset: Tests.student_submit_test_change(test), is_submitted: false}
      end)

    socket
    |> assign(changesets: changesets)
    |> assign(total_marks: test.total_marks)
    |> assign(selected_test_subject: test.subject)
    |> assign(selected_test_date: test.date_of_test)
    |> assign(edit_test_id: test.id)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-5">
        <h1 class="font-bold text-3xl mb-5">Tests List for Class <%= @class.name %></h1>
      </div>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-md">
        <div>
          Subject
        </div>
        <div>
          Date
        </div>
        <div>
          Total Marks
        </div>
        <div class="col-span-2">
          Failed Students
        </div>
        <div class="">
          Average Result
        </div>
        <div>
          Actions
        </div>
      </div>
      <%= for test <- @class.tests do %>
        <div class="grid grid-cols-7 items-center py-3 text-sm">
          <div>
            <%= test.subject %>
          </div>
          <div>
            <%= test.date_of_test %>
          </div>
          <div>
            <%= test.total_marks %>
          </div>
          <div class="col-span-2">
            Failed Students
          </div>
          <div class="">
            Average Result
          </div>
          <div class="flex gap-1">
            <.button
              phx-click={JS.push("assign_changesets") |> show_modal("test_result_add_#{test.id}")}
              phx-value-id={test.id}
              icon="hero-plus"
            />
            <.button phx-click="go_to_tests" icon="hero-eye" />
          </div>
        </div>
        <.modal id={"test_result_add_#{test.id}"}>
          <%= if @edit_test_id == test.id do %>
            <div class="my-5 border rounded-lg grid grid-cols-2">
              <div class="p-2"><b>Test Subject: </b><%= @selected_test_subject %></div>
              <div class="p-2 border-l"><b>Date: </b><%= @selected_test_date %></div>
            </div>
            <hr class="my-5" />
            <%= for %{test_id: id, name: name, changeset: changeset, is_submitted: is_submitted} <- @changesets do %>
              <%= if !is_submitted do %>
                <.form :let={f} for={changeset} phx-submit="submit" phx-change="validate" phx-value-test_id={id}>
                  <.input
                    field={f[:obtained_marks]}
                    label={"Obtained Marks of --- #{name} --- (out of #{@total_marks})"}
                    placeholder="0 marks means absent"
                    type="number"
                  />

                  <.button class="mt-5">Submit</.button>
                  <hr class="my-5" />
                </.form>
              <% end %>
            <% end %>
          <% end %>
        </.modal>
      <% end %>
    </div>
    """
  end
end
