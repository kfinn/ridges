import classNames from "classnames";
import { INPUT_CLASS_NAME, LABEL_CLASS_NAME } from "components/field";
import { html } from "htm/react";
import { Fragment, useCallback } from "react";
import { DAYS, secondsBetweenTimes, timeAddSeconds } from "utils";

export default function AllHoursField({ day, value, onChange, errors }) {
  const opens_at = value.monday_opens_at;
  const open_seconds = value.monday_open_seconds;
  const closes_at =
    opens_at === "" ? "" : timeAddSeconds(opens_at, open_seconds);

  const onChangeOpensAt = useCallback(
    ({ target: { value: new_opens_at } }) => {
      onChange({
        target: {
          value: {
            ...value,
            ...DAYS.reduce(
              (updated_value, day) => ({
                ...updated_value,
                [`${day}_opens_at`]: new_opens_at,
              }),
              {}
            ),
          },
        },
      });
    },
    [value]
  );

  const onChangeClosesAt = useCallback(
    ({ target: { value: new_closes_at } }) => {
      const new_open_seconds = secondsBetweenTimes(opens_at, new_closes_at);
      onChange({
        target: {
          value: {
            ...value,
            ...DAYS.reduce(
              (updated_value, day) => ({
                ...updated_value,
                [`${day}_open_seconds`]: new_open_seconds,
              }),
              {}
            ),
          },
        },
      });
    },
    [value, opens_at]
  );

  return html`
    <div className=${LABEL_CLASS_NAME}>
      <div className="flex space-x-2 justify-stretch">
        <label
          for="opens_at"
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>open</span>
          <input
            id="opens_at"
            name="opens_at"
            type="time"
            value=${opens_at}
            onChange=${onChangeOpensAt}
            className=${INPUT_CLASS_NAME}
          />
          ${errors.monday_opens_at.length > 0 &&
          html`
            <span className="text-red-600 dark:text-red-500">
              ${errors.monday_opens_at.join(", ")}
            </span>
          `}
        </label>
        <label
          for="closes_at"
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>close</span>
          <input
            id="closes_at"
            name="closes_at"
            type="time"
            value=${closes_at}
            onChange=${onChangeClosesAt}
            className=${INPUT_CLASS_NAME}
          />
          ${errors.monday_open_seconds.length > 0 &&
          html`
            <span className="text-red-600 dark:text-red-500">
              ${errors.monday_open_seconds.join(", ")}
            </span>
          `}
        </label>
      </div>
      ${DAYS.map(
        (day) =>
          html`<${Fragment}>
            <input
              type="hidden"
              name=${`${day}_opens_at`}
              value=${opens_at}
            />
            <input
              type="hidden"
              name=${`${day}_open_seconds`}
              value=${open_seconds}
            />
          </${Fragment}>`
      )}
    </div>
  `;
}
