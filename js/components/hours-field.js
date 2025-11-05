import classNames from "classnames";
import Button from "components/button";
import { INPUT_CLASS_NAME, LABEL_CLASS_NAME } from "components/field";
import { html } from "htm/react";
import { useCallback } from "react";
import { GoArrowDown, GoMoveToBottom } from "react-icons/go";
import { nextDay, nextDays, secondsBetweenTimes, timeAddSeconds } from "utils";

export default function HoursField({ day, value, onChange, errors }) {
  const opens_at_field_name = day + "_opens_at";
  const open_seconds_field_name = day + "_open_seconds";
  const closes_at_field_name = day + "_closes_at";

  const opens_at = value[opens_at_field_name];
  const open_seconds = value[open_seconds_field_name];
  const closes_at =
    opens_at === "" ? "" : timeAddSeconds(opens_at, open_seconds);

  const onChangeOpensAt = useCallback(
    ({ target: { value: new_opens_at } }) => {
      onChange({
        target: {
          value: {
            ...value,
            [opens_at_field_name]: new_opens_at,
          },
        },
      });
    },
    [value]
  );

  const onChangeClosesAt = useCallback(
    ({ target: { value: new_closes_at } }) => {
      onChange({
        target: {
          value: {
            ...value,
            [open_seconds_field_name]: secondsBetweenTimes(
              opens_at,
              new_closes_at
            ),
          },
        },
      });
    },
    [value, opens_at]
  );

  const onClickDuplicateToNext = useCallback(() => {
    onChange({
      target: {
        value: {
          ...value,
          [`${nextDay(day)}_opens_at`]: opens_at,
          [`${nextDay(day)}_open_seconds`]: open_seconds,
        },
      },
    });
  }, [onChange, value, day, opens_at, open_seconds]);

  const onClickDuplicateToAll = useCallback(() => {
    let updated_value = { ...value };
    for (const next_day of nextDays(day)) {
      updated_value[`${next_day}_opens_at`] = opens_at;
      updated_value[`${next_day}_open_seconds`] = open_seconds;
    }
    onChange({
      target: {
        value: updated_value,
      },
    });
  }, [onChange, value, day, opens_at, open_seconds]);

  return html`
    <div className=${LABEL_CLASS_NAME}>
      <div className="flex space-x-2 justify-stretch">
        <label
          for=${opens_at_field_name}
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>${day} open</span>
          <input
            id=${opens_at_field_name}
            name=${opens_at_field_name}
            type="time"
            value=${opens_at}
            onChange=${onChangeOpensAt}
            className=${INPUT_CLASS_NAME}
          />
          ${
            errors[opens_at_field_name].length > 0 &&
            html`
              <span className="text-red-600 dark:text-red-500">
                ${errors[opens_at_field_name].join(", ")}
              </span>
            `
          }
        </label>
        <label
          for=${closes_at_field_name}
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>close</span>
          <input
            id=${closes_at_field_name}
            name=${closes_at_field_name}
            type="time"
            value=${closes_at}
            onChange=${onChangeClosesAt}
            className=${INPUT_CLASS_NAME}
          />
          <input
            type="hidden"
            value=${open_seconds}
            name=${open_seconds_field_name}
          />
          ${
            errors[open_seconds_field_name].length > 0 &&
            html`
              <span className="text-red-600 dark:text-red-500">
                ${errors[open_seconds_field_name].join(", ")}
              </span>
            `
          }
        </label>
        <span className=${LABEL_CLASS_NAME}>
          <span>${"\xA0"}</span>
          <${Button}
          type="button"
          disabled=${day === "sunday"}
          onClick=${onClickDuplicateToNext}
          alt="copy to next day"
          >
            <${GoArrowDown} />
          </${Button}>
        </span>
        <span className=${LABEL_CLASS_NAME}>
          <span>${"\xA0"}</span>
          <${Button}
            type="button"
            disabled=${day === "sunday"}
            onClick=${onClickDuplicateToAll}
            alt="copy to all following days"
            >
            <${GoMoveToBottom} />
          </${Button}>
        </span>
      </div>
    </div>
  `;
}
