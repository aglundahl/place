defmodule Place.DB do
  @enforce_keys [
    :cities,
    :countries,
    :states
  ]

  @type t :: %__MODULE__{}

  defstruct [
    :cities,
    :countries,
    :states
  ]
end
