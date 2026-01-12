import classNames from "classnames";
import { html } from "htm/react";
export const LABEL_CLASS_NAME = "flex flex-col items-stretch space-y-1";

export default function Label({ htmlFor, label, children, className }) {
  return html`<label
    htmlFor=${htmlFor}
    className=${classNames(LABEL_CLASS_NAME, className)}
  >
    <span>${label || htmlFor}</span>
    ${children}
  </label>`;
}
