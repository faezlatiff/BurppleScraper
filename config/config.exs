import Config

config :hound, driver: "chrome_driver", browser: "chrome_headless"

config :crawly,

  closespider_timeout: :disabled,
  concurrent_requests_per_domain: 1,
  closespider_itemcount: :disabled,
  # fetcher: {Crawly.Fetchers.Splash, [base_url: "http://localhost:8050/render.html"]},
  middlewares: [
    Crawly.Middlewares.DomainFilter,
    {Crawly.Middlewares.UserAgent, user_agents: ["Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36"]}
  ],
  pipelines: [
    Crawly.Pipelines.JSONEncoder,
    {Crawly.Pipelines.WriteToFile, extension: "json", folder: "./tmp"}
  ],
  server: true

    # https://www.burpple.com/neighbourhoods/sg/chinatown
