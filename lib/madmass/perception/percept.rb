# This class represents a single Percept generated as result of, possibly part of,
# an action. The current perception is an array of such percepts. Each percept
# is composed of three Hashes: the header, the data and the status.

module Madmass
  module Perception
    class Percept
      attr_reader  :header, :data, :status
      attr_writer :data, :status

      def add_headers headers
        @header.merge! headers
      end

      def initialize(context = nil)
          base_header = {:agent_id => "#{Madmass.current_agent.id}"}
          base_header.merge!({:action => context.class.name}) if context
          @header = HashWithIndifferentAccess.new(base_header)
          @data = HashWithIndifferentAccess.new
          @status = HashWithIndifferentAccess.new(:code => 'ok')
      end

      #Deep copy of the percept
      def clone
        tp = Percept.new
        tp.add_headers(@header.clone)
        tp.status = @status.clone
        tp.data = @data.clone
        return tp
      end

      
      #Returns a translated clone of the Percept.
      #Only the data hash is affected
      def translate
        return self if data.any?
        tp = self.clone
        recursive_translate(tp.data)
        return tp
      end

      # Does a deep (recursive) translation of the content hash passed as argument.
      # Any value in the  hash that corresponds to a key in the translation
      # file is translated.
      # *Note* The method does side-effect on the content
      def recursive_translate content
          
        content.each do |key,value|
          if value.is_a?(Hash)
            recursive_translate value
          else
            translation = I18n.t(value) if(value.is_a? Symbol)
            content[key] = translation if translation
          end
        end
      end
      
    end
  end
end
