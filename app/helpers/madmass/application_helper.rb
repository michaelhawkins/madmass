module Madmass
  module ApplicationHelper

    # Use this helper to regiter the client with the socky server. Put it
    # somewhere in the views. It accepts options in the form of:
    # {
    #   :channels => [array of channel identifiers],
    #   :client => client identifier
    # }
    # Channels are used to broadcast messages to everyone while client is
    # used to send private messges only to the client.
    def register_websocket(options)
      if(!options.kind_of?(Hash) or (options[:channels].blank? and options[:client].blank?))
        raise Madmass::Errors::CatastrophicError, "Wrong socky registration: #{options.inspect}"
      end

      ws_client = Madmass.install_options(:ws_client)
      case ws_client
      when :socky
        madsocky(:channels => options[:channels], :client_id => options[:client])
      when :stilts
        stilts(:channels => options[:channels], :client_id => options[:client])
      else
        raise Madmass::Errors::WrongInputError, "Cannot find the web socket client library: #{ws_client}"
      end
    end

    def madsocky(options)
      host = Socky.random_host
      options = {
        :host                 => (host[:secure] ? "wss://" : "ws://") + host[:host],
        :port                 => host[:port],
      }.merge(options)
      javascript_tag <<SOCKY_JS
        $(window).load(function() {
          new Socky('#{options.delete(:host)}', '#{options.delete(:port)}', '#{options.to_query}');
        });
SOCKY_JS
    end

    def stilts(options)
      connection_options = {
        :host => Madmass.install_options(:stomplet_host),
        :port => Madmass.install_options(:stomplet_port),
        :topic => Madmass.install_options(:stomplet_topic)
      }
      javascript_tag <<STILTS_JS
        $(window).load(function() {
          var stiltsClient = Madmass.Stomp.getInstance(#{connection_options.to_json});
          stiltsClient.register();
        });
STILTS_JS
    end

  end
end
