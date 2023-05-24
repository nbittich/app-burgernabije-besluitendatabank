defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
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
  get "/agenda-item-handlings/*path", @json do
    Proxy.forward conn, path, "http://resources/agenda-item-handlings/"
  end

  get "/agenda-items/*path", @json do
    Proxy.forward conn, path, "http://resources/agenda-items/"
  end

  get "/mandatories/*path", @json do
    Proxy.forward conn, path, "http://resources/mandatories/"
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

  get "/tests/*path", @json do
    Proxy.forward conn, path, "http://resources/tests/"
  end

  ###############
  # SERVICES
  ###############
  match "/uuid-generator/*path", @json do
    Proxy.forward conn, path, "http://uuid-generator/"
  end

  ###############
  # FRONTEND
  ###############
  get "/*path", @json do
    Proxy.forward conn, path, "http://frontend/"
  end

  #################
  # NOT FOUND
  #################
  match "/*_", %{ last_call: true } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
