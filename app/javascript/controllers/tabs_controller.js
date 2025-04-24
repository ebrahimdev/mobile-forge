import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content", "dot"]
  static values = {
    current: { type: Number, default: 0 }
  }

  connect() {
    this.touchStartX = 0
    this.element.addEventListener("touchstart", this.handleTouchStart.bind(this))
    this.element.addEventListener("touchmove", this.handleTouchMove.bind(this))
    this.element.addEventListener("touchend", this.handleTouchEnd.bind(this))
    this.showTab(this.currentValue)
  }

  disconnect() {
    this.element.removeEventListener("touchstart", this.handleTouchStart.bind(this))
    this.element.removeEventListener("touchmove", this.handleTouchMove.bind(this))
    this.element.removeEventListener("touchend", this.handleTouchEnd.bind(this))
  }

  handleTouchStart(e) {
    this.touchStartX = e.touches[0].clientX
  }

  handleTouchMove(e) {
    e.preventDefault()
  }

  handleTouchEnd(e) {
    const touchEndX = e.changedTouches[0].clientX
    const diff = touchEndX - this.touchStartX
    const threshold = 50 // minimum distance for swipe

    if (Math.abs(diff) > threshold) {
      if (diff > 0 && this.currentValue > 0) {
        // Swipe right
        this.currentValue--
      } else if (diff < 0 && this.currentValue < this.tabTargets.length - 1) {
        // Swipe left
        this.currentValue++
      }
      this.showTab(this.currentValue)
    }
  }

  showTab(index) {
    // Update the fixed header with the current tab title
    const currentTabTitle = document.getElementById("current-tab-title")
    const activeTabTitle = this.tabTargets[index].textContent

    if (currentTabTitle) {
      currentTabTitle.textContent = activeTabTitle
    }

    // Hide all content sections except the current one
    this.contentTargets.forEach((content, i) => {
      content.classList.toggle("hidden", i !== index)
    })

    // Update dot indicators
    this.dotTargets.forEach((dot, i) => {
      dot.classList.toggle("bg-gray-400", i !== index)
      dot.classList.toggle("bg-gray-800", i === index)
    })

    // Update the current value to trigger any observers
    this.currentValue = index
  }
} 