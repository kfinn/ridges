import { html } from "htm/react";

export const LABEL_CLASS_NAME = "flex flex-col items-stretch space-y-1";
export const INPUT_CLASS_NAME =
  "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600";

export default function Field({ label, name, value, onChange, type }) {
  return html`
    <label for=${name} className=${LABEL_CLASS_NAME}>
      <span>${label || name}</span>
      <input
        type=${type || "text"}
        name=${name}
        id=${name}
        value=${value}
        onChange=${onChange}
        className=${INPUT_CLASS_NAME}
      />
    </label>
  `;
}
