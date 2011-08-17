# This is the transaction manager adapter for Active Record.
module Madmass
  module Atomic

    class ActiveRecordAdapter
      class << self
        def transaction &block
          ActiveRecord::Base.transaction do
            block.call
          end
        end
      end
    end

  end
end
