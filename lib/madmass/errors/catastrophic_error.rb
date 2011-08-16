# This error is an unrecoverable error, mainly detection of inconsistent states.
# This is the worst error possible and should be raised only if one knows there
# is no easy way to handle the error.
module Madmass
  module Errors
    class CatastrophicError < Madmass::Errors::MadmassError
    end
  end
end
