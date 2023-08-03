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
    # need to change class
    # refresh_page()
    # :timer.sleep(500)
    class = set_class(counter)
    case find_all_elements(:class, class) do
      [] ->
        IO.inspect("no elements found, waiting for page to load...")
        :timer.sleep(500)
        scrape(counter)
      list ->
        list
        |> Enum.at(counter)
        |> attribute_value("href")
        |> store_info
    end

    scrape(counter + 1)
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

  defp store_info(link) do
    navigate_to(link)
    username = find_element(:class, "jss48") |> inner_text()
    map = %{
        "username" => username
      }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])
    navigate_back()
  end

end
