require "builder"
require "net/http"
require "net/https"
require "nori"
require "tempfile"
require "base64"
require "dry-monads"

require "fcb/version"
require "fcb/report"
require "fcb/behavioral_scoring"
require "fcb/verification"
require "fcb/credit_request"
require "fcb/upload_zipped_data"
require "fcb/get_batch_status"
require "fcb/get_report"

M = Dry::Monads

module FCB
  # Your code goes here...
end
