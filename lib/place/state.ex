defmodule Place.State do
  @enforce_keys [
    :country_iso2,
    :csc_id,
    :latitude,
    :longitude,
    :name,
    :state_code,
    :type
  ]

  @type t :: %__MODULE__{}

  defstruct [
    :country_iso2,
    :csc_id,
    :latitude,
    :longitude,
    :name,
    :state_code,
    :type
  ]
end
