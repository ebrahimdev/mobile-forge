import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["handle", "top", "bottom"]

  connect() {
    this.handleTarget.addEventListener("mousedown", this.startResize.bind(this))
    this.handleTarget.addEventListener("touchstart", this.startResize.bind(this), { passive: false })
  }

  disconnect() {
    this.handleTarget.removeEventListener("mousedown", this.startResize.bind(this))
    this.handleTarget.removeEventListener("touchstart", this.startResize.bind(this))
  }

  startResize(e) {
    e.preventDefault()

    const isTouch = e.type === "touchstart"
    const startY = isTouch ? e.touches[0].clientY : e.clientY
    const startHeight = this.topTarget.offsetHeight
    const containerHeight = this.element.offsetHeight
    const minHeight = 100

    const onMove = (e) => {
      const currentY = isTouch ? e.touches[0].clientY : e.clientY
      const delta = currentY - startY
      const newHeight = Math.max(minHeight, Math.min(containerHeight - minHeight, startHeight + delta))

      // Calculate the percentage height
      const percentage = (newHeight / containerHeight) * 100

      // Set flex-basis to maintain the height
      this.topTarget.style.flex = `0 0 ${percentage}%`
      this.bottomTarget.style.flex = `1 1 auto`
    }

    const onEnd = () => {
      if (isTouch) {
        document.removeEventListener("touchmove", onMove)
        document.removeEventListener("touchend", onEnd)
      } else {
        document.removeEventListener("mousemove", onMove)
        document.removeEventListener("mouseup", onEnd)
      }
      document.body.style.cursor = ""
      document.body.style.userSelect = ""
    }

    if (isTouch) {
      document.addEventListener("touchmove", onMove, { passive: false })
      document.addEventListener("touchend", onEnd)
    } else {
      document.addEventListener("mousemove", onMove)
      document.addEventListener("mouseup", onEnd)
      document.body.style.cursor = "ns-resize"
      document.body.style.userSelect = "none"
    }
  }
} 