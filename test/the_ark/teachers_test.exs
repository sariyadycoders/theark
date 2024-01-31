defmodule TheArk.TeachersTest do
  use TheArk.DataCase

  alias TheArk.Teachers

  describe "teachers" do
    alias TheArk.Teachers.Teacher

    import TheArk.TeachersFixtures

    @invalid_attrs %{date_of_joining: nil, date_of_leaving: nil, name: nil, residence: nil}

    test "list_teachers/0 returns all teachers" do
      teacher = teacher_fixture()
      assert Teachers.list_teachers() == [teacher]
    end

    test "get_teacher!/1 returns the teacher with given id" do
      teacher = teacher_fixture()
      assert Teachers.get_teacher!(teacher.id) == teacher
    end

    test "create_teacher/1 with valid data creates a teacher" do
      valid_attrs = %{date_of_joining: ~D[2024-01-22], date_of_leaving: ~D[2024-01-22], name: "some name", residence: "some residence"}

      assert {:ok, %Teacher{} = teacher} = Teachers.create_teacher(valid_attrs)
      assert teacher.date_of_joining == ~D[2024-01-22]
      assert teacher.date_of_leaving == ~D[2024-01-22]
      assert teacher.name == "some name"
      assert teacher.residence == "some residence"
    end

    test "create_teacher/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teachers.create_teacher(@invalid_attrs)
    end

    test "update_teacher/2 with valid data updates the teacher" do
      teacher = teacher_fixture()
      update_attrs = %{date_of_joining: ~D[2024-01-23], date_of_leaving: ~D[2024-01-23], name: "some updated name", residence: "some updated residence"}

      assert {:ok, %Teacher{} = teacher} = Teachers.update_teacher(teacher, update_attrs)
      assert teacher.date_of_joining == ~D[2024-01-23]
      assert teacher.date_of_leaving == ~D[2024-01-23]
      assert teacher.name == "some updated name"
      assert teacher.residence == "some updated residence"
    end

    test "update_teacher/2 with invalid data returns error changeset" do
      teacher = teacher_fixture()
      assert {:error, %Ecto.Changeset{}} = Teachers.update_teacher(teacher, @invalid_attrs)
      assert teacher == Teachers.get_teacher!(teacher.id)
    end

    test "delete_teacher/1 deletes the teacher" do
      teacher = teacher_fixture()
      assert {:ok, %Teacher{}} = Teachers.delete_teacher(teacher)
      assert_raise Ecto.NoResultsError, fn -> Teachers.get_teacher!(teacher.id) end
    end

    test "change_teacher/1 returns a teacher changeset" do
      teacher = teacher_fixture()
      assert %Ecto.Changeset{} = Teachers.change_teacher(teacher)
    end
  end
end
