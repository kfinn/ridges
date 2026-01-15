import classNames from "classnames";
import AllHoursField from "components/all-hours-field";
import HoursField from "components/hours-field";
import UnavailableAllHoursField from "components/unavailable-all-hours-field";
import { html } from "htm/react";
import { Fragment, useCallback, useMemo, useState } from "react";
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

  const isAllHoursFieldAvailable = useMemo(() => {
    for (const day of DAYS) {
      const dayNextDay = nextDay(day);
      if (value[`${day}OpensAt`] !== value[`${dayNextDay}OpensAt`])
        return false;
      if (value[`${day}OpenSeconds`] !== value[`${dayNextDay}OpenSeconds`])
        return false;
    }
    return true;
  }, [value]);
  const [isExpanded, setIsExpanded] = useState(!isAllHoursFieldAvailable);

  const onClickExpandCollapse = useCallback(() => {
    setIsExpanded((isExpandedWas) => !isExpandedWas);
  }, []);

  return html`
    <${Fragment}>
      <button type="button" className="flex justify-start items-center space-x-1 cursor-pointer" onClick=${onClickExpandCollapse}>
        <span className=${classNames("transition", {
          "rotate-90": isExpanded,
        })}><${GoChevronRight} /></span>
        Hours
      </button>
      ${
        isExpanded
          ? DAYS.map(
              (day) => html`<${HoursField}
                key=${day}
                value=${value}
                errors=${props.errors}
                day=${day}
                onChange=${onChange}
              />`
            )
          : isAllHoursFieldAvailable
          ? html`<${AllHoursField}
              value=${value}
              errors=${props.errors}
              onChange=${onChange}
            />`
          : html`<${UnavailableAllHoursField}
              value=${value}
              onClick=${onClickExpandCollapse}
            />`
      }
    </${Fragment}>
  `;
}
