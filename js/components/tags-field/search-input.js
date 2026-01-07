import SearchResults from "components/tags-field/search-results";
import { html } from "htm/react";
import { useState } from "react";

export default function SearchInput({ tagIds, onChangeTagIds, createTagCsrfToken }) {
  const [q, setQ] = useState("");

  return html`<div>
    <input
      id="tag_ids"
      value=${q}
      onChange=${({ target: { value } }) => setQ(value)}
      className="focus:outline-0"
    />
    ${q !== "" &&
    html`<${SearchResults}
      q=${q}
      tagIds=${tagIds}
      onChangeTagIds=${onChangeTagIds}
      createTagCsrfToken=${createTagCsrfToken}
    />`}
  </div>`;
}
