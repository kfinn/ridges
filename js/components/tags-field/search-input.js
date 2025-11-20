import SearchResults from "components/tags-field/search-results";
import { html } from "htm/react";
import { Fragment, useState } from "react";

export default function SearchInput({ tagIds, onChangeTagIds }) {
  const [q, setQ] = useState("");

  return html`<${Fragment}>
    <input
        id="tag_ids"
        value=${q}
        onChange=${({ target: { value } }) => setQ(value)}
        className="focus:outline-0"
    />
    ${html`<${SearchResults}
      q=${q}
      tagIds=${tagIds}
      onChangeTagIds=${onChangeTagIds}
    />`}
  </${Fragment}>`;
}
