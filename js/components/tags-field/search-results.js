import { useQuery } from "@tanstack/react-query";
import classNames from "classnames";
import { html } from "htm/react";
import _ from "lodash";
import tagsQuery from "queries/tags-multi-select/tags-query";

export default function SearchResults({ q, tagIds, onChangeTagIds }) {
  const { data } = useQuery(tagsQuery(q === "" ? {} : { q }));

  return html`<div className="flex flex-col items-stretch divide-y">
    ${data !== undefined
      ? data.map(
          (tag) =>
            html`<div
              key=${tag.id}
              className=${classNames("cursor-pointer", {
                "bg-green-300 dark:bg-green-600": _.includes(tagIds, tag.id),
              })}
              onClick=${() => {
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
  </div>`;
}
