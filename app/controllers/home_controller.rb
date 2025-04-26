class HomeController < ApplicationController
  def index
    # Get or set the conversation ID
    @conversation_id = session[:conversation_id] || SecureRandom.uuid
    session[:conversation_id] = @conversation_id
    
    # Fetch messages for this conversation
    @messages = Message.for_conversation(@conversation_id)
  end
end
