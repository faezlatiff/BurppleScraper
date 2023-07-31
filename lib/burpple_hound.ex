defmodule Burpple.Hound do
  use Hound.Helpers
  @base_url "https://www.burpple.com"
  @neighbourhood "tuas"
  @url "https://www.burpple.com/neighbourhoods/sg/#{@neighbourhood}"
  @limit 4000
  @file_path "./tmp/#{@neighbourhood}.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)

    offset = 0
    find_all_elements(:css, ".food.card.feed-item")
    |> scrape(@file_path, offset)

    Hound.end_session()

  end

  defp scrape(list, file_path, offset) when offset < @limit do
    Enum.drop(list, offset) |>
     Enum.each(fn element ->
        post_map =
          inner_html(element)
          |> Floki.parse_document()
          |> into_map()
          # |> check_date()
          |> store(file_path, offset)
    end)
    check_visible_and_click(file_path, offset)

  end

  defp scrape(:scrape_limit_reached, _, _), do: IO.puts("Scraped #{@limit} items, scraper stopping... \nTo scrape more items, change the @limit setting.")
  defp scrape(:no_more_data), do: IO.puts("No more data to scrape, scraper stopping...")

  defp into_map({:ok, html_tree}) do
    name = Floki.find(html_tree, ".food-venue-detail--title") |> get_inner_text()
    address = Floki.find(html_tree, ".food-venue-detail--address") |> get_inner_text()
    title = Floki.find(html_tree, ".food-description-title") |> get_inner_text()
    body = Floki.find(html_tree, ".food-description-body") |> get_inner_text()
    reviewer_name = Floki.find(html_tree, ".card-item-set--link-title") |> get_inner_text()
    link = Floki.find(html_tree, ".food-image") |> Floki.find("a") |> Floki.attribute("href") |> Enum.at(0) |> make_url()
    date = Floki.find(html_tree, ".card-item-set--link-subtitle") |> get_inner_text() |> String.split("·") |> Enum.at(0) |> String.trim

    %{
      name =>
      %{
        "address" => address,
        "title" => title,
        "body" => body,
        "reviewer_name" => reviewer_name,
        "date" => date,
        "link" => link
      }
    }
  end

  defp store(map, file_path, offset) when is_map(map) do
    File.write(file_path, Jason.encode!(map) <> "\n", [:append])
  end

  defp check_visible_and_click(file_path, offset) do
    button = find_element(:id, "load-more-reviews")
    button_visibility = button |> css_property("visibility")
    case button_visibility do
      "visible" ->
        click(button)
        :timer.sleep(2000)
        find_all_elements(:css, ".food.card.feed-item")
        |> scrape(file_path, offset + 12)
      _ ->
        scrape(:no_more_data)
        Hound.end_session()
    end
  end

  defp get_inner_text(html_element), do: html_element |> Floki.text() |> String.trim

  defp make_url(link), do: "#{@base_url}#{link}"

  # defp check_date(map) do
  #   map
  #   |> Map.values()
  #   |> Enum.filter(fn map ->
  #     String.split(map["date"])
  #     |> Enum.reverse()
  #     |> Enum.at(0)
  #     |> check_year()
  #     |> Kernel.<(2021)
  #     end)
  #   |> Enum.at(0)
  # end

  # defp check_year(year_str) do
  #   try do
  #     year = String.to_integer(year_str)
  #   rescue
  #     _ ->
  #       year = 2020
  #   end
  # end

end
