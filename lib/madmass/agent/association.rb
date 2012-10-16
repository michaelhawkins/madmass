module Madmass
  module Agent
    module Association

      def self.included klass
        klass.class_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def associate_with_agent(klass)
          if DataModel == Relational
            extend ActiveRecordClassMethods
          elsif DataModel == Cloudtm
            extend CloudTmClassMethods
          else
            Madmass.logger.error "Class #{klass.superclass} not supported for Madmass::Agent::Association"
          end

          associate_with(klass)
        end
      end

      module ActiveRecordClassMethods
        def associate_with(klass)
          has_one :player, :class_name => klass
        end
      end

      module CloudTmClassMethods
        def associate_with(klass)
          class_eval do
            include Madmass::Agent::Association::CloudTmInstanceMethods
          end
        end
      end

      module CloudTmInstanceMethods
        # TODO: to check
        def player
          pl = DataModel::Player.where(:id => agent_id).first
          @player ||= pl
        end

        def player=(pl)
          update_attribute(:agent_id, pl.oid)
          @player = pl
        end

        def create_player!
          _player = DataModel::Player.create
          _player.user = self
          update_attribute(:agent_id, _player.oid)
          @player = _player
        end

      end

    end
  end
end