import classNames from "classnames";
import { INPUT_CLASS_NAME } from "components/field";
import Label from "components/label";
import { html } from "htm/react";
import _ from "lodash";
import { useCallback, useEffect, useRef, useState } from "react";

function calculatePriceRating(event, element) {
  const boundingClientRect = element.getBoundingClientRect();
  return _.clamp(
    _.ceil(
      (5 * (event.clientX - boundingClientRect.left)) /
        boundingClientRect.width,
    ),
    1,
    5,
  );
}

export default function PriceRatingField(props) {
  const [value, setValue] = useState(props.value);
  const [draggingValue, setDraggingValue] = useState(null);

  const ref = useRef();

  const onPointerDown = useCallback(
    (event) => {
      if (!event.isPrimary) return;
      event.preventDefault();
      setDraggingValue(calculatePriceRating(event, ref.current));
    },
    [value],
  );
  useEffect(() => {
    if (draggingValue === null) return;

    const onPointerMove = (event) => {
      if (!event.isPrimary) return;
      setDraggingValue(calculatePriceRating(event, ref.current));
    };
    document.addEventListener("pointermove", onPointerMove);

    const onPointerUp = (event) => {
      if (!event.isPrimary) return;
      setValue(draggingValue);
      setDraggingValue(null);
    };
    document.addEventListener("pointerup", onPointerUp);

    const onPointerCancel = (event) => {
      if (!event.isPrimary) return;
      setDraggingValue(null);
    };
    document.addEventListener("pointercancel", onPointerCancel);

    return () => {
      document.removeEventListener("pointermove", onPointerMove);
      document.removeEventListener("pointerup", onPointerMove);
      document.removeEventListener("pointercancel", onPointerCancel);
    };
  }, [draggingValue]);

  return html`<${Label} htmlFor="price_rating" label="Price">
    <div
      className=${classNames(INPUT_CLASS_NAME, "flex justify-start")}
      id="price_rating"
    >
      <div
        className="cursor-pointer select-none touch-pan-y space-x-0.5"
        ref=${ref}
        onPointerDown=${onPointerDown}
      >
        ${_.map(
          _.range(5),
          (index) =>
            html`<span
              key=${index}
              className=${classNames({
                "text-gray-300 dark:text-gray-600":
                  index + 1 > (draggingValue || value),
              })}
              >$<span></span
            ></span>`,
        )}
      </div>
    </div>
    <input type="hidden" name="price_rating" value=${value}/>
  </${Label}>`;
}
