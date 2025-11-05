import classNames from "classnames";
import { html } from "htm/react";

export const BUTTON_CLASS_NAME =
  "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600";

export default function Button({ children, className, ...buttonProps }) {
  return html`
    <button
      ...${buttonProps}
      className=${classNames(
        BUTTON_CLASS_NAME,
        "p-1",
        "text-center",
        "cursor-pointer",
        className
      )}
    >
      ${children}
    </button>
  `;
}
