import Label from "components/label";
import { html } from "htm/react";

export const INPUT_CLASS_NAME =
  "rounded outline-1 focus:outline-2 outline-gray-300 dark:outline-gray-600 disabled:text-gray-600 data-disabled:text-gray-600 dark:disabled:text-gray-200 dark:data-disabled:text-gray-200";

export default function Field({
  label,
  name,
  value,
  onChange,
  type,
  className,
}) {
  return html`
    <${Label} htmlFor=${name} label=${label || name} className=${className}>
      <input
        type=${type || "text"}
        name=${name}
        id=${name}
        value=${value}
        onChange=${onChange}
        className=${INPUT_CLASS_NAME}
      />
    </${Label}>
  `;
}
