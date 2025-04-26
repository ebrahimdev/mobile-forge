class Message < ApplicationRecord
  validates :role, presence: true, inclusion: { in: ['user', 'assistant', 'system'] }
  validates :content, presence: true
  
  # Status can be: 'pending', 'completed', 'failed'
  validates :status, presence: true, inclusion: { in: ['pending', 'completed', 'failed'] }
  
  scope :for_conversation, ->(conversation_id) { where(conversation_id: conversation_id).order(created_at: :asc) }
  
  def self.create_user_message(content, conversation_id)
    create(
      role: 'user',
      content: content,
      status: 'completed',
      conversation_id: conversation_id || SecureRandom.uuid
    )
  end
  
  def self.create_pending_assistant_message(conversation_id)
    create(
      role: 'assistant',
      content: '',
      status: 'pending',
      conversation_id: conversation_id
    )
  end
  
  def complete(content)
    update(content: content, status: 'completed')
  end
  
  def fail(error_message = nil)
    update(
      content: error_message || "Sorry, I couldn't process your request.",
      status: 'failed'
    )
  end
end 