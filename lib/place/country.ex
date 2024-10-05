defmodule Place.Country do
  @enforce_keys [
    :capital,
    :csc_id,
    :csc_region_id,
    :csc_subregion_id,
    :currency,
    :currency_name,
    :currency_symbol,
    :emoji,
    :emojiU,
    :iso2,
    :iso3,
    :latitude,
    :longitude,
    :name,
    :nationality,
    :native,
    :numeric_code,
    :phone_code,
    :timezones,
    :tld,
    :translations
  ]

  @type t :: %__MODULE__{}

  defstruct [
    :capital,
    :csc_id,
    :csc_region_id,
    :csc_subregion_id,
    :currency,
    :currency_name,
    :currency_symbol,
    :emoji,
    :emojiU,
    :iso2,
    :iso3,
    :latitude,
    :longitude,
    :name,
    :nationality,
    :native,
    :numeric_code,
    :phone_code,
    :timezones,
    :tld,
    :translations
  ]
end
