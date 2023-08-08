defmodule Burpple.Hound do
  use Hound.Helpers
  @neighbourhood "chinatown"
  @url "https://www.burpple.com/neighbourhoods/sg/#{@neighbourhood}"
  @limit 4000

  @file_path "./tmp/burpple_#{@neighbourhood}_#{Timex.now() |> Timex.to_date() |> Timex.format("{0D}_{0M}_{YYYY}") |> elem(1)}.json"

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
          |> store(file_path, offset)
    end)
    check_visible_and_click(file_path, offset)

  end

  defp scrape(:scrape_limit_reached, _, _), do: IO.puts("[ALERT] Scraped #{@limit} items, scraper stopping... \nTo scrape more items, change the @limit setting.")
  defp scrape(:no_more_data), do: IO.puts("[ALERT] No more data to scrape, scraper stopping...")

  defp into_map({:ok, html_tree}) do
    name = Floki.find(html_tree, ".food-venue-detail--title") |> get_inner_text()
    address = Floki.find(html_tree, ".food-venue-detail--address") |> get_inner_text()
    # postal = get_postal(address)
    title = Floki.find(html_tree, ".food-description-title") |> get_inner_text()
    body = Floki.find(html_tree, ".food-description-body") |> get_inner_text()
    reviewer_name = Floki.find(html_tree, ".card-item-set--link-title") |> get_inner_text()
    link = Floki.find(html_tree, ".food-image") |> Floki.find("img") |> Floki.attribute("src") |> Enum.at(0)
    date = Floki.find(html_tree, ".card-item-set--link-subtitle") |> get_inner_text() |> String.split("·") |> Enum.at(0) |> String.trim |> convert_date_string()

    %{
      name: name,
      address: address,
      # postal: postal,
      title: title,
      body: body,
      reviewer_name: reviewer_name,
      date: date,
      link: link
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

  defp convert_date_string(date_string) do
    cond do
      String.contains?(date_string, "h") ->
        hours = get_digit(date_string, "h")
        {:ok, date} =
          Timex.shift(Timex.now("Asia/Singapore"), hours: String.to_integer(hours) * -1)
          |> Timex.to_date()
          |> Timex.format("{0D}/{0M}/{YYYY}")

        date

      String.contains?(date_string, "d") ->
        days = get_digit(date_string, "d")
        {:ok, date} =
          Timex.shift(Timex.now("Asia/Singapore"), days: String.to_integer(days) * -1)
          |> Timex.to_date()
          |> Timex.format("{0D}/{0M}/{YYYY}")

        date

      String.contains?(date_string, "week") ->
        weeks = get_digit(date_string, "week")
        {:ok, date} =
          Timex.shift(Timex.now("Asia/Singapore"), weeks: String.to_integer(weeks) * -1)
          |> Timex.to_date()
          |> Timex.format("{0D}/{0M}/{YYYY}")

        date

      String.contains?(date_string, "at") ->
        date_string
        |> format_date("at")

      String.contains?(date_string, ",") ->
        date_string
        # |> format_date(",")

    end
  end

  defp get_digit(date_string, type) do
    date_string
    |> String.split(type)
    |> Enum.at(0)
  end

  defp format_date(date_string, "at") do
    date_enum =
      String.split(date_string, "at")
      |> Enum.at(0)
      |> String.split(" ")

    month =
      date_enum
      |> Enum.at(0)
      |> month_to_num()

    day =
      date_enum
      |> Enum.at(1)

    "#{day}/#{month}/2023"
  end

  defp format_date(date_string, ",") do
    date_enum =
      String.split(date_string, ",")
      |> Enum.at(0)
      |> String.split(" ")

    month =
      date_enum
      |> Enum.at(0)
      |> month_to_num()

    day =
      date_enum
      |> Enum.at(1)

    year =
      String.split(date_string, ",")
      |> Enum.at(1)
      |> String.trim()

      "#{day}/#{month}/#{year}"
    end

  defp month_to_num(month) do
    months = %{
      "Jan" => "01",
      "Feb" => "02",
      "Mar" => "03",
      "Apr" => "04",
      "May" => "05",
      "Jun" => "06",
      "Jul" => "07",
      "Aug" => "08",
      "Sep" => "09",
      "Oct" => "10",
      "Nov" => "11",
      "Dec" => "12"}

    months[month]

  end

  # defp get_postal(address) do
  #   IO.inspect("checking address")
  #   enum =
  #     read_json_file("postal_codes_22_06_2023.json")
  #     |> Enum.map(fn tuple ->
  #         # Levenshtein.distance(map["address"], address)
  #         tuple
  #         |> elem(1)
  #         |> Map.get("address")
  #         |> Levenshtein.distance(String.upcase(address))
  #       end)
  #   Enum.sort(enum)
  #   |> Enum.reverse()
  #   |> Enum.at(0)

  # end

  # defp read_json_file(file_path) do
  #   File.read(file_path)
  #   |> elem(1)
  #   |> Jason.decode()
  #   |> elem(1)
  # end

end
