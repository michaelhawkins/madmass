# This error is raised when the applicable() method of an action
# returns false, meaning that the requested error can not be applied
# in the current setting. This type of errors can and must be managed,
# as these errors may occur due to concurrency or mistakes by agents.
module Madmass
  module Errors
    class NotApplicableError < Madmass::Errors::MadmassError
    end
  end
end

