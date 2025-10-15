import { INPUT_CLASS_NAME, LABEL_CLASS_NAME } from "components/field";
import { html } from "htm/react";
import { useCallback, useMemo } from "react";

function timeToSecondsAfterMidnight(time) {
  const [time_hours, time_minutes, time_seconds] = time.split(":");
  return (
    (time_seconds || 0) + (time_minutes || 0) * 60 + (time_hours || 0) * 60 * 60
  );
}

function timeAddSeconds(time, seconds) {
  if (time.length === 0) {
    return "";
  }

  const time_seconds_after_midnight = timeToSecondsAfterMidnight(time);
  const result_seconds_after_midnight =
    (time_seconds_after_midnight + seconds) % (60 * 60 * 24);

  const result_seconds = result_seconds_after_midnight % 60;
  const total_result_minutes = Math.floor(result_seconds_after_midnight / 60);
  const result_minutes = total_result_minutes % 60;
  const result_hours = Math.floor(total_result_minutes / 60);

  return `${result_hours.toString().padStart(2, "0")}:${result_minutes
    .toString()
    .padStart(2, "0")}:${result_seconds.toString().padStart(2, "0")}`;
}

function secondsBetweenTimes(start, end) {
  if (start.length === 0 || end.length === 0) {
    return 0;
  }

  const start_time_seconds_after_midnight = timeToSecondsAfterMidnight(start);
  const end_time_seconds_after_midnight = timeToSecondsAfterMidnight(end);

  let seconds_between_time =
    end_time_seconds_after_midnight - start_time_seconds_after_midnight;
  while (seconds_between_time < 0) {
    seconds_between_time += 60 * 60 * 24;
  }
  return seconds_between_time;
}

export default function HoursField({ day, value, onChange, errors }) {
  const opens_at_field_name = useMemo(() => day + "_opens_at", [day]);
  const open_seconds_field_name = useMemo(() => day + "_open_seconds", [day]);
  const closes_at_field_name = useMemo(() => day + "_closes_at", [day]);

  const opens_at = value[opens_at_field_name];
  const open_seconds = value[open_seconds_field_name];
  const closes_at = timeAddSeconds(opens_at, open_seconds);

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

  return html`
    <div className=${LABEL_CLASS_NAME}>
      <div className="flex space-x-2 justify-stretch">
        <label
          for=${opens_at_field_name}
          className=${LABEL_CLASS_NAME + " grow basis-1/2"}
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
          className=${LABEL_CLASS_NAME + " grow basis-1/2"}
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
      </div>
    </label>
  `;
}
