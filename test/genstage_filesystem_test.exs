defmodule GenstageFilesystemTest do
  use ExUnit.Case, async: true # don't run this async - we use the same directory!
  
  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end


  defp start_app(directory) do

    import Supervisor.Spec

    children = [
      worker(GenstageFilesystem.Server, [directory]),
      worker(GenstageFilesystem.Producer, [])
    ]

    opts = [strategy: :one_for_one, name: GenstageFilesystem.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defp create_random_dir do
    test_dir = "testdata/#{random_string(8)}"
    :ok = File.mkdir_p(test_dir)
    {:ok, test_dir}
  end

  test "read files from empty directory" do

    {:ok, test_dir} = create_random_dir()

    File.touch("#{test_dir}/1.jpg.done") # already processed
    File.touch("#{test_dir}/2.jpg.done") # already processed
    File.touch("#{test_dir}/3.jpg")      # not processed but lies around before we start

    {:ok, sup} = start_app(test_dir)

    producer = Process.whereis(GenstageFilesystem.Producer)

    task = Task.async(fn -> 
    
      events = GenStage.stream([{producer, max_demand: 1, cancel: :temporary}])

      Process.sleep(2) # FIXME: required, otherwise we somehow miss the 9.jpg

      files = Enum.take(events, 2) |> Enum.map(fn({file, _mtime}) -> file end)

      assert files == ["3.jpg","4.jpg"]

      files = Enum.take(events, 1) |> Enum.map(fn({file, _mtime}) -> file end)

      assert files == ["5.jpg"]
      {:ok, files} = File.ls(test_dir)

      assert [
        "1.jpg.done",
        "2.jpg.done",
        "3.jpg.done",
        "4.jpg.done",
        "5.jpg.done",
        "6.jpg",
        "7.jpg",
        "8.jpg",
        "9.jpg"] == Enum.sort(files)
    
      GenStage.stop(producer)
      
    end)
    
    # now added  4.jpg, 5.jpg ... 9.jpg after we set up the genstage
    new_images = Enum.to_list(4..9)
    new_images = new_images |> Enum.map(fn(x)-> "#{test_dir}/#{x}.jpg" end)
    new_images |> Enum.each(&File.touch/1)
    
  
    Task.await(task)

    :ok = Supervisor.stop(sup)

    File.rm_rf(test_dir)
    
  end

  test "File operations" do

    {:ok, test_dir} = create_random_dir()
    File.touch("#{test_dir}/1.jpg") 

    {file, %NaiveDateTime{year: _year}} = GenstageFilesystem.FileUtils.file_with_mtime("1.jpg", test_dir)
    
    File.rm_rf(test_dir)
  end


end
