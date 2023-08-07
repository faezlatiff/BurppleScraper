defmodule Lemon8.Hound do
  use Hound.Helpers
  @url "https://www.lemon8-app.com/topic/7093249700899487745?region=sg"
  @file_path "./tmp/lemon8.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    refresh_page()
    scrape()
  end

  defp scrape(counter \\ 0) do
    try do
      find_all_elements(:class, "article-card")
      |> Enum.at(counter)
      |> get_info_navigate_back(counter)
    rescue
      _ ->
        see_more()
        scrape(counter)
    end
  end

  defp get_info_navigate_back(element, counter) do
    click(element)
    store_info()
    navigate_back()
    scrape(counter+1)
  end

  defp store_info() do
    title = find_element(:tag, "h1") |> inner_text()
    body = find_element(:tag, "article") |> inner_text()
    postal = body |> find_postal()
    poster_name = find_element(:class, "name") |> inner_text()

    map = %{
      title: title,
      body: body,
      postal: postal,
      poster_name: poster_name
    }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])

  end

  defp see_more() do

    find_all_elements(:class, "article-card")
    |> List.last()
    |> scroll()

    find_element(:class, "see-more")
    |> check_click()
    |> click()

  end

  defp find_postal(text) do
    Regex.run(~r/Singapore \d{6}/, text)
    |> handle_postal()
  end

  defp scroll(element) when not is_nil(element) do
    {width, height} = element_location(element)
    execute_script("window.scrollTo(#{width},#{height});")
    element
  end
  defp scroll(_), do: navigate_back()

  defp handle_postal(postal) when not is_nil(postal), do: postal
  defp handle_postal(_), do: "no address stated"

  defp check_click(nil), do: navigate_back()
  defp check_click(element), do: element

end
