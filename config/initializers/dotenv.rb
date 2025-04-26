# Load environment variables from .env file
begin
  require 'dotenv'
  Dotenv.load
  
  puts "Environment variables loaded successfully!"
  Rails.logger.info("Environment variables loaded successfully!") if defined?(Rails) && Rails.logger
  
  # Check for OpenRouter API key
  if ENV['OPENROUTER_API_KEY'].present?
    puts "OpenRouter API key loaded successfully!"
    Rails.logger.info("OpenRouter API key loaded successfully!") if defined?(Rails) && Rails.logger
  else
    puts "WARNING: OPENROUTER_API_KEY environment variable is not set or is empty."
    Rails.logger.warn("OPENROUTER_API_KEY environment variable is not set or is empty.") if defined?(Rails) && Rails.logger
  end
rescue => e
  puts "Error loading environment variables: #{e.message}"
  Rails.logger.error("Error loading environment variables: #{e.message}") if defined?(Rails) && Rails.logger
end 