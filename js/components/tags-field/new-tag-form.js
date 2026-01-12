import classNames from "classnames";
import { html } from "htm/react";
import { BASE_CLASS_NAME } from "utils";

export default function NewTagForm({ name, onClick }) {
  return html`<div className="w-[0] h-[0] overflow-visible self-start">
    <div
      className=${classNames(
        BASE_CLASS_NAME,
        "flex",
        "flex-col",
        "items-stretch",
        "w-48",
        "relative",
        "z-[1]"
      )}
    >
      <div
        className="cursor-pointer select-none bg-green-300 hover:bg-green-400 dark:bg-green-600 hover:dark:bg-green-500"
        onClick=${onClick}
      >
        Create tag named <span className="font-bold">${name}</span>
      </div>
    </div>
  </div>`;
}
