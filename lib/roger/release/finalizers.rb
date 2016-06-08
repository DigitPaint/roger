# The Finalizers will finalize the release. Finalizers can be used to
# copy the release, zip the release or upload the release
module Roger::Release::Finalizers
  extend Roger::Helpers::Registration

  # Abstract base finalizer; This is practically the same as a processor
  class Base < Roger::Release::Processors::Base
  end
end

require File.dirname(__FILE__) + "/finalizers/zip"
require File.dirname(__FILE__) + "/finalizers/dir"
require File.dirname(__FILE__) + "/finalizers/rsync"
require File.dirname(__FILE__) + "/finalizers/git_branch"
