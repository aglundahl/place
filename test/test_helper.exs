{:ok, _} = Place.start_link([])
:ok = ExUnit.start(exclude: [:benchmark])
