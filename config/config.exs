import Config

# for burpple
config :hound, driver: "chrome_driver", browser: "chrome_headless", server: true

# for lemon8 or explorest
# config :hound,
#   host: "http://localhost",
#   port: 4444,
#   path_prefix: "wd/hub/"
