import { Controller } from "@hotwired/stimulus"

const COLOR_MAP = {
  purple: "#7c3aed",
  green: "#22c55e",
  blue: "#3b82f6",
  yellow: "#facc15"
}

const IMAGE_THRESHOLD_OFFSET = 8
const MIN_COMPONENT_AREA = 10
const MAX_COMPONENT_AREA = 50000
const MIN_COMPONENT_DIMENSION = 3
const MIN_RENDERED_HOLDS = 250

export default class extends Controller {
  static targets = ["overlay", "input", "colorButton", "image", "modal", "count"]
  static values = {
    editable: { type: Boolean, default: true },
    assignments: { type: Object, default: {} },
    defaultColor: { type: String, default: "purple" }
  }

  connect() {
    this.currentColor = this.defaultColorValue
    this.holdElements = new Map()
    this.holds = []
    this.modalInstance = null
    this.state = this.initialState()

    this.syncPaletteUI()
    this.syncInput()
    this.updateSelectionCount()
    this.prepareHoldMap()
  }

  selectColor(event) {
    if (!this.editableValue) return

    this.currentColor = event.currentTarget.dataset.color
    this.syncPaletteUI()
  }

  openModal(event) {
    event.preventDefault()
    if (!this.hasModalTarget || !window.bootstrap) return

    this.modalInstance ||= new window.bootstrap.Modal(this.modalTarget)
    this.modalInstance.show()
  }

  closeModal(event) {
    if (event) event.preventDefault()
    this.modalInstance?.hide()
  }

  clearBoard(event) {
    event.preventDefault()
    if (!this.editableValue) return

    this.state = {}
    this.refreshAllHolds()
    this.syncInput()
    this.updateSelectionCount()
  }

  handleHoldClick(event) {
    if (!this.editableValue) return

    const holdId = event.currentTarget.dataset.holdId
    if (!holdId) return

    if (this.currentColor === "none") {
      delete this.state[holdId]
    } else {
      this.state[holdId] = this.currentColor
    }

    this.paintHold(event.currentTarget, this.state[holdId])
    this.syncInput()
    this.updateSelectionCount()
  }

  initialState() {
    const state = {}
    const fromValue = this.assignmentsValue || {}
    Object.entries(fromValue).forEach(([holdId, color]) => {
      const normalizedColor = String(color).toLowerCase()
      if (Object.prototype.hasOwnProperty.call(COLOR_MAP, normalizedColor)) {
        state[String(holdId)] = normalizedColor
      }
    })

    if (!this.hasInputTarget) return state

    try {
      const parsed = JSON.parse(this.inputTarget.value || "{}")
      Object.entries(parsed).forEach(([holdId, color]) => {
        const normalizedColor = String(color).toLowerCase()
        if (Object.prototype.hasOwnProperty.call(COLOR_MAP, normalizedColor)) {
          state[String(holdId)] = normalizedColor
        }
      })
    } catch (_error) {
      this.inputTarget.value = "{}"
    }

    return state
  }

  syncInput() {
    if (!this.hasInputTarget) return
    this.inputTarget.value = JSON.stringify(this.state)
  }

  syncPaletteUI() {
    if (!this.hasColorButtonTarget) return

    this.colorButtonTargets.forEach((button) => {
      const isActive = button.dataset.color === this.currentColor
      button.classList.toggle("is-active", isActive)
      button.setAttribute("aria-pressed", isActive ? "true" : "false")
    })
  }

  renderHolds() {
    if (!this.hasOverlayTarget) return
    this.overlayTarget.innerHTML = ""
    this.holdElements.clear()

    this.holds.forEach(({ id, x, y, radius }) => {
      const hold = document.createElement("button")
      hold.type = "button"
      hold.className = "kilter-hold-target"
      hold.dataset.holdId = id
      hold.style.left = `${x}%`
      hold.style.top = `${y}%`
      hold.style.setProperty("--ring-size", `${Math.max(10, radius * 2)}px`)
      hold.style.setProperty("--hit-size", `${Math.max(18, radius * 2 + 12)}px`)
      hold.title = `Hold ${id}`
      hold.disabled = !this.editableValue

      if (this.editableValue) {
        hold.setAttribute("aria-label", `Toggle hold ${id}`)
        hold.addEventListener("click", this.handleHoldClick.bind(this))
      } else {
        hold.setAttribute("aria-hidden", "true")
      }

      this.paintHold(hold, this.state[id])
      this.overlayTarget.appendChild(hold)
      this.holdElements.set(id, hold)
    })
  }

  refreshAllHolds() {
    this.holdElements.forEach((element, holdId) => {
      this.paintHold(element, this.state[holdId])
    })
  }

  paintHold(element, color) {
    const normalizedColor = color && String(color).toLowerCase()
    if (normalizedColor && COLOR_MAP[normalizedColor]) {
      element.dataset.state = normalizedColor
      element.style.setProperty("--hold-color", COLOR_MAP[normalizedColor])
    } else {
      element.dataset.state = "off"
      element.style.removeProperty("--hold-color")
    }
  }

  updateSelectionCount() {
    if (!this.hasCountTarget) return
    const selectedCount = Object.keys(this.state).length
    this.countTarget.textContent = `${selectedCount} hold${selectedCount === 1 ? "" : "s"} selected`
  }

  prepareHoldMap() {
    if (!this.hasImageTarget) return

    if (this.imageTarget.complete && this.imageTarget.naturalWidth > 0) {
      this.detectHoldsFromImage()
      return
    }

    this.imageTarget.addEventListener("load", () => this.detectHoldsFromImage(), { once: true })
  }

  detectHoldsFromImage() {
    if (!this.hasImageTarget) return

    const width = this.imageTarget.naturalWidth
    const height = this.imageTarget.naturalHeight
    if (!width || !height) return

    const canvas = document.createElement("canvas")
    canvas.width = width
    canvas.height = height
    const context = canvas.getContext("2d", { willReadFrequently: true })
    if (!context) return

    context.drawImage(this.imageTarget, 0, 0, width, height)

    let imageData
    try {
      imageData = context.getImageData(0, 0, width, height)
    } catch (_error) {
      this.holds = this.buildFallbackHoldPositions()
      this.renderHolds()
      this.syncInput()
      this.updateSelectionCount()
      return
    }

    const pixels = imageData.data
    const visited = new Uint8Array(width * height)

    const bgLuminance = this.sampleBackgroundLuminance(pixels, width, height)
    const dynamicThreshold = Math.max(60, bgLuminance - IMAGE_THRESHOLD_OFFSET)

    const components = []
    for (let y = 0; y < height; y += 1) {
      for (let x = 0; x < width; x += 1) {
        const index = y * width + x
        if (visited[index]) continue
        if (!this.pixelLooksLikeHold(pixels, index * 4, dynamicThreshold)) continue

        const component = this.collectComponent(x, y, width, height, pixels, visited, dynamicThreshold)
        if (!component) continue
        if (component.area < MIN_COMPONENT_AREA || component.area > MAX_COMPONENT_AREA) continue
        if (component.width < MIN_COMPONENT_DIMENSION || component.height < MIN_COMPONENT_DIMENSION) continue

        components.push(component)
      }
    }

    components.sort((a, b) => {
      if (Math.abs(a.cy - b.cy) > 5) return a.cy - b.cy
      return a.cx - b.cx
    })

    let mappedHolds = components.map((component, idx) => {
      const radius = Math.max(component.width, component.height) * 0.55 + 2
      return {
        id: `r${idx}c0`,
        x: (component.cx / width) * 100,
        y: (component.cy / height) * 100,
        radius
      }
    })

    if (mappedHolds.length < MIN_RENDERED_HOLDS) {
      mappedHolds = this.buildFallbackHoldPositions()
    }

    this.holds = mappedHolds

    const validIds = new Set(this.holds.map((hold) => hold.id))
    Object.keys(this.state).forEach((holdId) => {
      if (!validIds.has(holdId)) {
        delete this.state[holdId]
      }
    })

    this.renderHolds()
    this.syncInput()
    this.updateSelectionCount()
  }

  pixelLooksLikeHold(pixels, offset, threshold) {
    const alpha = pixels[offset + 3]
    if (alpha < 15) return false

    const r = pixels[offset]
    const g = pixels[offset + 1]
    const b = pixels[offset + 2]
    const luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
    return luminance <= threshold
  }

  sampleBackgroundLuminance(pixels, width, height) {
    const samples = [
      [Math.floor(width * 0.01), Math.floor(height * 0.01)],
      [Math.floor(width * 0.99), Math.floor(height * 0.01)],
      [Math.floor(width * 0.01), Math.floor(height * 0.99)],
      [Math.floor(width * 0.99), Math.floor(height * 0.99)]
    ]

    let total = 0
    let count = 0
    samples.forEach(([x, y]) => {
      const safeX = Math.min(Math.max(x, 0), width - 1)
      const safeY = Math.min(Math.max(y, 0), height - 1)
      const offset = (safeY * width + safeX) * 4
      const r = pixels[offset]
      const g = pixels[offset + 1]
      const b = pixels[offset + 2]
      total += 0.2126 * r + 0.7152 * g + 0.0722 * b
      count += 1
    })

    return count > 0 ? total / count : 245
  }

  collectComponent(startX, startY, width, height, pixels, visited, threshold) {
    const queue = [[startX, startY]]
    let pointer = 0

    let minX = startX
    let maxX = startX
    let minY = startY
    let maxY = startY
    let area = 0
    let sumX = 0
    let sumY = 0

    while (pointer < queue.length) {
      const [x, y] = queue[pointer]
      pointer += 1

      if (x < 0 || y < 0 || x >= width || y >= height) continue
      const idx = y * width + x
      if (visited[idx]) continue
      visited[idx] = 1

      if (!this.pixelLooksLikeHold(pixels, idx * 4, threshold)) continue

      area += 1
      sumX += x
      sumY += y
      if (x < minX) minX = x
      if (x > maxX) maxX = x
      if (y < minY) minY = y
      if (y > maxY) maxY = y

      queue.push([x + 1, y])
      queue.push([x - 1, y])
      queue.push([x, y + 1])
      queue.push([x, y - 1])
    }

    if (area === 0) return null

    return {
      area,
      width: maxX - minX + 1,
      height: maxY - minY + 1,
      cx: sumX / area,
      cy: sumY / area
    }
  }

  buildFallbackHoldPositions() {
    const rows = 22
    const positions = []
    for (let row = 0; row < rows; row += 1) {
      const cols = row % 2 === 0 ? 24 : 23
      for (let col = 0; col < cols; col += 1) {
        const x = ((col + 1) / (cols + 1)) * 90 + 5
        const y = ((row + 1) / (rows + 1)) * 90 + 5
        positions.push({ id: `r${positions.length}c0`, x, y, radius: 9 })
      }
    }
    return positions
  }
}