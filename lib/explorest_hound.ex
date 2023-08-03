defmodule Explorest.Hound do
  use Hound.Helpers
  @neighbourhood "chinatown"
  @url "https://www.explorest.com/places/singapore/#{@neighbourhood}"
  @file_path "./tmp/explorest.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    current_window_handle()
    |> set_window_size(1657, 802)

    scrape(0)
  end

  defp scrape(counter) do
    # links = []
    elements = find_all_elements(:class, "jss35")
    links = Enum.map(elements, fn elem ->
      attribute_value(elem, "href")
    end)

    store_info(links)
    # scrape(counter + 1)
  end

  defp check_nil(element) when not is_nil(element), do: element
  defp check_nil(element) do
    IO.inspect("element is nil: #{element}")
    IO.inspect("stopping...")
    :timer.sleep(12093123)
  end

  defp inspect_navigate(link) when not is_nil(link), do: navigate_to(link)
  defp inspect_navigate(link), do: IO.inspect("WOI LINK BROKEN: #{link}")

  defp set_class(0), do: "jss35"
  defp set_class(_), do: "jss28"

  defp store_info(links) do
    Enum.each(links, fn link ->
      navigate_to(link)
      store_info()
    end)
  end
  defp store_info() do
    username = find_element(:class, "jss48") |> inner_text()
    map = %{
        "username" => username
      }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])
  end

end
