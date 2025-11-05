import HoursField from "components/hours-field";
import { html } from "htm/react";
import { Fragment, useCallback, useState } from "react";

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

  return html`
    <${Fragment}>
      <${HoursField} value=${value} errors=${props.errors} day="monday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="tuesday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="wednesday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="thursday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="friday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="saturday" onChange=${onChange} />
      <${HoursField} value=${value} errors=${props.errors} day="sunday" onChange=${onChange} />
    </${Fragment}>
  `;
}
