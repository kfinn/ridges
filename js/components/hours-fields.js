import classNames from "classnames";
import AllHoursField from "components/all-hours-field";
import HoursField from "components/hours-field";
import { html } from "htm/react";
import { Fragment, useCallback, useEffect, useMemo, useState } from "react";
import { GoChevronRight } from "react-icons/go";
import { DAYS, nextDay } from "utils";

export default function HoursFields(props) {
  const [value, setValue] = useState({
    monday_opens_at: props.monday_opens_at,
    monday_open_seconds: props.monday_open_seconds,
    tuesday_opens_at: props.tuesday_opens_at,
    tuesday_open_seconds: props.tuesday_open_seconds,
    wednesday_opens_at: props.wednesday_opens_at,
    wednesday_open_seconds: props.wednesday_open_seconds,
    thursday_opens_at: props.thursday_opens_at,
    thursday_open_seconds: props.thursday_open_seconds,
    friday_opens_at: props.friday_opens_at,
    friday_open_seconds: props.friday_open_seconds,
    saturday_opens_at: props.saturday_opens_at,
    saturday_open_seconds: props.saturday_open_seconds,
    sunday_opens_at: props.sunday_opens_at,
    sunday_open_seconds: props.sunday_open_seconds,
  });

  const onChange = useCallback(
    ({ target: { value: new_value } }) => {
      setValue(new_value);
    },
    [setValue]
  );

  const mustBeExpanded = useMemo(() => {
    for (const day of DAYS) {
      const next_day = nextDay(day);
      if (value[`${day}_opens_at`] !== value[`${next_day}_opens_at`])
        return true;
      if (value[`${day}_open_seconds`] !== value[`${next_day}_open_seconds`])
        return true;
    }
    return false;
  }, [value]);
  const [isExpanded, setIsExpanded] = useState(mustBeExpanded);
  useEffect(
    () => setIsExpanded(isExpanded || mustBeExpanded),
    [mustBeExpanded, isExpanded]
  );

  const onClickExpandCollapse = useCallback(() => {
    setIsExpanded((isExpandedWas) => !isExpandedWas);
  }, []);

  return html`
    <${Fragment}>
      <button disabled=${mustBeExpanded} type="button" className="flex justify-start items-center space-x-1 cursor-pointer disabled:cursor-default" onClick=${onClickExpandCollapse}>
        <span className=${classNames("transition", {
          "rotate-90": isExpanded || mustBeExpanded,
        })}><${GoChevronRight} /></span>
        Hours
      </button>
      ${
        isExpanded || mustBeExpanded
          ? DAYS.map(
              (day) => html`<${HoursField}
                key=${day}
                value=${value}
                errors=${props.errors}
                day=${day}
                onChange=${onChange}
              />`
            )
          : html`<${AllHoursField}
              value=${value}
              errors=${props.errors}
              onChange=${onChange}
            />`
      }
    </${Fragment}>
  `;
}
