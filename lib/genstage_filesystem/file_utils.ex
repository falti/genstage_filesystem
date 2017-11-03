defmodule GenstageFilesystem.FileUtils do
  
  def get_files(dir) do
    
    {:ok, files} = File.ls(dir)
    files |> new_files() |> Enum.sort() |> files_with_mtime(dir)
  end


  def files_with_mtime(files, dir) do
    files |> Enum.map(fn(file) ->
      file_with_mtime(file, dir)
    end)
  end

  def file_with_mtime(file, dir) do
    {:ok, %File.Stat{mtime: mtime}} = File.lstat("#{dir}/#{file}")
    {:ok, naive_datetime} = NaiveDateTime.from_erl(mtime)
    {file, naive_datetime}
  end

  def new_files(files) do
    files |> Enum.filter(fn(f) -> !String.ends_with?(f, ".done") end)
  end


end