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
      "bg-purple-300 hover:bg-purple-400 dark:bg-purple-600 hover:dark:bg-purple-500":
        isSelected && !isHighlighted,
      "bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700":
        !isSelected && isHighlighted,
      "bg-purple-400 hover:bg-purple-500 dark:bg-purple-500 hover:dark:bg-purple-400":
        isSelected && isHighlighted,
    })}
    onClick=${onClick}
  >
    ${tag.name}
  </div>`;
}
