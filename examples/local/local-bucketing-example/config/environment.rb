# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.logger = Logger.new(STDOUT)
Rails.application.initialize!
