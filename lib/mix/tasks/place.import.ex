defmodule Mix.Tasks.Place.Import do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:httpoison)

    countries =
      HTTPoison.get!(
        "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/refs/tags/v2.4/countries%2Bstates%2Bcities.json",
        [],
        recv_timeout: 30_000
      ).body
      |> Jason.decode!()

    File.write!(
      "#{Application.app_dir(:place)}/priv/countries-states-cities-database/db.gz",
      %Place.DB{
        cities:
          Enum.map(countries, fn country ->
            {
              Map.fetch!(country, "iso2"),
              Map.fetch!(country, "states")
              |> Enum.map(fn state ->
                {
                  Map.fetch!(state, "state_code"),
                  Map.fetch!(state, "cities")
                  |> Enum.map(fn city ->
                    %Place.City{
                      country_iso2: Map.fetch!(country, "iso2"),
                      csc_id: Map.fetch!(city, "id"),
                      latitude: Map.fetch!(city, "latitude"),
                      longitude: Map.fetch!(city, "longitude"),
                      name: Map.fetch!(city, "name"),
                      state_code: Map.fetch!(state, "state_code")
                    }
                  end)
                }
              end)
              |> Enum.into(%{})
            }
          end)
          |> Enum.into(%{}),
        countries:
          Enum.map(countries, fn country ->
            {
              Map.fetch!(country, "iso2"),
              %Place.Country{
                capital: Map.fetch!(country, "capital"),
                csc_id: Map.fetch!(country, "id"),
                csc_region_id: Map.fetch!(country, "region_id"),
                csc_subregion_id: Map.fetch!(country, "subregion_id"),
                currency: Map.fetch!(country, "currency"),
                currency_name: Map.fetch!(country, "currency_name"),
                currency_symbol: Map.fetch!(country, "currency_symbol"),
                emoji: Map.fetch!(country, "emoji"),
                emojiU: Map.fetch!(country, "emojiU"),
                iso2: Map.fetch!(country, "iso2"),
                iso3: Map.fetch!(country, "iso3"),
                latitude: Map.fetch!(country, "latitude"),
                longitude: Map.fetch!(country, "longitude"),
                name: Map.fetch!(country, "name"),
                nationality: Map.fetch!(country, "nationality"),
                native: Map.fetch!(country, "native"),
                numeric_code: Map.fetch!(country, "numeric_code"),
                phone_code: Map.fetch!(country, "phone_code"),
                timezones: Map.fetch!(country, "timezones"),
                tld: Map.fetch!(country, "tld"),
                translations: Map.fetch!(country, "translations")
              }
            }
          end)
          |> Enum.into(%{}),
        states:
          Enum.map(countries, fn country ->
            {
              Map.fetch!(country, "iso2"),
              Map.fetch!(country, "states")
              |> Enum.map(fn state ->
                {
                  Map.fetch!(state, "state_code"),
                  %Place.State{
                    country_iso2: Map.fetch!(country, "iso2"),
                    csc_id: Map.fetch!(state, "id"),
                    latitude: Map.fetch!(state, "latitude"),
                    longitude: Map.fetch!(state, "longitude"),
                    name: Map.fetch!(state, "name"),
                    state_code: Map.fetch!(state, "state_code"),
                    type: Map.fetch!(state, "type")
                  }
                }
              end)
              |> Enum.into(%{})
            }
          end)
          |> Enum.into(%{})
      }
      |> :erlang.term_to_binary()
      |> :zlib.gzip()
    )
  end
end
