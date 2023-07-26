defmodule Atlas.Hound do
  use Hound.Helpers
  @url "https://www.burpple.com/neighbourhoods/sg/chinatown"

  @spec run :: list
  def run do
    Hound.start_session()

    file_path = "./tmp/burpple_scraper.json"

    navigate_to(@url)

    find_element(:id, "load-more-reviews")
    |> css_property("visibility")
    |> click_loop(2)

    elements = find_all_elements(:css, ".food.card.feed-item")

    Enum.each(elements, fn element ->
      post_map =
        inner_html(element)
        |> Floki.parse_document()
        |> into_map()
        # |> Jason.encode()

      IO.inspect(post_map)
    end)

    Hound.end_session()

  end


  defp into_map({:ok, html_tree}) do
    name = Floki.find(html_tree, ".food-venue-detail--title") |> get_inner_text()
    address = Floki.find(html_tree, ".food-venue-detail--address") |> get_inner_text()
    title = Floki.find(html_tree, ".food-description-title") |> get_inner_text()
    body = Floki.find(html_tree, ".food-description-body") |> get_inner_text()
    username = Floki.find(html_tree, ".card-item-set--link-title") |> get_inner_text()

    %{
      name => %{
        "address" => address,
        "title" => title,
        "body" => body,
        "username" => username
      }
    }
  end

  defp get_inner_text(html_element), do: html_element |> Floki.text() |> String.trim

  defp click_loop("visible", count) when count > 0 do
    new_count = count - 1
    click(find_element(:id, "load-more-reviews"))
    :timer.sleep(1000)

    find_element(:id, "load-more-reviews")
    |> css_property("visibility")
    |> click_loop(new_count)

  end

  defp click_loop(_, 0) do
    :click_limit_reached
  end

  defp click_loop(_, _) do
    :page_loaded
  end

  # defp get_dt_now() do
  #   utc_now = DateTime.utc_now()
  #   timezone = "Asia/Singapore"
  #   singapore_time = DateTime.shift_zone(utc_now, timezone)
  #   hours = singapore_time.hour
  #   minutes = singapore_time.minute
  #   seconds = singapore_time.second

  #   time_str = "#{hours}:#{minutes}:#{seconds}"

  # end
end
