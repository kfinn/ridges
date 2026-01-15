import classNames from "classnames";
import { html } from "htm/react";
import { useCallback } from "react";

export default function SearchResult({
  tag,
  onClick,
  isSelected,
  isHighlighted,
}) {
  const onMouseDown = useCallback((event) => {
    event.preventDefault();
  }, []);

  const onClickWithLogging = useCallback(
    (event) => {
      onClick(event);
    },
    [onClick]
  );

  return html`<div
    className=${classNames("cursor-pointer", "select-none", "px-2", "py-1", {
      "hover:bg-gray-100 dark:hover:bg-gray-800": !isSelected && !isHighlighted,
      "bg-purple-300 hover:bg-purple-400 dark:bg-purple-600 hover:dark:bg-purple-500":
        isSelected && !isHighlighted,
      "bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600":
        !isSelected && isHighlighted,
      "bg-purple-400 hover:bg-purple-500 dark:bg-purple-500 hover:dark:bg-purple-400":
        isSelected && isHighlighted,
    })}
    onClick=${onClickWithLogging}
    onMouseDown=${onMouseDown}
  >
    ${tag.name}
  </div>`;
}
