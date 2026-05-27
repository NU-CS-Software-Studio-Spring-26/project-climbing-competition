import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "competitionsFilterMenuOpen"

export default class extends Controller {
  static targets = [ "button", "menu" ]

  connect() {
    this.onDocumentClick = this.onDocumentClick.bind(this)
    this.onMenuLinkClick = this.onMenuLinkClick.bind(this)
    this.beforeCache = () => this.close(false)

    this.element.addEventListener("click", this.onMenuLinkClick)
    document.addEventListener("turbo:before-cache", this.beforeCache)

    if (sessionStorage.getItem(STORAGE_KEY) === "true") {
      sessionStorage.removeItem(STORAGE_KEY)
      this.open()
    }
  }

  disconnect() {
    this.close(false)
    this.element.removeEventListener("click", this.onMenuLinkClick)
    document.removeEventListener("turbo:before-cache", this.beforeCache)
    document.removeEventListener("click", this.onDocumentClick)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      sessionStorage.removeItem(STORAGE_KEY)
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.add("filter-menu--open")
    this.buttonTarget.classList.add("show")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    document.addEventListener("click", this.onDocumentClick)
  }

  close() {
    this.menuTarget.classList.remove("filter-menu--open")
    this.buttonTarget.classList.remove("show")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    document.removeEventListener("click", this.onDocumentClick)
  }

  onMenuLinkClick(event) {
    if (this.isOpen && event.target.closest("a")) {
      sessionStorage.setItem(STORAGE_KEY, "true")
    }
  }

  onDocumentClick(event) {
    if (!this.element.contains(event.target)) {
      sessionStorage.removeItem(STORAGE_KEY)
      this.close()
    }
  }

  get isOpen() {
    return this.menuTarget.classList.contains("filter-menu--open")
  }
}
