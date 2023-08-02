import Config

# for burpple
# config :hound, driver: "chrome_driver", browser: "chrome_headless", server: true

# for lemon8
config :hound,
  # driver: "chrome_driver",
  host: "http://localhost",
  port: 4444,
  path_prefix: "wd/hub/"
