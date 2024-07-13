import { Controller } from "@hotwired/stimulus";

/**
 * This controller is responsible for switching between system, light and dark themes.
 */
export default class extends Controller {
    static targets = ["toggleButton"];

    connect() {
        this.loadThemePreference();
    }

    toggle() {
        const mode = document.documentElement.classList.toggle("dark");
        this.saveThemePreference(isDarkMode);
    }

    loadThemePreference() {
        const isDarkMode = localStorage.getItem("themePreference") === "dark";
        if (isDarkMode) {
            document.documentElement.classList.add("dark");
        }
    }

    saveThemePreference(mode) {
        localStorage.setItem("themePreference", mode);
    }
}