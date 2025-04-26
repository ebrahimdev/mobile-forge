import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "input", "form"]

  connect() {
    this.scrollToBottom()
  }

  submit(event) {
    event.preventDefault()

    const content = this.inputTarget.value.trim()
    if (!content) return

    // Clear the input field immediately
    this.inputTarget.value = ""

    // Add the user message to the chat
    this.addMessage("user", content)

    // Add a temporary loading message
    const loadingMessage = this.addMessage("assistant", "...", true)

    // Submit the form data via AJAX
    fetch(this.formTarget.action, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({
        message: { content }
      })
    })
      .then(response => response.json())
      .then(data => {
        // Start checking for the assistant's response
        this.pollForAssistantResponse(data.assistant_message.id, loadingMessage)
      })
      .catch(error => {
        console.error("Error sending message:", error)
        this.updateMessage(loadingMessage, "Sorry, an error occurred. Please try again.")
      })
  }

  pollForAssistantResponse(messageId, loadingElement) {
    const checkMessage = () => {
      fetch(`/messages/${messageId}.json`)
        .then(response => response.json())
        .then(message => {
          if (message.status === 'completed') {
            this.updateMessage(loadingElement, message.content)
            this.scrollToBottom()
          } else if (message.status === 'failed') {
            this.updateMessage(loadingElement, "Sorry, I couldn't process that request.")
          } else {
            // Still pending, check again in a moment
            setTimeout(checkMessage, 1000)
          }
        })
        .catch(error => {
          console.error("Error polling for response:", error)
          this.updateMessage(loadingElement, "Sorry, an error occurred while waiting for a response.")
        })
    }

    // Start polling
    setTimeout(checkMessage, 1000)
  }

  addMessage(role, content, isLoading = false) {
    const messageElement = document.createElement("div")
    messageElement.className = `message ${role} ${isLoading ? 'loading' : ''}`
    messageElement.innerHTML = `
      <div class="message-content">
        <p>${content}</p>
      </div>
    `
    this.messagesTarget.appendChild(messageElement)
    this.scrollToBottom()
    return messageElement
  }

  updateMessage(element, content) {
    element.querySelector("p").textContent = content
    element.classList.remove("loading")
  }

  scrollToBottom() {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }
} 