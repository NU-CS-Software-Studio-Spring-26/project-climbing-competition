import { Controller } from "@hotwired/stimulus"

const MENU_STORAGE_KEY = "competitionsFilterMenuOpen"
const GRADE_MAX = 16

export default class extends Controller {
  static targets = [ "min", "max", "minLabel", "maxLabel", "control", "minThumb", "maxThumb" ]

  connect() {
    this.syncFromInputs()
  }

  minThumbPointerDown(event) {
    event.preventDefault()
    event.stopPropagation()
    this.startDrag("min", event)
  }

  maxThumbPointerDown(event) {
    event.preventDefault()
    event.stopPropagation()
    this.startDrag("max", event)
  }

  controlPointerDown(event) {
    if (event.target !== this.controlTarget) return
    event.preventDefault()

    const min = parseInt(this.minTarget.value, 10)
    const max = parseInt(this.maxTarget.value, 10)
    const value = this.valueFromClientX(event.clientX)
    const distToMin = Math.abs(value - min)
    const distToMax = Math.abs(value - max)

    this.startDrag(distToMin <= distToMax ? "min" : "max", event, value)
  }

  startDrag(thumb, event, initialValue = null) {
    this.dragging = thumb
    this.controlTarget.classList.toggle("is-dragging-min", thumb === "min")
    this.controlTarget.classList.toggle("is-dragging-max", thumb === "max")

    if (initialValue !== null) {
      this.setThumbValue(thumb, initialValue)
    }

    this.pointerMoveHandler = (moveEvent) => {
      moveEvent.preventDefault()
      this.setThumbValue(thumb, this.valueFromClientX(moveEvent.clientX))
    }

    this.pointerEndHandler = (endEvent) => {
      this.endDrag(endEvent)
    }

    document.addEventListener("pointermove", this.pointerMoveHandler)
    document.addEventListener("pointerup", this.pointerEndHandler)
    document.addEventListener("pointercancel", this.pointerEndHandler)
  }

  endDrag(event) {
    document.removeEventListener("pointermove", this.pointerMoveHandler)
    document.removeEventListener("pointerup", this.pointerEndHandler)
    document.removeEventListener("pointercancel", this.pointerEndHandler)
    this.pointerMoveHandler = null
    this.pointerEndHandler = null
    this.dragging = null
    this.controlTarget.classList.remove("is-dragging-min", "is-dragging-max")
    this.apply(event)
  }

  setThumbValue(thumb, rawValue) {
    let min = parseInt(this.minTarget.value, 10)
    let max = parseInt(this.maxTarget.value, 10)
    const value = Math.max(0, Math.min(GRADE_MAX, rawValue))

    if (thumb === "min") {
      min = Math.min(value, max)
      this.minTarget.value = min
    } else {
      max = Math.max(value, min)
      this.maxTarget.value = max
    }

    this.refreshUI(parseInt(this.minTarget.value, 10), parseInt(this.maxTarget.value, 10))
  }

  valueFromClientX(clientX) {
    const rect = this.controlTarget.getBoundingClientRect()
    const thumbSize = this.thumbSizePx()
    const usableWidth = rect.width - thumbSize
    const offsetX = clientX - rect.left - thumbSize / 2
    const ratio = usableWidth > 0 ? Math.max(0, Math.min(1, offsetX / usableWidth)) : 0
    return Math.round(ratio * GRADE_MAX)
  }

  thumbSizePx() {
    const size = getComputedStyle(this.controlTarget).getPropertyValue("--grade-thumb-size").trim()
    if (size.endsWith("rem")) {
      const root = parseFloat(getComputedStyle(document.documentElement).fontSize) || 16
      return parseFloat(size) * root
    }
    return parseFloat(size) || 18
  }

  apply() {
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

    const minRatio = min / GRADE_MAX
    const maxRatio = max / GRADE_MAX

    if (this.hasControlTarget) {
      this.controlTarget.style.setProperty("--range-min", minRatio)
      this.controlTarget.style.setProperty("--range-max", maxRatio)
    }

    if (this.hasMinThumbTarget) {
      this.minThumbTarget.style.left = this.thumbPosition(minRatio)
      this.minThumbTarget.setAttribute("aria-valuenow", min)
      this.minThumbTarget.setAttribute("aria-valuetext", this.gradeLabel(min))
    }

    if (this.hasMaxThumbTarget) {
      this.maxThumbTarget.style.left = this.thumbPosition(maxRatio)
      this.maxThumbTarget.setAttribute("aria-valuenow", max)
      this.maxThumbTarget.setAttribute("aria-valuetext", this.gradeLabel(max))
    }
  }

  thumbPosition(ratio) {
    return `calc(var(--grade-thumb-offset) + (100% - var(--grade-thumb-size)) * ${ratio})`
  }

  gradeLabel(grade) {
    return grade >= 10 ? "V10+" : `V${grade}`
  }
}
