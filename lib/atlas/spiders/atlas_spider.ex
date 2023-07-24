defmodule AtlasSpider do
  use Crawly.Spider
  import Meeseeks.CSS

  @impl Crawly.Spider
  def base_url do
    "http://www.burpple.com"
  end

  @impl Crawly.Spider
  def init() do
    [
      start_urls: [
        "https://www.burpple.com/neighbourhoods/sg/chinatown"
      ]
    ]
  end

  @impl Crawly.Spider
  def parse_item(response) do
    # xhr = "https://www.burpple.com/foods/load_more?area_id=18&city_id=1&offset=12"
    document = Meeseeks.parse(response.body)
    food = Meeseeks.one(document, css(".food.card.feed-item"))

    shop_name = Meeseeks.one(food, css(".food-venue-detail--title")) |> Meeseeks.text()
    shop_address = Meeseeks.one(food, css(".food-venue-detail--address")) |> Meeseeks.text()
    review_title = Meeseeks.one(food, css("."))




    %Crawly.ParsedItem{:items => [], :requests => []}
  end
end
