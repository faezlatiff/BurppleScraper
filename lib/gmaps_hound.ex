defmodule GMaps.Hound do
  use Hound.Helpers
  @url "https://www.google.com/maps"
  @search_term "food near me"
  @file_path "./tmp/gmaps_#{Timex.now() |> Timex.to_date() |> Timex.format("{0D}_{0M}_{YYYY}") |> elem(1)}.json"
  @limit 10000
  @panels_skip 4

  @spec run :: list
  def run do
    Hound.start_session()
    navigate_to(@url)
    window_id = current_window_handle()
    set_window_size(window_id, 1280, 972)
    fill_search_box()
    scrape()
  end

  defp fill_search_box() do
    search_box = find_element(:id, "searchboxinput")
    search_box
    |> fill_field(@search_term)
    wait(500)

    find_element(:id, "cell0x0")
    |> click()
  end

  defp scrape(counter \\ @panels_skip)
  defp scrape(counter) when counter <= @limit do


    feed = find_element(:css, "div[role='feed']")

    find_all_within_element(feed, :tag, "a")
    |> Enum.drop(counter)
    |> Enum.each(fn elem ->
      click(elem)
      wait(500)
      name = find_all_elements(:tag, "h1")
      |> Enum.reject(fn elem -> elem |> inner_text == "Sponsored" end)
      |> Enum.at(0)
      |> inner_text()

      address = find_element(:css, "button[data-item-id='address']")|> inner_text()
      reviews = get_reviews()
      store(name, address, reviews)
    end)
    scroll()
    scrape(counter + 7)
  end

  defp scrape(counter), do: Hound.end_session()

  defp store(name, address, reviews) do
    map = %{
      name: name,
      address: address,
      reviews: reviews
    }

    File.write(@file_path, Jason.encode!(map) <> "\n", [:append])
  end

  defp get_reviews() do
    # click Reviews
    find_all_elements(:css, "button[role='tab']")
    |> Enum.at(1)
    |> click()
    wait(500)

    # get review details
    find_all_elements(:class, "MyEned")
    |> Enum.map(fn elem ->
        parse_review(elem)
      end)

  end

  defp parse_review(elem) do
    user =
      find_all_elements(:css, "button[jsaction='pane.review.reviewerLink']")
      |> Enum.at(1)
      |> find_all_within_element(:tag, "div")
      |> Enum.at(0)
      |> inner_text()

    review = find_all_within_element(elem, :tag, "span")
      |> Enum.at(0)
      |> inner_text()

    %{user => review}
  end

  defp scroll() do
    div_scroll_script = """
      var div = document.querySelectorAll('[role="feed"]')[0] ;
      div.scrollTop = div.scrollHeight;
    """
    execute_script(div_scroll_script)
    wait(500) # wait for load-more to finish
  end

  # defp check_load(feed) do
  #   # url("https://maps.gstatic.com/tactile/pane/spinner_color_2x.gif")

  #   script = """
  #     var divs = arguments[0]
  #     console.log(divs)
  #   """

  #   execute_script(script, feed)
  #   :timer.sleep(123123123)

  # end

  defp wait(time), do: :timer.sleep(time)

end
