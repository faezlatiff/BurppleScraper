defmodule Explorest.Hound do
  use Hound.Helpers
  @neighbourhood "chinatown"
  @url "https://www.explorest.com/places/singapore/#{@neighbourhood}"
  @file_path "./tmp/explorest.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    # :timer.sleep(999999)

    current_window_handle()
    |> set_window_size(1280, 637)

    scrape()
  end

  defp scrape(counter \\ 0) do
    handle = current_window_handle()

    find_all_elements(:class, "jss32")
    # |> Enum.take(2)
    |> Enum.each(fn elem ->
        click(elem)
        :timer.sleep(1000)
        focus_window(handle)
    end)
    # |> Enum.at(counter)
    # |> get_info_navigate_back(counter)

    :timer.sleep(100000)
  end

  defp get_info_navigate_back(element, counter) do
    click(element)
    store_info()
    navigate_back()
    scrape(counter+1)
  end

  defp store_info() do
    title = find_element(:tag, "h1") |> inner_text()
    map = %{
        "title" => title
      }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])

  end

  # defp see_more() do

  #   find_all_elements(:class, "article-card")
  #   |> List.last()
  #   |> scroll()

  #   find_element(:class, "see-more")
  #   |> check_click()
  #   |> click()

  # end

  # defp find_postal(text) do
  #   Regex.run(~r/Singapore \d{6}/, text)
  #   |> handle_postal()
  # end

  # defp scroll(element) when not is_nil(element) do
  #   {width, height} = element_location(element)
  #   execute_script("window.scrollTo(#{width},#{height});")
  #   element
  # end
  # defp scroll(_), do: navigate_back()

  # defp handle_postal(postal) when not is_nil(postal), do: postal
  # defp handle_postal(_), do: "no address stated"

  # defp check_click(nil), do: navigate_back()
  # defp check_click(element), do: element

end
