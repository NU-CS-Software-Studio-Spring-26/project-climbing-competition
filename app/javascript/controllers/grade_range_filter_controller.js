import { Controller } from "@hotwired/stimulus"

const MENU_STORAGE_KEY = "competitionsFilterMenuOpen"
const GRADE_MAX = 16

export default class extends Controller {
  static targets = [ "min", "max", "minLabel", "maxLabel", "control" ]

  connect() {
    this.syncFromInputs()
  }

  update() {
    let min = parseInt(this.minTarget.value, 10)
    let max = parseInt(this.maxTarget.value, 10)

    if (min > max) {
      if (this.activeThumb === "min") {
        max = min
        this.maxTarget.value = max
      } else {
        min = max
        this.minTarget.value = min
      }
    }

    this.refreshUI(min, max)
  }

  pointerDown(event) {
    this.activeThumb = event.target === this.minTarget ? "min" : "max"
    this.controlTarget.classList.toggle("is-dragging-min", this.activeThumb === "min")
    this.controlTarget.classList.toggle("is-dragging-max", this.activeThumb === "max")
  }

  apply() {
    this.controlTarget.classList.remove("is-dragging-min", "is-dragging-max")
    sessionStorage.setItem(MENU_STORAGE_KEY, "true")
    this.element.requestSubmit()
  }

  syncFromInputs() {
    const min = parseInt(this.minTarget.value, 10)
    const max = parseInt(this.maxTarget.value, 10)
    this.refreshUI(min, max)
  }

  refreshUI(min, max) {
    if (this.hasMinLabelTarget) this.minLabelTarget.textContent = this.gradeLabel(min)
    if (this.hasMaxLabelTarget) this.maxLabelTarget.textContent = this.gradeLabel(max)

    if (this.hasControlTarget) {
      this.controlTarget.style.setProperty("--range-min", min / GRADE_MAX)
      this.controlTarget.style.setProperty("--range-max", max / GRADE_MAX)
    }
  }

  gradeLabel(grade) {
    return grade >= 10 ? "V10+" : `V${grade}`
  }
}
