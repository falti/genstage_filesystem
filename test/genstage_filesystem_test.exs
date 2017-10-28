defmodule GenstageFilesystemTest do
  use ExUnit.Case
  doctest GenstageFilesystem

  setup do
    File.mkdir_p("testdata")

    on_exit fn ->
      File.rm_rf("testdata")
    end
  end


  test "put files into empty directory" do
    File.mkdir_p("testdata/empty_directory")

    {:ok, producer} = GenStage.start_link(GenstageFilesystem.Producer, {0, "testdata/empty_directory",[]})

    task = Task.async(fn -> 

      events = GenStage.stream([{producer, max_demand: 1, cancel: :temporary}]) |> Enum.take(2)

      assert events == ["1.txt","2.txt"]
      
    end)

    File.touch("testdata/empty_directory/1.txt")
    File.touch("testdata/empty_directory/2.txt")

    Task.await(task)
  end
end
