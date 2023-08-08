defmodule GMaps.Hound do
  use Hound.Helpers
  @url "https://www.google.com/maps"
  @search_term "food near me"
  @file_path "./tmp/gmaps_#{Timex.now() |> Timex.to_date() |> Timex.format("{0D}_{0M}_{YYYY}") |> elem(1)}.json"

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    window_id = current_window_handle()
    set_window_size(window_id, 1280, 972)
    scrape()
    Hound.end_session()
  end

  defp scrape() do
    search_box = find_element(:id, "searchboxinput")

    search_box
    |> fill_field(@search_term)

    find_element(:id, "cell0x0")
    |> click()

    feed = find_element(:css, "div[role='feed']")
    find_all_within_element(feed, :tag, "a")
    |> Enum.each(fn elem ->
      click(elem)
      name = find_element(:tag, "h1") |> inner_text()
      address = find_element(:css, "button[data-item-id='address']")|> inner_text()
      reviews = get_reviews()
      wait(12312313123)

    end)

  end

  defp get_reviews() do
    find_all_elements(:css, "button[role='tab']")
    |> Enum.at(1)
    |> click()

    find_element(:css, "img[alt='Sort']")
    |> click()

    find_element(:css, "div[data-index='1']")
    |> click()
  end


  defp wait(time \\ 1000) do
    :timer.sleep(time)
  end
end
