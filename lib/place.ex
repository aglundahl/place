defmodule Place do
  @moduledoc """
  Query API and GenServer for Place, a dataset of countries, states and cities
  around the world.
  """

  use GenServer

  alias Place.City
  alias Place.Country
  alias Place.DB
  alias Place.State

  def start_link(_) do
    GenServer.start_link(
      __MODULE__,
      load_db!(),
      name: __MODULE__
    )
  end

  @doc """
  Reads and deserializes the database file into a `%Place.DB{}` struct.

  ## Examples

      iex> db = Place.load_db!()
      iex> Enum.count(db.countries)
      250
  """
  @spec load_db!() :: DB.t()
  def load_db! do
    File.read!("#{Application.app_dir(:place)}/priv/countries-states-cities-database/db.gz")
    |> :zlib.gunzip()
    |> :erlang.binary_to_term()
  end

  @doc """
  Get an unordered list of all countries.

  ## Examples

      iex> countries = Place.get_countries()
      iex> Enum.find(countries, &(&1.iso2 == "US")).name
      "United States"
  """
  @spec get_countries() :: [Country.t(), ...]
  def get_countries do
    GenServer.call(__MODULE__, :get_countries)
  end

  @doc """
  Like `get_countries/0` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> countries = Place.get_countries(db)
      iex> Enum.find(countries, &(&1.iso2 == "US")).name
      "United States"
  """
  @spec get_countries(DB.t()) :: [Country.t(), ...]
  def get_countries(%DB{countries: countries}) do
    Map.values(countries)
  end

  @doc """
  Get an unordered list of all states by the given country code.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.

  ## Examples

      iex> states = Place.get_states(country_code: "US")
      iex> Enum.find(states, &(&1.state_code == "CA")).name
      "California"
  """
  @spec get_states(country_code: binary()) :: [State.t()]
  def get_states(country_code: country_code) do
    GenServer.call(__MODULE__, {:get_states, country_code})
  end

  @doc """
  Like `get_states/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> states = Place.get_states(db, country_code: "US")
      iex> Enum.find(states, &(&1.state_code == "CA")).name
      "California"
  """
  @spec get_states(DB.t(), country_code: binary()) :: [State.t()]
  def get_states(%DB{states: states}, country_code: country_code) do
    case Map.get(states, country_code) do
      nil ->
        nil

      states ->
        Map.values(states)
    end
  end

  @doc """
  Get an unordered list of all cities by the given country code, and optional
  state code.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.
    * `:state_code` - A state code.

  ## Examples

      iex> cities = Place.get_cities(country_code: "US")
      iex> Enum.find(cities, &(&1.name == "Los Angeles")).latitude
      "34.05223000"

      iex> cities = Place.get_cities(country_code: "US", state_code: "CA")
      iex> Enum.find(cities, &(&1.name == "Los Angeles")).latitude
      "34.05223000"
  """
  @spec get_cities(country_code: binary()) :: [City.t()]
  def get_cities(country_code: country_code) do
    GenServer.call(__MODULE__, {:get_cities, country_code})
  end

  @spec get_cities(country_code: binary(), state_code: binary()) :: [City.t()]
  def get_cities(country_code: country_code, state_code: state_code) do
    GenServer.call(__MODULE__, {:get_cities, country_code, state_code})
  end

  @doc """
  Like `get_cities/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> cities = Place.get_cities(db, country_code: "US")
      iex> Enum.find(cities, &(&1.name == "Los Angeles")).latitude
      "34.05223000"

      iex> db = Place.load_db!()
      iex> cities = Place.get_cities(db, country_code: "US", state_code: "CA")
      iex> Enum.find(cities, &(&1.name == "Los Angeles")).latitude
      "34.05223000"
  """
  @spec get_cities(DB.t(), country_code: binary()) :: [City.t()]
  def get_cities(%DB{cities: cities}, country_code: country_code) do
    case Map.get(cities, country_code) do
      nil ->
        nil

      cities ->
        Map.values(cities)
        |> List.flatten()
    end
  end

  @spec get_cities(DB.t(), country_code: binary(), state_code: binary()) :: [City.t()]
  def get_cities(%DB{cities: cities}, country_code: country_code, state_code: state_code) do
    get_in(cities, [country_code, state_code])
  end

  @doc """
  Get a country by the given country code.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.

  ## Examples

      iex> Place.get_country(country_code: "US").name
      "United States"
  """
  @spec get_country(country_code: binary()) :: Country.t() | nil
  def get_country(country_code: country_code) do
    GenServer.call(__MODULE__, {:get_country, country_code})
  end

  @doc """
  Like `get_country/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> Place.get_country(db, country_code: "US").name
      "United States"
  """
  @spec get_country(DB.t(), country_code: binary()) :: Country.t() | nil
  def get_country(%DB{countries: countries}, country_code: country_code) do
    Map.get(countries, country_code)
  end

  @doc """
  Get a state by the given country code and state code.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.
    * `:state_code` - A state code.

  ## Examples

      iex> Place.get_state(country_code: "US", state_code: "CA").name
      "California"
  """
  @spec get_state(country_code: binary(), state_code: binary()) :: State.t() | nil
  def get_state(country_code: country_code, state_code: state_code) do
    GenServer.call(__MODULE__, {:get_state, country_code, state_code})
  end

  @doc """
  Like `get_state/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> Place.get_state(db, country_code: "US", state_code: "CA").name
      "California"
  """
  @spec get_state(DB.t(), country_code: binary(), state_code: binary()) :: State.t() | nil
  def get_state(%DB{states: states}, country_code: country_code, state_code: state_code) do
    get_in(states, [country_code, state_code])
  end

  @doc """
  Get a city by the given country code, state code and city name.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.
    * `:state_code` - A state code.
    * `:city_name` - A city name.

  ## Examples

      iex> Place.get_city(country_code: "US", state_code: "CA", city_name: "Los Angeles").latitude
      "34.05223000"
  """
  @spec get_city(country_code: binary(), state_code: binary(), city_name: binary()) ::
          City.t() | nil
  def get_city(country_code: country_code, state_code: state_code, city_name: city_name) do
    GenServer.call(__MODULE__, {:get_city, country_code, state_code, city_name})
  end

  @doc """
  Like `get_city/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> Place.get_city(db, country_code: "US", state_code: "CA", city_name: "Los Angeles").latitude
      "34.05223000"
  """
  @spec get_city(DB.t(), country_code: binary(), state_code: binary(), city_name: binary()) ::
          City.t() | nil
  def get_city(%DB{cities: cities},
        country_code: country_code,
        state_code: state_code,
        city_name: city_name
      ) do
    case get_in(cities, [country_code, state_code]) do
      nil ->
        nil

      cities ->
        Enum.find(cities, &(&1.name == city_name))
    end
  end

  @doc """
  Check if the country by the given country code has any states.

  ## Options

    * `:country_code` - An [ISO 3166-1
      alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country code.

  ## Examples

      iex> Place.has_states?(country_code: "US")
      {:ok, true}
  """
  @spec has_states?(country_code: binary()) :: {:ok, boolean()} | {:error, false}
  def has_states?(country_code: country_code) do
    GenServer.call(__MODULE__, {:has_states?, country_code})
  end

  @doc """
  Like `has_states?/1` but takes a `%Place.DB{}` as the first argument.

  ## Examples

      iex> db = Place.load_db!()
      iex> Place.has_states?(db, country_code: "US")
      {:ok, true}
  """
  @spec has_states?(DB.t(), country_code: binary()) :: {:ok, boolean()} | {:error, false}
  def has_states?(%DB{states: states}, country_code: country_code) do
    case Map.get(states, country_code) do
      nil ->
        {:error, false}

      states ->
        {
          :ok,
          Enum.empty?(states)
          |> Kernel.not()
        }
    end
  end

  @impl GenServer
  def init(initial_arg) do
    {:ok, initial_arg}
  end

  @impl GenServer
  def handle_call(:get_countries, _, state) do
    {:reply, get_countries(state), state}
  end

  def handle_call({:get_states, country_code}, _, state) do
    {:reply, get_states(state, country_code: country_code), state}
  end

  def handle_call({:get_cities, country_code}, _, state) do
    {:reply, get_cities(state, country_code: country_code), state}
  end

  def handle_call({:get_cities, country_code, state_code}, _, state) do
    {:reply, get_cities(state, country_code: country_code, state_code: state_code), state}
  end

  def handle_call({:get_country, country_code}, _, state) do
    {:reply, get_country(state, country_code: country_code), state}
  end

  def handle_call({:get_state, country_code, state_code}, _, state) do
    {:reply, get_state(state, country_code: country_code, state_code: state_code), state}
  end

  def handle_call({:get_city, country_code, state_code, city_name}, _, state) do
    {:reply,
     get_city(state, country_code: country_code, state_code: state_code, city_name: city_name),
     state}
  end

  def handle_call({:has_states?, country_code}, _, state) do
    {:reply, has_states?(state, country_code: country_code), state}
  end
end
