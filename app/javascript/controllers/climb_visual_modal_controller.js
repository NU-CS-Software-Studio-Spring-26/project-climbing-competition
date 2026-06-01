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

    if (!window.bootstrap) return
    this.modalInstance ||= window.bootstrap.Modal.getOrCreateInstance(this.modalTarget)
    this.modalInstance.show()
  }

  get kilterBoardController() {
    if (!this.hasKilterBoardTarget) return null
    return this.application.getControllerForElementAndIdentifier(
      this.kilterBoardTarget,
      "kilter-board"
    )
  }
}
