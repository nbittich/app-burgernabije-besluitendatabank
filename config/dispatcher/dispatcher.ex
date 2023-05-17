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
  get "/agendapunten/*path", @json do
    Proxy.forward conn, path, "http://resources/agendapunten/"
  end

  get "/behandelingen-van-agendapunten/*path", @json do
    Proxy.forward conn, path, "http://resources/behandelingen-van-agendapunten/"
  end

  get "/stemmingen/*path", @json do
    Proxy.forward conn, path, "http://resources/stemmingen/"
  end

  get "/zittingen/*path", @json do
    Proxy.forward conn, path, "http://resources/zittingen/"
  end

  get "/mandatarissen/*path", @json do
    Proxy.forward conn, path, "http://resources/mandatarissen/"
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
