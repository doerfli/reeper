class Utils {
  static getCsrfToken() {
    return document.head.querySelector("meta[name=csrf-token]").content;
  }
}

export { Utils }
