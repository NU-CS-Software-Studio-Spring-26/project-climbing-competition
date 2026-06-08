import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "tab", "panel" ]

  connect() {
    const initial =
      this.tabTargets.find((tab) => tab.classList.contains("is-active"))?.dataset.profileTabsTabParam ||
      this.tabTargets[0]?.dataset.profileTabsTabParam

    if (initial) this.activate(initial)
  }

  show(event) {
    event.preventDefault()
    this.activate(event.params.tab)
  }

  activate(tabName) {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.profileTabsTabParam === tabName
      tab.classList.toggle("is-active", isActive)
      tab.setAttribute("aria-selected", isActive ? "true" : "false")
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.profileTabsPanelParam !== tabName
    })
  }
}
