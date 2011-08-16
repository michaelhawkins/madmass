module Madmass
  module Comm

    class StandardCommStrategy < CommStrategy

      def send_percept percept
        # inform all agents in the app of state changes
        js = [ fire_event('update', percept) ]
        send_to_all [percept[:channel]], js
      end
    end


  end
end
