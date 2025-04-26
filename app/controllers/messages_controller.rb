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
    # This is a placeholder method after removing all LLM integrations
    # Will be replaced with a new implementation
    
    # Create a temporary static response
    assistant_message.complete("This is a placeholder response. LLM integration will be implemented soon.")
  end
end 