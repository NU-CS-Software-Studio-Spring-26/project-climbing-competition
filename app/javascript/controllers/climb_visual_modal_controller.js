import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "title", "kilterBoard"]

  open(event) {
    event.preventDefault()

    const board = this.kilterBoardController
    if (!board) return

    const assignments = event.params.climbAssignments || {}
    const climbName = event.params.climbName || "Climb Visual"

    if (this.hasTitleTarget) {
      this.titleTarget.textContent = climbName
    }

    board.loadAssignments(assignments)

    const modalEl = this.hasModalTarget ? this.modalTarget : null
    const Modal = window.bootstrap?.Modal
    if (!modalEl || !Modal) return

    Modal.getOrCreateInstance(modalEl).show()
  }

  get kilterBoardController() {
    if (!this.hasKilterBoardTarget) return null
    return this.application.getControllerForElementAndIdentifier(
      this.kilterBoardTarget,
      "kilter-board"
    )
  }
}
