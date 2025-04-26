# Load environment variables from .env file
begin
  require 'dotenv'
  Dotenv.load
  
  puts "Environment variables loaded successfully!"
  Rails.logger.info("Environment variables loaded successfully!") if defined?(Rails) && Rails.logger
rescue => e
  puts "Error loading environment variables: #{e.message}"
  Rails.logger.error("Error loading environment variables: #{e.message}") if defined?(Rails) && Rails.logger
end 