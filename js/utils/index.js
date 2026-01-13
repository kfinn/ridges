export * from "utils/time-helpers";

export const BASE_CLASS_NAME =
  "bg-gray-50 dark:bg-gray-900 text-gray-800 dark:text-gray-100";

export function onDocumentReady(fn) {
  if (document.readyState !== "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}
