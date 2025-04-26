class MessagesController < ApplicationController
  before_action :set_conversation_id
  before_action :set_message, only: [:show]

  def index
    @messages = Message.for_conversation(@conversation_id)
    
    respond_to do |format|
      format.html
      format.json { render json: @messages }
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json { render json: @message }
    end
  end

  def create
    # Save the user's message
    @user_message = Message.create_user_message(message_params[:content], @conversation_id)
    
    # Create a pending assistant message
    @assistant_message = Message.create_pending_assistant_message(@conversation_id)
    
    # Get all messages for this conversation to provide context
    conversation_messages = Message.for_conversation(@conversation_id)
    
    # Process the message asynchronously
    process_with_ai(conversation_messages, @assistant_message)
    
    # Return immediately with the messages
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { 
        render json: {
          user_message: @user_message,
          assistant_message: @assistant_message
        }
      }
    end
  end

  private
  
  def set_conversation_id
    @conversation_id = params[:conversation_id] || session[:conversation_id] || SecureRandom.uuid
    session[:conversation_id] = @conversation_id
  end
  
  def set_message
    @message = Message.find(params[:id])
  end
  
  def message_params
    params.require(:message).permit(:content)
  end
  
  def process_with_ai(conversation_messages, assistant_message)
    # Filter out any pending messages and ensure they have content
    valid_messages = conversation_messages.reject { |m| m.status == 'pending' || m.content.blank? }
    
    # Make sure we have system message for context
    unless valid_messages.any? { |m| m.role == 'system' }
      system_message = Message.new(
        role: 'system',
        content: 'You are a helpful assistant. Respond concisely and accurately.',
        status: 'completed',
        conversation_id: @conversation_id
      )
      valid_messages.unshift(system_message)
    end
    
    # In a real application, this should be done in a background job
    # But for simplicity, we'll do it inline
    begin
      service = OpenrouterService.new
      # You can customize the model to use by changing the second parameter
      response = service.chat_completion(valid_messages)
      
      if response[:success]
        assistant_message.complete(response[:content])
      else
        Rails.logger.error("AI API Error: #{response[:error]}")
        assistant_message.fail(response[:error])
      end
    rescue => e
      Rails.logger.error("Error processing message: #{e.message}")
      assistant_message.fail("An error occurred: #{e.message}")
    end
  end
end 