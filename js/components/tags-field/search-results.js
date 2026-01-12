import classNames from "classnames";
import SearchResult from "components/tags-field/search-result";
import { html } from "htm/react";
import _ from "lodash";
import { BASE_CLASS_NAME } from "utils";

export default function SearchResults({
  tags,
  tagIds,
  onToggleTagId,
  highlightedSearchResultId,
}) {
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
      ${_.map(
        tags,
        (tag) =>
          html`<${SearchResult}
            key=${tag.id}
            tag=${tag}
            onClick=${() => onToggleTagId(tag.id)}
            isSelected=${_.includes(tagIds, tag.id)}
            isHighlighted=${tag.id === highlightedSearchResultId}
          />`
      )}
    </div>
  </div>`;
}
