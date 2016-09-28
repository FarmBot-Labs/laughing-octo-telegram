ExUnit.start
defmodule AuthTest do
  @path Application.get_env(:fb, :ro_path)
  use ExUnit.Case, async: true

end
