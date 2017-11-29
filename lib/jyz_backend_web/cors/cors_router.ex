defmodule JyzBackendWeb.CORS do
  use Corsica.Router,
    origins: ["http://localhost:4200", ~r{^https?://(.*\.?)foo\.com$}],
    allow_headers: ["content-type", "application/json", "Authorization"],
    allow_credentials: true,
    max_age: 600
  
  # resource "/public/*", origins: "*"
  resource "/*", origins: "*"
  # resource "/api/v1/login", origins: "*"
  
end