import { useMutation } from "@tanstack/react-query";
import { html } from "htm/react";
import createTagMutation from "queries/tags-multi-select/create-tag-mutation";
import { useCallback, useMemo } from "react";

export default function NewTagForm({ name, onSuccess, createTagCsrfToken }) {
  const mutation = useMemo(
    () => createTagMutation(createTagCsrfToken),
    [createTagCsrfToken]
  );
  const { mutate } = useMutation(mutation);

  const onClick = useCallback(() => {
    mutate({ name, _csrf_token: createTagCsrfToken }, { onSuccess });
  }, [mutate, name, onSuccess, createTagCsrfToken]);

  return html`<div
    className="cursor-pointer select-none bg-green-300 hover:bg-green-400 dark:bg-green-600 hover:dark:bg-green-500"
    onClick=${onClick}
  >
    Create tag named <span className="font-bold">${name}</span>
  </div>`;
}
