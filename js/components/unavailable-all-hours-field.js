import classNames from "classnames";
import { INPUT_CLASS_NAME } from "components/field";
import { LABEL_CLASS_NAME } from "components/label";
import { html } from "htm/react";
import { Fragment } from "react";
import { DAYS } from "utils";

export default function UnavailableAllHoursField({ value, onClick }) {
  return html`
    <div
      className=${classNames(LABEL_CLASS_NAME, "cursor-pointer")}
      onClick=${onClick}
    >
      <div className="flex space-x-2 justify-stretch">
        <div className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}>
          <span>open</span>
          <div
            className=${classNames(INPUT_CLASS_NAME, "italic")}
            data-disabled
          >
            Various; expand to see hours
          </div>
        </div>
        <div className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}>
          <span>close</span>
          <div
            className=${classNames(INPUT_CLASS_NAME, "italic")}
            data-disabled
          >
            —
          </div>
        </div>
      </div>
      ${DAYS.map(
        (day) =>
          html`<${Fragment} key=${day}>
            <input
              type="hidden"
              name=${`${day}_opens_at`}
              value=${value[`${day}OpensAt`]}
            />
            <input
              type="hidden"
              name=${`${day}_open_seconds`}
              value=${value[`${day}OpenSeconds`]}
            />
          </${Fragment}>`
      )}
    </div>
  `;
}
