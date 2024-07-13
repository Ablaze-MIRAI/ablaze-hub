import { Controller } from "@hotwired/stimulus";

/**
 * This controller is responsible for switching between system, light and dark themes.
 */
export default class extends Controller {
    initialize() {
        if (localStorage.theme === 'dark') {
            document.documentElement.classList.add('dark')
        } else {
            document.documentElement.classList.remove('dark')
        }
    }

    toggle() {
        if (localStorage.theme === 'dark') {
            localStorage.theme = 'light'
        } else {
            localStorage.theme = 'dark'
        }
        this.initialize()
    }
}