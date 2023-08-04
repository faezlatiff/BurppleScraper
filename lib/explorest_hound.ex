defmodule Explorest.Hound do
  use Hound.Helpers
  @neighbourhood "chinatown"
  @url "https://www.explorest.com/places/singapore/#{@neighbourhood}"
  @file_path "./tmp/explorest_#{@neighbourhood}.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    set_size(1657, 802)
    scrape(0, true)
    Hound.end_session()
  end

  defp set_size(width, height) do
    window_id = current_window_handle()
    try do
      set_window_size(window_id, width, height)
    rescue
      _ ->
        set_size(width, height)
    end
  end

  defp scrape(counter, first_click) do
    class = set_class(first_click)
    maybe_scroll(counter)

    find_all_elements(:class, class)
    |> store_or_wait(counter)
    scrape(counter + 1, false)
  end

  defp store_or_wait(list, counter) when list != [] do
    list
    # |> maybe_scroll(counter)
    |> Enum.at(counter)
    |> attribute_value("href")
    |> store_info()
  end
  defp store_or_wait(_, counter), do: scrape(counter, false)

  defp maybe_scroll(counter) when counter >= 20 do
    div(counter, 20)
    |> scroll()
  end
  defp maybe_scroll(counter), do: :ok

  defp set_class(true), do: "jss35"
  defp set_class(false), do: "jss28"

  defp store_info(link) do
    navigate_to(link)
    title = find_element(:class, "jss50") |> inner_text()
    username = find_element(:class, "jss48") |> inner_text()
    body = find_element(:class, "jss82") |> inner_text()
    {lat, lon} = get_lat_lon()

    map = %{
      title => %{
        "username" => username,
        "body" => body,
        "lat" => lat,
        "lon" => lon
      }
    }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])
    navigate_back()
  end

  defp get_lat_lon() do
    coords =
      find_element(:class, "jss79")
      |> visible_text()
      |> String.split("\n")

    lat =
      coords
      |> Enum.at(1)
      |> coordinate_parser()

    lon =
      coords
      |> Enum.at(3)
      |> coordinate_parser()

    {lat, lon}

  end

  defp coordinate_parser(coordinate) do
    regex = ~r/(?<degrees>\d+)°\s+(?<minutes>\d+)'\s+(?<seconds>[0-9.]+)"/
    %{"degrees" => deg_str, "minutes" => min_str, "seconds" => sec_str} = Regex.named_captures(regex, coordinate)
    String.to_integer(deg_str) + String.to_integer(min_str)/60 + String.to_float(sec_str)/3600
  end

  defp scroll(scrolls) when scrolls > 0 do
    scroll()
    scroll(scrolls - 1)
  end
  defp scroll(_), do: scroll()
  defp scroll() do
    div_scroll_script = """
      var div = document.getElementById('scrollableDiv');
      div.scrollTop = div.scrollHeight;
    """
    execute_script(div_scroll_script)
    :timer.sleep(1000)
  end



end
