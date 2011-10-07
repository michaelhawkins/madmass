# This is the transaction manager adapter that do nothing. 
module Madmass
  module Transaction

    class NoneAdapter
      class << self
        def transaction &block
          block.call
        end

        def rescues
          {Exception => Proc.new {
              raise exception
            }
          }
        end
        
      end
    end

  end
end
