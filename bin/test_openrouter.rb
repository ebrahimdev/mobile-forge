#!/usr/bin/env ruby
require 'dotenv'
require 'faraday'
require 'json'

# Load environment variables
Dotenv.load

api_key = ENV['OPENROUTER_API_KEY']
puts "API Key status: #{api_key ? "Present" : "Missing"}"
puts "API Key prefix: #{api_key ? api_key[0..5] : "N/A"}"

if api_key.nil? || api_key.empty?
  puts "ERROR: OPENROUTER_API_KEY is missing. Please add it to your .env file."
  exit 1
end

puts "Testing OpenRouter API connection..."

begin
  url = 'https://openrouter.ai/api/v1/chat/completions'
  
  connection = Faraday.new(url: url) do |conn|
    conn.headers['Content-Type'] = 'application/json'
    conn.headers['Authorization'] = "Bearer #{api_key}"
    conn.headers['HTTP-Referer'] = 'https://example.com'
    conn.headers['X-Title'] = 'Mobile Forge Test'
  end
  
  payload = {
    model: "meta-llama/llama-3.1-8b-instruct:free",
    messages: [
      { role: "system", content: "You are a helpful programming assistant skilled in writing clean, efficient code." },
      { role: "user", content: "Write a simple function in Ruby to check if a number is prime." }
    ],
    temperature: 0.7,
    # Optional fallback models - all free models
    models: ["mistralai/mistral-7b-instruct:free", "mistralai/mistral-nemo:free"]
  }
  
  response = connection.post do |req|
    req.body = payload.to_json
  end
  
  if response.status == 200
    parsed_response = JSON.parse(response.body)
    if parsed_response["choices"] && parsed_response["choices"].any?
      puts "\n✅ SUCCESS! API connection works."
      puts "Response: #{parsed_response["choices"][0]["message"]["content"]}"
      puts "\nFull response:"
      puts JSON.pretty_generate(parsed_response)
    else
      puts "\n❌ ERROR: Received unexpected response format."
      puts "Response: #{parsed_response.inspect}"
    end
  else
    puts "\n❌ ERROR: API request failed with status #{response.status}"
    puts "Response: #{response.body}"
  end
rescue => e
  puts "\n❌ ERROR: #{e.message}"
  puts e.backtrace.join("\n")
end 