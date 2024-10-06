# Place

Place is an Elixir library and dataset containing names, ISO 3166 codes,
currencies and much more about countries, states and cities around the
world. It's using the
[countries-states-cities-database](https://github.com/dr5hn/countries-states-cities-database)
project as the data source, and it's regularly updated with new data.

```elixir
iex> Place.get_country(country_code: "US")
%Place.Country{
  capital: "Washington",
  csc_id: 233,
  csc_region_id: "2",
  csc_subregion_id: "6",
  currency: "USD",
  currency_name: "United States dollar",
  currency_symbol: "$",
  emoji: "🇺🇸",
  emojiU: "U+1F1FA U+1F1F8",
  iso2: "US",
  iso3: "USA",
  latitude: "38.00000000",
  longitude: "-97.00000000",
  name: "United States",
  nationality: "American",
  native: "United States",
  numeric_code: "840",
  phone_code: "1",
  ... # and more
}
```

## Installation

Add `:place` to your `mix.exs`:

```elixir
{:place, "~> 0.1"}
```

Add `Place` to your application's supervisor (read more under usage for an
[alternative approach](#loading-the-database-explicitly)):

```elixir
# lib/my_app/application.ex
def start(_type, _args) do
  children = [
    ...,
    Place
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
end
```

## Usage

Place provides functions for getting countries, states and cities. The
[documentation for the `Place` module](https://hexdocs.pm/place/Place.html)
contains detailed information about each function, but here are a few examples:

Get a list of all countries:

```elixir
iex> Place.get_countries() |> Enum.count()
250
```

Get all states in a country:

```elixir
iex> Place.get_states(country_code: "US") |> Enum.count()
66 # The extra 16 are non-state US territories, which can be identified by the `type` field.
```

Get all cities in a state:

```elixir
iex> Place.get_cities(country_code: "US", state_code: "CA") |> Enum.count()
1124
```

Get a country:

```elixir
iex> Place.get_country(country_code: "US")
%Place.Country{
  ...,
  name: "United States",
  ...
}
```

Get a state:

```elixir
iex> Place.get_state(country_code: "US", state_code: "CA")
%Place.State{
  ...,
  name: "California",
  ...
}
```

Get a city:

```elixir
iex> Place.get_city(country_code: "US", state_code: "CA", city_name: "Los Angeles")
%Place.City{
  ...,
  name: "Los Angeles",
  ...
}
```


### Loading the database explicitly

Place ships with a compressed database file, containing the
[countries-states-cities-database](https://github.com/dr5hn/countries-states-cities-database)
dataset. The `Place` module is a GenServer that at startup reads the file and
holds it as state in a `%Place.DB{}` struct. This is convenient, since you don't
have to think about passing around the struct, and for most use cases the
overhead of the interprocess communication is negligible.

However, if you don't want to add `Place` to your application's supervisor or if
want to directly access the `%Place.DB{}` struct, you can use
`Place.load_db!()`. Most of the functions in Place's API ships with two arities,
one that assumes the GenServer is running and one that explicitly takes a
`%Place.DB{}`. For example:

```elixir
iex> Place.get_countries() # First option
iex> Place.load_db!() |> Place.get_countries() # Second option
```

## License

Place is released under the MIT license and the database file is released under
the ODbL-1.0 license. See the [LICENSE](LICENSE) and
[priv/countries-states-cities-database/LICENSE](priv/countries-states-cities-database/LICENSE)
files respectively for more information.
