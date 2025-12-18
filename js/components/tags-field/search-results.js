import { useQuery } from "@tanstack/react-query";
import classNames from "classnames";
import { html } from "htm/react";
import _ from "lodash";
import tagsQuery from "queries/tags-multi-select/tags-query";
import { BASE_CLASS_NAME } from "utils";

export default function SearchResults({ q, tagIds, onChangeTagIds }) {
  const { data } = useQuery(tagsQuery(q === "" ? {} : { q }));

  return html`<div className="w-[0] h-[0] overflow-visible self-start">
    <div
      className=${classNames(
        BASE_CLASS_NAME,
        "flex",
        "flex-col",
        "items-stretch",
        "divide-y",
        "w-48",
        "relative",
        "z-[1]"
      )}
    >
      ${data !== undefined
        ? data.map(
            (tag) =>
              html`<div
                key=${tag.id}
                className=${classNames(
                  "cursor-pointer",
                  "select-none",
                  "hover:bg-gray-100",
                  "dark:hover:bg-gray-800",
                  {
                    "bg-green-300 hover:bg-green-400 dark:bg-green-600 hover:dark:bg-green-500":
                      _.includes(tagIds, tag.id),
                  }
                )}
                onClick=${(e) => {
                  if (_.includes(tagIds, tag.id)) {
                    onChangeTagIds((previousTagIds) =>
                      _.without(previousTagIds, tag.id)
                    );
                  } else {
                    onChangeTagIds((previousTagIds) =>
                      _.union(previousTagIds, [tag.id])
                    );
                  }
                }}
              >
                ${tag.name}
              </div>`
          )
        : "..."}
    </div>
  </div>`;
}
