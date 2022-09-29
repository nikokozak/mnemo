import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :content_client, ContentClientWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "cLbabgU5p+YPnSK6cxl3WDNt8nJf3MD6ijK8nBv1cUwF6AXz6ypC7CTJ93AMl+R8",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
