import { Controller } from "@hotwired/stimulus"

// Displays a live "X / MAX" character count below a text input or textarea.
// Usage:
//   <div data-controller="char-counter" data-char-counter-max-value="500">
//     <textarea data-char-counter-target="input" data-action="input->char-counter#update"></textarea>
//     <span data-char-counter-target="count"></span>
//   </div>
export default class extends Controller {
  static targets = ["input", "count"]
  static values  = { max: Number }

  connect () {
    this.update()
  }

  update () {
    const len = this.inputTarget.value.length
    const max = this.maxValue
    this.countTarget.textContent = `${len} / ${max}`
    this.countTarget.classList.toggle("char-counter--near", len >= max * 0.85)
    this.countTarget.classList.toggle("char-counter--over", len >= max)
    this.inputTarget.classList.toggle("is-invalid", len >= max)
  }
}
