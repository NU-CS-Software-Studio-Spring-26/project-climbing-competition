import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "display" ]
  static values = {
    targetAt: String,
    expiredLabel: { type: String, default: "ended" }
  }

  connect() {
    this.tick()
    this.timer = window.setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    window.clearInterval(this.timer)
  }

  tick() {
    const targetAt = Date.parse(this.targetAtValue)
    if (Number.isNaN(targetAt)) {
      this.displayTarget.textContent = "—"
      return
    }

    const remainingMs = Math.max(0, targetAt - Date.now())
    if (remainingMs === 0) {
      this.displayTarget.textContent = this.expiredLabelValue
      window.clearInterval(this.timer)
      return
    }

    this.displayTarget.textContent = this.formatRemaining(remainingMs)
  }

  formatRemaining(remainingMs) {
    const totalSeconds = Math.floor(remainingMs / 1000)
    const days = Math.floor(totalSeconds / 86_400)
    const hours = Math.floor((totalSeconds % 86_400) / 3_600)
    const minutes = Math.floor((totalSeconds % 3_600) / 60)
    const seconds = totalSeconds % 60

    const parts = []
    if (days > 0) parts.push(`${days}d`)
    if (days > 0 || hours > 0) parts.push(`${hours}h`)
    parts.push(`${minutes}m`)
    parts.push(`${String(seconds).padStart(2, "0")}s`)

    return parts.join(" ")
  }
}
