import classNames from "classnames";
import AllHoursField from "components/all-hours-field";
import HoursField from "components/hours-field";
import { html } from "htm/react";
import { Fragment, useCallback, useEffect, useMemo, useState } from "react";
import { GoChevronRight } from "react-icons/go";
import { DAYS, nextDay } from "utils";

export default function HoursFields(props) {
  const [value, setValue] = useState({
    mondayOpensAt: props.mondayOpensAt,
    mondayOpenSeconds: props.mondayOpenSeconds,
    tuesdayOpensAt: props.tuesdayOpensAt,
    tuesdayOpenSeconds: props.tuesdayOpenSeconds,
    wednesdayOpensAt: props.wednesdayOpensAt,
    wednesdayOpenSeconds: props.wednesdayOpenSeconds,
    thursdayOpensAt: props.thursdayOpensAt,
    thursdayOpenSeconds: props.thursdayOpenSeconds,
    fridayOpensAt: props.fridayOpensAt,
    fridayOpenSeconds: props.fridayOpenSeconds,
    saturdayOpensAt: props.saturdayOpensAt,
    saturdayOpenSeconds: props.saturdayOpenSeconds,
    sundayOpensAt: props.sundayOpensAt,
    sundayOpenSeconds: props.sundayOpenSeconds,
  });

  const onChange = useCallback(
    ({ target: { value: newValue } }) => {
      setValue(newValue);
    },
    [setValue]
  );

  const mustBeExpanded = useMemo(() => {
    for (const day of DAYS) {
      const dayNextDay = nextDay(day);
      if (value[`${day}OpensAt`] !== value[`${dayNextDay}OpensAt`]) return true;
      if (value[`${day}OpenSeconds`] !== value[`${dayNextDay}OpenSeconds`])
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
