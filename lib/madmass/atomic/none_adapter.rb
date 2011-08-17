# This is the transaction manager adapter that do nothing. 
module Madmass
  module Atomic

    class NoneAdapter
      class << self
        def transaction &block
          block.call
        end
      end
    end

  end
end
