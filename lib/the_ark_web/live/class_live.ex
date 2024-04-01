defmodule TheArkWeb.ClassLive do
  use TheArkWeb, :live_view

  alias TheArk.{
    Classes,
    Classes.Class,
    Students,
    Subjects,
    Teachers
  }
  alias Phoenix.LiveView.Components.MultiSelect
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    socket
    |> check_result_completion()
    |> assign(teachers: Teachers.list_teachers())
    |> assign(class_changeset: Classes.change_class(%Class{}))
    |> assign(edit_class_id: 0)
    |> assign(delete_class_id: 0)
    |> assign(options: Subjects.list_subject_options())
    |> ok()
  end

  @impl true
  def handle_info({:updated_options, options}, socket) do
    socket
    |> assign(options: options)
    |> noreply()
  end

  @impl true
  def handle_event("edit_class_id", %{"class_id" => "0"}, socket) do
    socket
    |> assign(edit_class_id: 0)
    |> assign(delete_class_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event("edit_class_id", %{"class_id" => id}, socket) do
    class = Classes.get_class!(String.to_integer(id))
    class_changeset = Classes.change_class(class)

    class_subject_ids =
      Enum.map(class.subjects, fn class_subject ->
        class_subject.subject_id
      end)

    options =
      Enum.map(socket.assigns.options, fn subject_option ->
        if subject_option.id in class_subject_ids do
          Map.put(subject_option, :selected, true)
        else
          Map.put(subject_option, :selected, false)
        end
      end)

    socket
    |> assign(class_changeset: class_changeset)
    |> assign(options: options)
    |> assign(edit_class_id: String.to_integer(id))
    |> assign(delete_class_id: 0)
    |> noreply()
  end

  @impl true
  def handle_event("delete_class_id", %{"class_id" => id}, socket) do
    socket
    |> assign(delete_class_id: String.to_integer(id))
    |> assign(edit_class_id: 0)
    |> noreply
  end

  @impl true
  def handle_event("delete_class", %{"class_id" => id}, socket) do
    Classes.delete_class_by_id(String.to_integer(id))

    socket
    |> assign(classes: Classes.list_classes())
    |> put_flash(:info, "Class succefully deleted!")
    |> noreply()
  end

  @impl true
  def handle_event(
        "class_updation",
        %{"class" => params, "class_id" => id},
        %{assigns: %{options: options}} = socket
      ) do
    class = Classes.get_class!(String.to_integer(id))

    case Classes.update_class(class, params, options) do
      {:ok, _class} ->
        socket
        |> assign(edit_class_id: 0)
        |> put_flash(:info, "Class successfully updated!")
        |> assign(classes: Classes.list_classes())
        |> noreply()

      {:error, changeset} ->
        socket
        |> assign(class_changeset: changeset)
        |> noreply()
    end
  end

  @impl true
  def handle_event("class_validation", %{"class" => params, "class_id" => id}, socket) do
    class = Classes.get_class!(String.to_integer(id))
    class_changeset = Classes.change_class(class, params) |> Map.put(:action, :insert)

    socket
    |> assign(class_changeset: class_changeset)
    |> noreply()
  end

  @impl true
  def handle_event("open_class", %{"class_id" => id}, socket) do
    socket
    |> redirect(to: ~p"/classes/#{id}/students")
    |> noreply
  end

  @impl true
  def handle_event("go_to_registration", _, socket) do
    socket
    |> redirect(to: "/registration")
    |> noreply
  end

  @impl true
  def handle_event(
        "student_class_change",
        %{"prev_class_id" => prev_id, "student_class_change" => %{"class_id" => new_id}},
        socket
      ) do
    Students.replace_class_id_of_students(prev_id, new_id)
    Students.replace_subjects_of_students(new_id)
    Classes.delete_class_by_id(String.to_integer(prev_id))

    socket
    |> put_flash(:info, "Students transferred and class deleted!")
    |> assign(classes: Classes.list_classes())
    |> noreply
  end

  @impl true
  def handle_event("add_result", %{"class_id" => class_id}, socket) do
    socket
    |> redirect(to: "/classes/#{class_id}/add_result")
    |> noreply()
  end

  @impl true
  def handle_event("go_to_slos", %{"class_id" => id}, socket) do
    socket
    |> redirect(to: "/classes/#{id}/slos")
    |> noreply()
  end

  def handle_event("open_class_result", %{"class_id" => id}, socket) do
    socket
    |> redirect(to: "/classes/#{id}/results")
    |> noreply()
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between">
        <h1 class="font-bold text-3xl mb-5">Classes</h1>
        <.button phx-click="go_to_registration">Add a new Class</.button>
      </div>
      <div class="grid grid-cols-7 items-center border-b-4 pb-2 font-bold text-md">
        <div>
          Name
        </div>
        <div>
          Incharge
        </div>
        <div>
          # of Students
        </div>
        <div>
          SLO's
        </div>
        <div class="">
          Results
        </div>
        <div class=""></div>
        <div>
          Actions
        </div>
      </div>

      <%= for class <- @classes do %>
        <div class="grid grid-cols-7 items-center py-3 text-sm">
          <div class="cursor-pointer" phx-click="open_class" phx-value-class_id={class.id}>
            <%= class.name %>
          </div>
          <div>
            <%= class.incharge %>
          </div>
          <div>
            <%= Enum.count(class.students) %>
          </div>
          <div>
            <.button phx-click="go_to_slos" phx-value-class_id={class.id} icon="hero-eye" />
          </div>
          <div class="flex items-center gap-1">
            <.button phx-click="add_result" phx-value-class_id={class.id} icon="hero-plus" />
            <.button phx-click="open_class_result" phx-value-class_id={class.id} icon="hero-eye" />
          </div>
          <div class="flex items-center gap-1">
            <%= for term_name <- @list_of_terms do %>
              <%= if Map.get(class, String.to_atom("is_#{term_name}_announced")) do %>
                <div class={"w-5 rounded-full text-center #{!Map.get(class, String.to_atom("is_#{term_name}_result_completed")) && "bg-red-500 text-white"} #{Map.get(class, String.to_atom("is_#{term_name}_result_completed")) && "bg-green-500 text-white"}"}>
                  <%= if term_name == "first_term" do %>
                    1
                  <% else %>
                    <%= if term_name == "second_term" do %>
                      2
                    <% else %>
                      3
                    <% end %>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>
          <%!-- <%= if @current_user.email == "management@ark.com" do %> --%>
          <div class="flex items-center gap-1">
            <.button
              icon="hero-pencil"
              phx-click={JS.push("edit_class_id") |> show_modal("edit_class_modal_#{class.id}")}
              phx-value-class_id={class.id}
            />
            <.button
              icon="hero-trash"
              phx-click={JS.push("delete_class_id") |> show_modal("delete_class_modal_#{class.id}")}
              phx-value-class_id={class.id}
            />
          </div>
          <%!-- <% end %> --%>
        </div>
        <.modal id={"delete_class_modal_#{class.id}"}>
          <%= if @delete_class_id == class.id do %>
            <div class="relative border p-3 rounded-lg">
              <div
                phx-click="delete_class_id"
                phx-value-class_id="0"
                class="absolute top-2 right-2 cursor-pointer"
              >
                &#9746;
              </div>
              <.button class="mb-2" phx-click="delete_class" phx-value-class_id={class.id}>
                Delete Class alongwith All Students
              </.button>
              <div class="font-bold">OR transfer students to another class</div>
              <div class="p-2 border rounded-lg mt-2">
                <h2 class="font-bold mb-2">
                  Students of class <%= class.name %> should be transfered to:
                </h2>
                <.form
                  :let={s}
                  for={%{}}
                  as={:student_class_change}
                  phx-value-prev_class_id={class.id}
                  phx-submit="student_class_change"
                >
                  <.input
                    field={s[:class_id]}
                    type="select"
                    label="Class"
                    options={Enum.flat_map(@classes, fn class -> [{:"#{class.name}", class.id}] end)}
                  />

                  <.button class="mt-5">Transfer Studens and Delete Class</.button>
                </.form>
              </div>
            </div>
          <% end %>
        </.modal>
        <.modal id={"edit_class_modal_#{class.id}"}>
          <%= if @edit_class_id == class.id do %>
            <div class="relative border p-3 rounded-lg">
              <div
                phx-click="edit_class_id"
                phx-value-class_id="0"
                class="absolute top-2 right-2 cursor-pointer"
              >
                &#9746;
              </div>
              <.form
                :let={f}
                for={@class_changeset}
                phx-change="class_validation"
                phx-submit="class_updation"
                phx-value-class_id={class.id}
              >
                <.input
                  field={f[:incharge]}
                  type="select"
                  options={List.insert_at(Enum.map(@teachers, fn teacher -> teacher.name end), 0, "")}
                  label="Incharge Name"
                />
                <MultiSelect.multi_select
                  id={"subjects_#{class.id}"}
                  on_change={fn opts -> send(self(), {:updated_options, opts}) end}
                  form={f}
                  options={@options}
                  max_selected={7}
                  placeholder="Select subjects..."
                  title="Select Subjects"
                />

                <.button
                  phx-click={JS.exec("data-cancel", to: "#edit_class_modal_#{class.id}")}
                  class="mt-5"
                >
                  Submit
                </.button>
              </.form>
            </div>
          <% end %>
        </.modal>
        <hr class="" />
      <% end %>
    </div>
    """
  end

  def check_result_completion(socket) do
    all_class_ids = Classes.get_all_class_ids()
    list_of_terms = Classes.make_list_of_terms()

    if Enum.any?(list_of_terms) do
      for id <- all_class_ids do
        class = Classes.get_class!(id)

        for term_name <- list_of_terms do
          is_term_result_completed =
            Enum.all?(class.students, fn student ->
              Enum.all?(student.subjects, fn subject ->
                results =
                  Enum.filter(subject.results, fn result ->
                    result.name == term_name
                  end)

                Enum.all?(results, fn result ->
                  result.obtained_marks
                end)
              end)
            end)

          Classes.update_class(class, %{
            "is_#{term_name}_result_completed" => is_term_result_completed
          })
        end
      end
    end

    classes = Classes.list_classes()

    socket
    |> assign(classes: classes)
    |> assign(list_of_terms: list_of_terms)
  end
end
