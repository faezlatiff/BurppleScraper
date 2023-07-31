# Scraper with Elixir & Hound    
An Elixir-based crawler using Hound and Floki to invoke a "load more" button on the scraped page. I faced an issue where I had to simulate a click event and wait for a page to load, so I built this scraper to help me with that. 

## How to run Elixir-based Crawler
### Getting a webdriver
Since we need to interact with the page a little, you'll need to install a webdriver. For this case, I used a chromedriver, a webdriver for Google Chrome.
1. Download and install a chromedriver here (make sure it supports your Google Chrome version): [Versions 115 & later](https://googlechromelabs.github.io/chrome-for-testing/#stable), [Older Versions](https://chromedriver.chromium.org/downloads)
2. Run in terminal: `chromedriver`
### Run the scraper
1. Run in another terminal: `mix deps.get`
2. Run in terminal:
   - `iex -S mix run -e "Burpple.Hound.run"` for Burpple
   - `iex -S mix run -e "Lemon8.Hound.run"` for Lemon8

## Configuring the Crawler
### burpple_hound.ex
`@neighbourhood`: Sets the neighbourhood to be scraped. Ensure that it's available on Burpple. <br/>
`@limit`: Sets when to stop scraping (default 4000)
### lemon8_hound.ex
(in progress)
