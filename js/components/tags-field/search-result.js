import classNames from "classnames";
import { html } from "htm/react";

export default function SearchResult({
  tag,
  onClick,
  isSelected,
  isHighlighted,
}) {
  return html`<div
    className=${classNames("cursor-pointer", "select-none", {
      "hover:bg-gray-100 dark:hover:bg-gray-800": !isSelected && !isHighlighted,
      "bg-green-300 hover:bg-green-400 dark:bg-green-600 hover:dark:bg-green-500":
        isSelected && !isHighlighted,
      "bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700":
        !isSelected && isHighlighted,
      "bg-green-400 hover:bg-green-500 dark:bg-green-500 hover:dark:bg-green-400":
        isSelected && isHighlighted,
    })}
    onClick=${onClick}
  >
    ${tag.name}
  </div>`;
}
