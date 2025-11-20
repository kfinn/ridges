import classNames from "classnames";
import Button from "components/button";
import { INPUT_CLASS_NAME } from "components/field";
import { LABEL_CLASS_NAME } from "components/label";
import { html } from "htm/react";
import { useCallback } from "react";
import { GoArrowDown, GoMoveToBottom } from "react-icons/go";
import toSnakeCase from "to-snake-case";
import { nextDay, nextDays, secondsBetweenTimes, timeAddSeconds } from "utils";

export default function HoursField({ day, value, onChange, errors }) {
  const opensAtFieldName = day + "OpensAt";
  const openSecondsFieldName = day + "OpenSeconds";
  const closesAtFieldName = day + "ClosesAt";

  const opensAt = value[opensAtFieldName];
  const openSeconds = value[openSecondsFieldName];
  const closesAt = opensAt === "" ? "" : timeAddSeconds(opensAt, openSeconds);

  const onChangeOpensAt = useCallback(
    ({ target: { value: newOpensAt } }) => {
      onChange({
        target: {
          value: {
            ...value,
            [opensAtFieldName]: newOpensAt,
          },
        },
      });
    },
    [value]
  );

  const onChangeClosesAt = useCallback(
    ({ target: { value: newClosesAt } }) => {
      onChange({
        target: {
          value: {
            ...value,
            [openSecondsFieldName]: secondsBetweenTimes(opensAt, newClosesAt),
          },
        },
      });
    },
    [value, opensAt]
  );

  const onClickDuplicateToNext = useCallback(() => {
    onChange({
      target: {
        value: {
          ...value,
          [`${nextDay(day)}OpensAt`]: opensAt,
          [`${nextDay(day)}OpenSeconds`]: openSeconds,
        },
      },
    });
  }, [onChange, value, day, opensAt, openSeconds]);

  const onClickDuplicateToAll = useCallback(() => {
    let updatedValue = { ...value };
    for (const nextDay of nextDays(day)) {
      updatedValue[`${nextDay}OpensAt`] = opensAt;
      updatedValue[`${nextDay}OpenSeconds`] = openSeconds;
    }
    onChange({
      target: {
        value: updatedValue,
      },
    });
  }, [onChange, value, day, opensAt, openSeconds]);

  return html`
    <div className=${LABEL_CLASS_NAME}>
      <div className="flex space-x-2 justify-stretch">
        <label
          htmlFor=${opensAtFieldName}
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>${day} open</span>
          <input
            id=${opensAtFieldName}
            name=${toSnakeCase(opensAtFieldName)}
            type="time"
            value=${opensAt}
            onChange=${onChangeOpensAt}
            className=${INPUT_CLASS_NAME}
          />
          ${
            errors[opensAtFieldName].length > 0 &&
            html`
              <span className="text-red-600 dark:text-red-500">
                ${errors[opensAtFieldName].join(", ")}
              </span>
            `
          }
        </label>
        <label
          htmlFor=${closesAtFieldName}
          className=${classNames(LABEL_CLASS_NAME, "grow", "basis-1/2")}
        >
          <span>close</span>
          <input
            id=${closesAtFieldName}
            name=${toSnakeCase(closesAtFieldName)}
            type="time"
            value=${closesAt}
            onChange=${onChangeClosesAt}
            className=${INPUT_CLASS_NAME}
          />
          <input
            type="hidden"
            value=${openSeconds}
            name=${toSnakeCase(openSecondsFieldName)}
          />
          ${
            errors[openSecondsFieldName].length > 0 &&
            html`
              <span className="text-red-600 dark:text-red-500">
                ${errors[openSecondsFieldName].join(", ")}
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
