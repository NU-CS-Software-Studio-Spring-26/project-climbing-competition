import { Controller } from "@hotwired/stimulus"

// Prevent scientific notation and non-integer characters in attempt count fields.
export default class extends Controller {
  blockInvalidKey(event) {
    if (["e", "E", "+", "-"].includes(event.key)) {
      event.preventDefault()
    }
  }

  sanitizePaste(event) {
    const pasted = (event.clipboardData?.getData("text") || "").trim()
    if (!/^\d+$/.test(pasted)) {
      event.preventDefault()
    }
  }
}
