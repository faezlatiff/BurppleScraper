defmodule Atlas.Hound do
  use Hound.Helpers
  @url "https://www.burpple.com/neighbourhoods/sg/chinatown"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)

    offset = 0
    file_path = "./tmp/burpple_scraper.json"
    find_all_elements(:css, ".food.card.feed-item")
    |> scrape(file_path, offset)

    Hound.end_session()

  end

  defp scrape(list, file_path, offset) do
    Enum.drop(list, offset)
    |> Enum.each(fn element ->
        post_map =
          inner_html(element)
          |> Floki.parse_document()
          |> into_map()
          |> check_date()
          |> maybe_store_and_click(file_path, offset)
    end)
  end

  defp into_map({:ok, html_tree}) do
    name = Floki.find(html_tree, ".food-venue-detail--title") |> get_inner_text()
    address = Floki.find(html_tree, ".food-venue-detail--address") |> get_inner_text()
    title = Floki.find(html_tree, ".food-description-title") |> get_inner_text()
    body = Floki.find(html_tree, ".food-description-body") |> get_inner_text()
    username = Floki.find(html_tree, ".card-item-set--link-title") |> get_inner_text()
    date = Floki.find(html_tree, ".card-item-set--link-subtitle") |> get_inner_text()

    %{
      name =>
      %{"name" => name,
        "address" => address,
        "title" => title,
        "body" => body,
        "username" => username,
        "date" => date
      }
    }
  end

  defp check_date(map) do
    map
    |> Map.values()
    |> Enum.filter(fn map ->
      String.split(map["date"])
      |> Enum.reverse()
      |> Enum.at(0)
      |> check_year()
      |> Kernel.<(2021)
      end)
    |> Enum.at(0)
  end

  defp check_year(year_str) do
    try do
      year = String.to_integer(year_str)
    rescue
      _ ->
        year = 2020
    end
  end

  defp maybe_store_and_click(map, file_path, offset) when is_map(map) do
    File.write(file_path, Jason.encode!(map) <> "\n", [:append])
    check_visible_and_click(file_path,offset)
  end

  defp maybe_store_and_click(_, file_path, offset), do: check_visible_and_click(file_path,offset)

  defp get_inner_text(html_element), do: html_element |> Floki.text() |> String.trim

  defp check_visible_and_click(file_path, offset) do
    button = find_element(:id, "load-more-reviews")
    button_visibility = button |> css_property("visibility")
    case button_visibility do
      "visible" ->
        click(button)
        find_all_elements(:css, ".food.card.feed-item")
        |> scrape(file_path, offset + 12)
      _ ->
        Hound.end_session()
    end
  end

end
