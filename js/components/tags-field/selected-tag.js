import { useQuery } from "@tanstack/react-query";
import { html } from "htm/react";
import tagQuery from "queries/tags-multi-select/tag-query";
import { GoX } from "react-icons/go";

export default function SelectedTag({ id, onClick }) {
  const { data } = useQuery(tagQuery(id));

  return html`<div
    className="rounded bg-green-200 dark:bg-green-700 border border-green-400 dark:border-green-500 text-gray-900 dark:text-gray-50 cursor-pointer flex items-stretch group"
    onClick=${onClick}
  >
    ${data !== undefined ? data.name : "..."}
    <div
      className="flex items-center rounded-right bg-green-400 dark:bg-green-500 group-hover:bg-green-600 group-hover:dark:bg-green-300 group-hover:text-gray-50 group-hover:dark:text-gray-900 rounded-r"
    >
      <${GoX} />
    </div>
    <!-- <input type="hidden" name="tag_ids[]" value=${id} /> -->
  </div>`;
}
