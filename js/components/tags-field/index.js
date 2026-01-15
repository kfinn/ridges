import { useMutation, useQuery } from "@tanstack/react-query";
import classNames from "classnames";
import { INPUT_CLASS_NAME } from "components/field";
import Label from "components/label";
import NewTagForm from "components/tags-field/new-tag-form";
import SearchResults from "components/tags-field/search-results";
import SelectedTag from "components/tags-field/selected-tag";
import { html } from "htm/react";
import _ from "lodash";
import createTagMutation from "queries/tags-multi-select/create-tag-mutation";
import tagsQuery from "queries/tags-multi-select/tags-query";
import { useCallback, useEffect, useMemo, useState } from "react";
import { BASE_CLASS_NAME } from "utils";

export default function TagsField({
  tagIds: initialTagIds,
  createTagCsrfToken,
}) {
  const [q, setQ] = useState("");
  const [isFocused, setIsFocused] = useState(false);

  const { isSuccess: searchQueryIsSuccess, data: searchQueryData } = useQuery(
    tagsQuery(q === "" ? {} : { q })
  );
  const { mutate: createTag } = useMutation(
    useMemo(() => createTagMutation(createTagCsrfToken), [createTagCsrfToken])
  );

  const [tagIds, setTagIds] = useState(initialTagIds ?? []);
  const [
    tagHighlightedForBackspaceDeselectId,
    setTagHighlightedForBackspaceDeselectId,
  ] = useState(null);

  const [tagHighlightedForEnterToggleId, setTagHIghlightedForEnterToggleId] =
    useState(null);
  useEffect(() => {
    if (
      !_.find(
        searchQueryData,
        (tag) => tag.id === tagHighlightedForEnterToggleId
      )
    ) {
      setTagHIghlightedForEnterToggleId(_.get(_.first(searchQueryData), "id"));
    }
  }, [searchQueryData, tagHighlightedForEnterToggleId]);

  const onToggleTagId = useCallback((tagId) => {
    setTagIds((oldTagIds) => {
      if (_.includes(oldTagIds, tagId)) {
        return _.without(oldTagIds, tagId);
      } else {
        return _.union(oldTagIds, [tagId]);
      }
    });
  }, []);

  const onSelectTagId = useCallback((tagId) => {
    setTagIds((oldTagIds) => _.union(oldTagIds, [tagId]));
  }, []);

  const onDeselectTagId = useCallback((tagId) => {
    setTagIds((oldTagIds) => _.without(oldTagIds, tagId));
  }, []);

  const onCreateNewTag = useCallback(() => {
    createTag(
      { name: q },
      {
        onSuccess: ({ id }) => {
          setQ("");
          onSelectTagId(id);
        },
      }
    );
  }, [q]);

  const onEnterKeyDown = useCallback(
    (event) => {
      if (!isFocused && q === "") return;

      event.preventDefault();
    },
    [isFocused, q]
  );

  const onEnterKeyUp = useCallback(() => {
    if (!isFocused && q === "") return;

    if (searchQueryIsSuccess) {
      if (_.isEmpty(searchQueryData)) {
        onCreateNewTag();
      } else {
        if (tagHighlightedForEnterToggleId) {
          onToggleTagId(tagHighlightedForEnterToggleId);
        }
        setQ("");
      }
    }
  }, [
    q,
    searchQueryIsSuccess,
    searchQueryData,
    createTag,
    onCreateNewTag,
    tagHighlightedForEnterToggleId,
    onSelectTagId,
  ]);

  const [qAtCurrentBackspaceKeyDown, setQAtCurrentBackspaceKeyDown] =
    useState(null);

  const onBackspaceKeyDown = useCallback(() => {
    setQAtCurrentBackspaceKeyDown(q);
  }, [q]);

  const onBackspaceKeyUp = useCallback(() => {
    if (qAtCurrentBackspaceKeyDown !== "") return;

    setQAtCurrentBackspaceKeyDown(null);

    if (tagHighlightedForBackspaceDeselectId) {
      onDeselectTagId(tagHighlightedForBackspaceDeselectId);
      setTagHighlightedForBackspaceDeselectId(null);
      return;
    } else {
      setTagHighlightedForBackspaceDeselectId(_.last(tagIds));
    }
  }, [
    qAtCurrentBackspaceKeyDown,
    tagHighlightedForBackspaceDeselectId,
    onDeselectTagId,
    tagIds,
  ]);

  const onArrowDownKeyDown = useCallback((event) => {
    event.preventDefault();
  }, []);

  const onArrowDownKeyUp = useCallback(() => {
    setTagHIghlightedForEnterToggleId((oldTagHighlightedForEnterToggleId) => {
      const index = _.findIndex(
        searchQueryData,
        ({ id }) => id === oldTagHighlightedForEnterToggleId
      );

      const nextTag =
        index === -1
          ? _.first(searchQueryData)
          : searchQueryData[(index + 1) % searchQueryData.length];
      return _.get(nextTag, "id");
    });
  }, [searchQueryData]);

  const onArrowUpKeyDown = useCallback((event) => {
    event.preventDefault();
  }, []);

  const onArrowUpKeyUp = useCallback(() => {
    setTagHIghlightedForEnterToggleId((oldTagHighlightedForEnterToggleId) => {
      const index = _.findIndex(
        searchQueryData,
        ({ id }) => id === oldTagHighlightedForEnterToggleId
      );

      const previousTag =
        index <= 0 ? _.last(searchQueryData) : searchQueryData[index - 1];
      return _.get(previousTag, "id");
    });
  }, [searchQueryData]);

  const onKeyDown = useCallback(
    (event) => {
      if (event.key === "Enter") {
        onEnterKeyDown(event);
        return;
      }
      if (event.key === "Backspace") {
        onBackspaceKeyDown(event);
        return;
      }
      if (event.key === "ArrowDown") {
        onArrowDownKeyDown(event);
        return;
      }
      if (event.key === "ArrowUp") {
        onArrowUpKeyDown(event);
        return;
      }
    },
    [onEnterKeyDown, onArrowDownKeyDown, onArrowUpKeyDown]
  );

  const onKeyUp = useCallback(
    (event) => {
      if (event.key === "Enter") {
        onEnterKeyUp(event);
        return;
      }
      if (event.key === "Backspace") {
        onBackspaceKeyUp(event);
        return;
      }
      if (event.key === "ArrowDown") {
        onArrowDownKeyUp(event);
        return;
      }
      if (event.key === "ArrowUp") {
        onArrowUpKeyUp(event);
        return;
      }
    },
    [onEnterKeyUp, onBackspaceKeyUp, onArrowDownKeyUp, onArrowUpKeyUp]
  );

  const onBlur = useCallback(() => {
    setTagHighlightedForBackspaceDeselectId(null);
    setIsFocused(false);
  }, []);

  const onFocus = useCallback(() => {
    setIsFocused(true);
  }, []);

  const onChangeQ = useCallback(({ target: { value } }) => setQ(value), []);

  return html`<${Label} htmlFor="tag_ids" label="tags">
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
            isHighlighted=${tagHighlightedForBackspaceDeselectId === tagId}
          />`
      )}
      <div className="justify-self-stretch flex flex-col grow shrink items-stretch justify-stretch min-w-1">
        <input
          id="tag_ids"
          value=${q}
          onChange=${onChangeQ}
          onKeyUp=${onKeyUp}
          onKeyDown=${onKeyDown}
          onFocus=${onFocus}
          onBlur=${onBlur}
          className="focus:outline-0 min-w-1"
        />
        ${
          (isFocused || q !== "") &&
          (searchQueryIsSuccess
            ? !_.isEmpty(searchQueryData)
              ? html`<${SearchResults}
                  tags=${searchQueryData}
                  tagIds=${tagIds}
                  onToggleTagId=${onToggleTagId}
                  highlightedSearchResultId=${tagHighlightedForEnterToggleId}
                />`
              : html`<${NewTagForm} name=${q} onClick=${onCreateNewTag} />`
            : html`<div className=${BASE_CLASS_NAME}>Loading...</div>`)
        }
      </div>
      <input type="hidden" name="tag_ids" value=${_.join(tagIds, ",")} />
    </div>
  </${Label}>`;
}
