import classNames from "classnames";
import { INPUT_CLASS_NAME } from "components/field";
import Label from "components/label";
import SearchInput from "components/tags-field/search-input";
import SelectedTag from "components/tags-field/selected-tag";
import { html } from "htm/react";
import _ from "lodash";
import { useState } from "react";

export default function TagsField({ tagIds: initialTagIds }) {
  const [tagIds, setTagIds] = useState(initialTagIds ?? []);

  return html`<${Label} htmlFor="tag_ids">
    <div className=${classNames(
      INPUT_CLASS_NAME,
      "flex",
      "flex-wrap",
      "items-center",
      "has-focus:outline-2",
      "space-x-2",
      "space-y-2"
    )}>
      ${tagIds.map(
        (tagId) =>
          html`<${SelectedTag}
            key=${tagId}
            id=${tagId}
            onClick=${() => {
              setTagIds((previousTagIds) => _.without(previousTagIds, tagId));
            }}
          />`
      )}
      <${SearchInput} tagIds=${tagIds} onChangeTagIds=${setTagIds} />
      <input type="hidden" name="tag_ids" value=${_.join(tagIds, ",")} />
    </div>
  </${Label}>`;
}
