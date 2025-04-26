require 'faraday'
require 'json'

class OpenrouterService
  OPENROUTER_API_URL = 'https://openrouter.ai/api/v1/chat/completions'
  
  def initialize
    api_key = ENV['OPENROUTER_API_KEY']
    Rails.logger.info("OpenRouter API Key: #{api_key ? "Key exists" : "Key missing"}")
    
    if api_key.blank?
      raise "OpenRouter API key is missing. Please set the OPENROUTER_API_KEY environment variable."
    end
    
    @api_key = api_key
  end

  def chat_completion(messages, model = 'meta-llama/llama-3.1-8b-instruct:free')
    begin
      Rails.logger.info("Making OpenRouter API call with #{messages.count} messages to model: #{model}")
      
      formatted_messages = messages.map { |message| { role: message.role, content: message.content } }
      
      response = make_api_request(
        model: model,
        messages: formatted_messages,
        temperature: 0.7,
        # Optional fallback models to try if the primary model fails - all free models
        models: ["mistralai/mistral-7b-instruct:free", "mistralai/mistral-nemo:free"]
      )
      
      # Extract the assistant's reply
      if response && response["choices"] && response["choices"].any?
        return { success: true, content: response["choices"][0]["message"]["content"] }
      else
        Rails.logger.error("OpenRouter unexpected response: #{response.inspect}")
        return { success: false, error: 'No response from OpenRouter API' }
      end
    rescue => e
      Rails.logger.error("OpenRouter API Error: #{e.message}")
      return { success: false, error: e.message }
    end
  end
  
  private
  
  def make_api_request(parameters)
    connection = Faraday.new(url: OPENROUTER_API_URL) do |conn|
      conn.headers['Content-Type'] = 'application/json'
      conn.headers['Authorization'] = "Bearer #{@api_key}"
      conn.headers['HTTP-Referer'] = ENV['APP_URL'] || 'https://example.com'
      conn.headers['X-Title'] = 'Mobile Forge Chat'
    end
    
    response = connection.post do |req|
      req.body = parameters.to_json
    end
    
    if response.status == 200
      JSON.parse(response.body)
    else
      Rails.logger.error("OpenRouter API error: Status #{response.status}, Body: #{response.body}")
      raise "OpenRouter API error: #{response.body}"
    end
  end
end 