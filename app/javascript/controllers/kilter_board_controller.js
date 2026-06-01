import { Controller } from "@hotwired/stimulus"

const COLOR_MAP = {
  purple: "#7c3aed",
  green: "#22c55e",
  blue: "#3b82f6",
  yellow: "#facc15"
}

const HOLDS_URL = "/kilter-board-holds.json"
const BOARD_SVG_URL = "/kilter-board.svg"
const VIEWBOX = { width: 1600, height: 1236 }
const SVG_NS = "http://www.w3.org/2000/svg"

export default class extends Controller {
  static targets = ["board", "input", "colorButton", "modal", "count", "removeButton"]
  static values = {
    editable: { type: Boolean, default: true },
    viewer: { type: Boolean, default: false },
    assignments: { type: Object, default: {} },
    defaultColor: { type: String, default: "purple" }
  }

  connect() {
    this.currentColor = this.defaultColorValue
    this.holdElements = new Map()
    this.holds = []
    this.modalInstance = null
    this.pendingAssignments = null
    this.state = this.initialState()
    this.onHoldPointerDown = this.onHoldPointerDown.bind(this)
    this.beforeCache = this.restoreModalPlacement.bind(this)

    document.addEventListener("turbo:before-cache", this.beforeCache)
    this.reconcileModalPlacement()

    this.syncPaletteUI()
    this.syncInput()
    this.updateSelectionCount()
    this.loadHoldMap()
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCache)
    this.restoreModalPlacement()
  }

  selectColor(event) {
    if (!this.editableValue) return

    this.currentColor = event.currentTarget.dataset.color
    this.syncPaletteUI()
  }

  openModal(event) {
    event.preventDefault()

    const modalEl = this.modalElement()
    const Modal = window.bootstrap?.Modal
    if (!modalEl || !Modal) return

    Modal.getOrCreateInstance(modalEl).show()
  }

  modalElement() {
    this.reconcileModalPlacement()
    return this.element.querySelector("[data-kilter-board-target='modal']")
  }

  reconcileModalPlacement() {
    const modalInField = this.element.querySelector("[data-kilter-board-target='modal']")
    if (modalInField) return

    const ownerId = this.element.id
    if (!ownerId) return

    const orphanedModal = document.querySelector(`[data-kilter-board-owner="${ownerId}"]`)
    if (orphanedModal) {
      this.element.appendChild(orphanedModal)
    }
  }

  restoreModalPlacement() {
    const modalEl = this.element.querySelector("[data-kilter-board-target='modal']")
    if (!modalEl) return

    if (modalEl.parentElement === document.body) {
      window.bootstrap?.Modal.getInstance(modalEl)?.hide()
      this.element.appendChild(modalEl)
    }
  }

  closeModal(event) {
    if (event) event.preventDefault()

    const modalEl = this.modalElement()
    if (!modalEl) return

    window.bootstrap?.Modal.getInstance(modalEl)?.hide()
  }

  clearBoard(event) {
    if (event) event.preventDefault()
    if (!this.editableValue) return

    this.state = {}
    if (this.viewerValue) {
      this.renderHolds()
    } else {
      this.refreshAllHolds()
    }
    this.syncInput()
    this.updateSelectionCount()
  }

  removeVisual(event) {
    if (event) event.preventDefault()
    if (!this.editableValue) return

    this.state = {}
    if (this.viewerValue) {
      this.renderHolds()
    } else {
      this.refreshAllHolds()
    }
    this.syncInput()
    this.updateSelectionCount()
  }

  loadAssignments(assignments) {
    this.state = this.normalizeAssignments(assignments)

    if (!this.holds.length || !this.overlayElement) {
      this.pendingAssignments = assignments
      return
    }

    this.pendingAssignments = null
    this.pruneInvalidState()
    this.renderHolds()
    this.syncInput()
    this.updateSelectionCount()
  }

  normalizeAssignments(assignments) {
    const state = {}
    Object.entries(assignments || {}).forEach(([holdId, color]) => {
      const normalizedColor = String(color).toLowerCase()
      if (Object.prototype.hasOwnProperty.call(COLOR_MAP, normalizedColor)) {
        state[String(holdId)] = normalizedColor
      }
    })
    return state
  }

  onHoldPointerDown(event) {
    if (!this.editableValue) return

    const hold = event.target.closest?.("[data-hold-id]")
    if (!hold || !this.overlayElement?.contains(hold)) return

    event.preventDefault()
    event.stopPropagation()

    const holdId = hold.getAttribute("data-hold-id")
    if (!holdId) return

    if (this.currentColor === "none") {
      delete this.state[holdId]
    } else {
      this.state[holdId] = this.currentColor
    }

    this.paintHold(hold, this.state[holdId])
    this.syncInput()
    this.updateSelectionCount()
  }

  initialState() {
    const state = this.normalizeAssignments(this.assignmentsValue)

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

  buildBoardSvg() {
    if (!this.hasBoardTarget) return

    const svg = document.createElementNS(SVG_NS, "svg")
    svg.setAttribute("viewBox", `0 0 ${VIEWBOX.width} ${VIEWBOX.height}`)
    svg.setAttribute("class", "kilter-board-svg")
    svg.setAttribute("role", "img")
    svg.setAttribute("aria-label", "Kilter board")

    const background = document.createElementNS(SVG_NS, "image")
    background.setAttribute("href", BOARD_SVG_URL)
    background.setAttributeNS("http://www.w3.org/1999/xlink", "href", BOARD_SVG_URL)
    background.setAttribute("x", "0")
    background.setAttribute("y", "0")
    background.setAttribute("width", String(VIEWBOX.width))
    background.setAttribute("height", String(VIEWBOX.height))
    background.setAttribute("pointer-events", "none")
    svg.appendChild(background)

    const overlay = document.createElementNS(SVG_NS, "g")
    overlay.setAttribute("class", "kilter-board-overlay")
    if (this.editableValue) {
      overlay.addEventListener("pointerdown", this.onHoldPointerDown)
    }
    svg.appendChild(overlay)

    this.boardTarget.innerHTML = ""
    this.boardTarget.appendChild(svg)
    this.overlayElement = overlay
  }

  renderHolds() {
    if (!this.overlayElement) return
    this.overlayElement.innerHTML = ""
    this.holdElements.clear()

    const inModal = this.inModalEditor()

    const holdsToShow = this.viewerValue
      ? this.holds.filter((hold) => this.state[hold.id])
      : this.holds

    holdsToShow.forEach(({ id, cx, cy, r }) => {
      const radius = inModal ? Math.max(r * 1.25, 14) : Math.max(r, 10)
      const hold = document.createElementNS(SVG_NS, "circle")
      hold.setAttribute("cx", String(cx))
      hold.setAttribute("cy", String(cy))
      hold.setAttribute("r", String(radius))
      hold.setAttribute("class", "kilter-hold-target")
      hold.setAttribute("data-hold-id", id)
      hold.title = `Hold ${id}`

      if (this.editableValue) {
        hold.setAttribute("role", "button")
        hold.setAttribute("tabindex", "0")
        hold.setAttribute("aria-label", `Toggle hold ${id}`)
      } else {
        hold.setAttribute("aria-hidden", "true")
      }

      this.paintHold(hold, this.state[id])
      this.overlayElement.appendChild(hold)
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
      element.setAttribute("data-state", normalizedColor)
    } else {
      element.setAttribute("data-state", "off")
    }
  }

  updateSelectionCount() {
    const selectedCount = Object.keys(this.state).length
    const hasVisual = selectedCount > 0

    if (this.hasCountTarget) {
      this.countTarget.textContent = hasVisual
        ? `${selectedCount} hold${selectedCount === 1 ? "" : "s"} selected`
        : "No visual"
    }

    if (this.hasRemoveButtonTarget) {
      this.removeButtonTargets.forEach((button) => {
        button.classList.toggle("d-none", !hasVisual)
      })
    }
  }

  async loadHoldMap() {
    try {
      const response = await fetch(HOLDS_URL, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`Failed to load hold map (${response.status})`)

      const holds = await response.json()
      if (!Array.isArray(holds) || holds.length === 0) throw new Error("Hold map is empty")

      this.holds = holds
        .filter((hold) => hold?.id && Number.isFinite(hold.cx) && Number.isFinite(hold.cy))
        .map((hold) => ({
          id: String(hold.id),
          cx: Number(hold.cx),
          cy: Number(hold.cy),
          r: Number(hold.r) || 16
        }))

      this.buildBoardSvg()
      this.pruneInvalidState()
      this.renderHolds()
      this.syncInput()
      this.updateSelectionCount()

      if (this.pendingAssignments) {
        this.loadAssignments(this.pendingAssignments)
      }
    } catch (_error) {
      this.holds = []
      this.buildBoardSvg()
      this.renderHolds()
    }
  }

  inModalEditor() {
    const modalEl = this.element.querySelector("[data-kilter-board-target='modal']")
    return Boolean(modalEl?.contains(this.boardTarget))
  }

  pruneInvalidState() {
    const validIds = new Set(this.holds.map((hold) => hold.id))
    Object.keys(this.state).forEach((holdId) => {
      if (!validIds.has(holdId)) {
        delete this.state[holdId]
      }
    })
  }
}
