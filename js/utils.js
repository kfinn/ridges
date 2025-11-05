export function onDocumentReady(fn) {
  if (document.readyState !== "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}

export function nextDay(day) {
  if (day === "monday") return "tuesday";
  if (day === "tuesday") return "wednesday";
  if (day === "wednesday") return "thursday";
  if (day === "thursday") return "friday";
  if (day === "friday") return "saturday";
  if (day === "saturday") return "sunday";
  return "monday";
}

export function previousDay(day) {
  if (day === "tuesday") return "monday";
  if (day === "wednesday") return "tuesday";
  if (day === "thursday") return "wednesday";
  if (day === "friday") return "thursday";
  if (day === "saturday") return "friday";
  if (day === "sunday") return "saturday";
  return "sunday";
}

export function nextDays(day) {
  let next_days = [];
  let current_day = nextDay(day);
  while (current_day !== "monday") {
    next_days.push(current_day);
    current_day = nextDay(current_day);
  }
  return next_days;
}

export function previousDays(day) {
  let previousDays = [];
  let current_day = previousDay(day);
  while (current_day !== "sunday") {
    previousDays.push(current_day);
    current_day = previousDay(current_day);
  }
  return previousDays;
}
