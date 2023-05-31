defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json", "application/sparql-results+json" ]
  ]

  @any %{}
  @json %{ accept: %{ json: true } }
  @html %{ accept: %{ html: true } }

  # In order to forward the 'themes' resource to the
  # resource service, use the following forward rule:
  #
  # match "/themes/*path", @json do
  #   Proxy.forward conn, path, "http://resource/themes/"
  # end
  #
  # Run `docker-compose restart dispatcher` after updating
  # this file.

  ###############
  # RESOURCES
  ###############
  get "/administrative-units/*path", @json do
    Proxy.forward conn, path, "http://resources/administrative-units/"
  end

  get "/agenda-item-handlings/*path", @json do
    Proxy.forward conn, path, "http://resources/agenda-item-handlings/"
  end

  get "/agenda-items/*path", @json do
    Proxy.forward conn, path, "http://resources/agenda-items/"
  end

  get "/locations/*path", @json do
    Proxy.forward conn, path, "http://resources/locations/"
  end

  get "/mandataries/*path", @json do
    Proxy.forward conn, path, "http://resources/mandataries/"
  end

  get "/resolutions/*path", @json do
    Proxy.forward conn, path, "http://resources/resolutions/"
  end

  get "/sessions/*path", @json do
    Proxy.forward conn, path, "http://resources/sessions/"
  end

  get "/votes/*path", @json do
    Proxy.forward conn, path, "http://resources/votes/"
  end

  ###############
  # SERVICES
  ###############
  post "/sparql/*path", @json do
    forward conn, path, "http://triplestore:8890/sparql/"
  end

  # to generate uuids manually
  match "/uuid-generation/run/*path", @json do
    Proxy.forward conn, [], "http://uuid-generation/run"
  end

  ###############
  # FRONTEND
  ###############
  match "/assets/*path", @html do
    Proxy.forward conn, path, "http://frontend/assets/"
  end

  match "/@appuniversum/*path", @html do
    Proxy.forward conn, path, "http://frontend/@appuniversum/"
  end

  match "/*path", @html do
    Proxy.forward conn, [], "http://frontend/index.html"
  end

  match "/*_path", @html do
    Proxy.forward conn, [], "http://frontend/index.html"
  end

  #################
  # NOT FOUND
  #################
  match "/*_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
