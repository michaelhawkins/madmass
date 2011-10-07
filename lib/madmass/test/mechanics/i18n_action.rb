# To change this template, choose Tools | Templates
# and open the template in the editor.

module Madmass
  module Test

    # This is a simple test action.
    class I18nAction < Madmass::Mechanics::Action



      def execute
        true
      end

      def build_result
         p = Madmass::Perception::Percept.new(self)
         p.add_headers({:topics => 'all', :clients => '1'})
         p.status = {:code => '100'}
         p.data =  {:message => :hello_message, :deep => {:one => "ciao!", :two => :second_message}}
         Madmass.current_perception << p
      end

    end

  end
end
