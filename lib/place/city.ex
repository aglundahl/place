defmodule Place.City do
  @enforce_keys [
    :country_iso2,
    :csc_id,
    :latitude,
    :longitude,
    :name,
    :state_code
  ]

  @type t :: %__MODULE__{}

  defstruct [
    :country_iso2,
    :csc_id,
    :latitude,
    :longitude,
    :name,
    :state_code
  ]
end
