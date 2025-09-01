import { html } from "htm/react";

export default function Field({ label, name, value, onChange, type }) {
  return html`
    <label for=${name} className="flex flex-col items-stretch space-y-1">
      <span>${label || name}</span>
      <input
        type=${type || "text"}
        name=${name}
        id=${name}
        value=${value}
        onChange=${onChange}
        className="rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600"
      />
      <div />
    </label>
  `;
}
