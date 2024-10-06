defmodule PlaceTest do
  use ExUnit.Case, async: true

  import Place

  setup_all do
    [db: load_db!()]
  end

  # This also implicitly tests `mix place.import`.
  describe "load_db!" do
    test "countries", %{db: db} do
      assert Enum.count(db.countries) == 250

      countries_without_csc_region_id =
        MapSet.new([
          "Bouvet Island",
          "Heard Island and McDonald Islands"
        ])

      countries_without_csc_subregion_id =
        MapSet.new([
          "Antarctica",
          "Bouvet Island",
          "Heard Island and McDonald Islands"
        ])

      countries_without_native =
        MapSet.new([
          "Cote D'Ivoire (Ivory Coast)"
        ])

      Enum.each(db.countries, fn {country_code, country} ->
        assert country_code == country.iso2

        assert is_binary(country.capital)
        assert is_integer(country.csc_id)
        assert is_binary(country.currency)
        assert is_binary(country.currency_name)
        assert is_binary(country.currency_symbol)
        assert is_binary(country.emoji)
        assert is_binary(country.emojiU)
        assert is_binary(country.iso2)
        assert is_binary(country.iso3)
        assert is_binary(country.latitude)
        assert is_binary(country.longitude)
        assert is_binary(country.name)
        assert is_binary(country.nationality)
        assert is_binary(country.phone_code)
        assert is_list(country.timezones)
        assert is_binary(country.tld)
        assert is_map(country.translations)

        Enum.each(country.timezones, fn timezone ->
          assert Map.fetch!(timezone, "abbreviation") |> is_binary()
          assert Map.fetch!(timezone, "gmtOffset") |> is_integer()
          assert Map.fetch!(timezone, "gmtOffsetName") |> is_binary()
          assert Map.fetch!(timezone, "tzName") |> is_binary()
          assert Map.fetch!(timezone, "zoneName") |> is_binary()
        end)

        Enum.each(country.translations, fn {country_code, name} ->
          assert is_binary(country_code)
          assert is_binary(name)
        end)

        if MapSet.member?(countries_without_csc_subregion_id, country.name) do
          assert is_nil(country.csc_subregion_id)
        else
          assert is_binary(country.csc_subregion_id)
        end

        if MapSet.member?(countries_without_csc_region_id, country.name) do
          assert is_nil(country.csc_region_id)
        else
          assert is_binary(country.csc_region_id)
        end

        if MapSet.member?(countries_without_native, country.name) do
          assert is_nil(country.native)
        else
          assert is_binary(country.native)
        end
      end)
    end

    test "states", %{db: db} do
      assert(
        Enum.flat_map(db.states, fn {_, states} ->
          states
        end)
        |> Enum.count() == 5023
      )

      Enum.each(db.states, fn {country_code, states} ->
        Enum.each(states, fn {state_code, state} ->
          assert state.country_iso2 == country_code
          assert is_integer(state.csc_id)
          assert is_binary(state.latitude) || is_nil(state.latitude)
          assert is_binary(state.longitude) || is_nil(state.longitude)
          assert is_binary(state.name)
          assert state.state_code == state_code
          assert is_binary(state.type) || is_nil(state.type)
        end)
      end)
    end

    test "cities", %{db: db} do
      assert(
        Enum.flat_map(db.cities, fn {_, states} ->
          Enum.flat_map(states, fn {_, cities} ->
            cities
          end)
        end)
        |> Enum.count() == 150_652
      )

      Enum.each(db.cities, fn {country_code, states} ->
        Enum.each(states, fn {state_code, cities} ->
          Enum.each(cities, fn city ->
            assert city.country_iso2 == country_code
            assert is_integer(city.csc_id)
            assert is_binary(city.latitude)
            assert is_binary(city.longitude)
            assert is_binary(city.name)
            assert city.state_code == state_code
          end)
        end)
      end)
    end
  end

  test "get_countries", %{db: db} do
    Enum.each([get_countries(), get_countries(db)], fn countries ->
      assert Enum.count(countries) == 250
      assert Enum.find(countries, &(&1.iso2 == "US")).name == "United States"
    end)
  end

  describe "get_states" do
    test "existent country", %{db: db} do
      Enum.each(
        [get_states(country_code: "US"), get_states(db, country_code: "US")],
        fn states ->
          assert Enum.count(states) == 66
          assert Enum.find(states, &(&1.state_code == "CA")).name == "California"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [get_states(country_code: "foo"), get_states(db, country_code: "foo")],
        fn states ->
          assert is_nil(states)
        end
      )
    end
  end

  describe "get_cities by country" do
    test "existent country", %{db: db} do
      Enum.each(
        [get_cities(country_code: "US"), get_cities(db, country_code: "US")],
        fn cities ->
          assert Enum.count(cities) == 19_820
          assert Enum.find(cities, &(&1.name == "Los Angeles")).latitude == "34.05223000"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [get_cities(country_code: "foo"), get_cities(db, country_code: "foo")],
        fn cities ->
          assert is_nil(cities)
        end
      )
    end
  end

  describe "get_cities by country and state" do
    test "existent country and state", %{db: db} do
      Enum.each(
        [
          get_cities(country_code: "US", state_code: "CA"),
          get_cities(db, country_code: "US", state_code: "CA")
        ],
        fn cities ->
          assert Enum.count(cities) == 1124
          assert Enum.find(cities, &(&1.name == "Los Angeles")).latitude == "34.05223000"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [
          get_cities(country_code: "foo", state_code: "CA"),
          get_cities(db, country_code: "foo", state_code: "CA")
        ],
        fn cities ->
          assert is_nil(cities)
        end
      )
    end

    test "nonexistent state", %{db: db} do
      Enum.each(
        [
          get_cities(country_code: "US", state_code: "foo"),
          get_cities(db, country_code: "US", state_code: "foo")
        ],
        fn cities ->
          assert is_nil(cities)
        end
      )
    end
  end

  describe "get_country" do
    test "existent country", %{db: db} do
      Enum.each(
        [get_country(country_code: "US"), get_country(db, country_code: "US")],
        fn country ->
          assert country.name == "United States"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [get_country(country_code: "foo"), get_country(db, country_code: "foo")],
        fn country ->
          assert is_nil(country)
        end
      )
    end
  end

  describe "get_state" do
    test "existent country and state", %{db: db} do
      Enum.each(
        [
          get_state(country_code: "US", state_code: "CA"),
          get_state(db, country_code: "US", state_code: "CA")
        ],
        fn state ->
          assert state.name == "California"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [
          get_state(country_code: "foo", state_code: "CA"),
          get_state(db, country_code: "foo", state_code: "CA")
        ],
        fn state ->
          assert is_nil(state)
        end
      )
    end

    test "nonexistent state", %{db: db} do
      Enum.each(
        [
          get_state(country_code: "US", state_code: "foo"),
          get_state(db, country_code: "US", state_code: "foo")
        ],
        fn state ->
          assert is_nil(state)
        end
      )
    end
  end

  describe "get_city" do
    test "existent country, state and city", %{db: db} do
      Enum.each(
        [
          get_city(country_code: "US", state_code: "CA", city_name: "Los Angeles"),
          get_city(db, country_code: "US", state_code: "CA", city_name: "Los Angeles")
        ],
        fn city ->
          assert city.latitude == "34.05223000"
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [
          get_city(country_code: "foo", state_code: "CA", city_name: "Los Angeles"),
          get_city(db, country_code: "foo", state_code: "CA", city_name: "Los Angeles")
        ],
        fn city ->
          assert is_nil(city)
        end
      )
    end

    test "nonexistent state", %{db: db} do
      Enum.each(
        [
          get_city(country_code: "US", state_code: "foo", city_name: "Los Angeles"),
          get_city(db, country_code: "US", state_code: "foo", city_name: "Los Angeles")
        ],
        fn city ->
          assert is_nil(city)
        end
      )
    end

    test "nonexistent city", %{db: db} do
      Enum.each(
        [
          get_city(country_code: "US", state_code: "CA", city_name: "foo"),
          get_city(db, country_code: "US", state_code: "CA", city_name: "foo")
        ],
        fn city ->
          assert is_nil(city)
        end
      )
    end
  end

  describe "has_states" do
    test "existent country with states", %{db: db} do
      Enum.each(
        [has_states?(country_code: "US"), has_states?(db, country_code: "US")],
        fn value ->
          assert {:ok, true} = value
        end
      )
    end

    test "existent country without states", %{db: db} do
      Enum.each(
        [has_states?(country_code: "AX"), has_states?(db, country_code: "AX")],
        fn value ->
          assert {:ok, false} = value
        end
      )
    end

    test "nonexistent country", %{db: db} do
      Enum.each(
        [has_states?(country_code: "foo"), has_states?(db, country_code: "foo")],
        fn value ->
          assert {:error, false} = value
        end
      )
    end
  end
end
