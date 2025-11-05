import classNames from "classnames";
import { INPUT_CLASS_NAME, LABEL_CLASS_NAME } from "components/field";
import { html } from "htm/react";
import { Fragment, useCallback } from "react";
import { DAYS, secondsBetweenTimes, timeAddSeconds } from "utils";

export default function AllHoursField({ day, value, onChange, errors }) {
  const opensAt = value.mondayOpensAt;
  const openSeconds = value.mondayOpenSeconds;
  const closesAt = opensAt === "" ? "" : timeAddSeconds(opensAt, openSeconds);

  const onChangeOpensAt = useCallback(
    ({ target: { value: newOpensAt } }) => {
      onChange({
        target: {
          value: {
            ...value,
            ...DAYS.reduce(
              (updatedValue, day) => ({
                ...updatedValue,
                [`${day}OpensAt`]: newOpensAt,
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
    ({ target: { value: newClosesAt } }) => {
      const newOpenSeconds = secondsBetweenTimes(opensAt, newClosesAt);
      onChange({
        target: {
          value: {
            ...value,
            ...DAYS.reduce(
              (updatedValue, day) => ({
                ...updatedValue,
                [`${day}OpenSeconds`]: newOpenSeconds,
              }),
              {}
            ),
          },
        },
      });
    },
    [value, opensAt]
  );

  return html`
    <div className=${LABEL_CLASS_NAME}>
      <div className="flex space-x-2 justify-stretch">
        <label
          for="opensAt"
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>open</span>
          <input
            id="opensAt"
            name="opens_at"
            type="time"
            value=${opensAt}
            onChange=${onChangeOpensAt}
            className=${INPUT_CLASS_NAME}
          />
          ${errors.mondayOpensAt.length > 0 &&
          html`
            <span className="text-red-600 dark:text-red-500">
              ${errors.mondayOpensAt.join(", ")}
            </span>
          `}
        </label>
        <label
          for="closesAt"
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>close</span>
          <input
            id="closesAt"
            name="closes_at"
            type="time"
            value=${closesAt}
            onChange=${onChangeClosesAt}
            className=${INPUT_CLASS_NAME}
          />
          ${errors.mondayOpenSeconds.length > 0 &&
          html`
            <span className="text-red-600 dark:text-red-500">
              ${errors.mondayOpenSeconds.join(", ")}
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
              value=${opensAt}
            />
            <input
              type="hidden"
              name=${`${day}_open_seconds`}
              value=${openSeconds}
            />
          </${Fragment}>`
      )}
    </div>
  `;
}
