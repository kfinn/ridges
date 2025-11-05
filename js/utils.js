export function onDocumentReady(fn) {
  if (document.readyState !== "loading") {
    fn();
  } else {
    document.addEventListener("DOMContentLoaded", fn);
  }
}

export const DAYS = [
  "monday",
  "tuesday",
  "wednesday",
  "thursday",
  "friday",
  "saturday",
  "sunday",
];

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

export function timeToSecondsAfterMidnight(time) {
  const [time_hours, time_minutes, time_seconds] = time.split(":");
  return (
    (parseInt(time_seconds) || 0) +
    (parseInt(time_minutes) || 0) * 60 +
    (parseInt(time_hours) || 0) * 60 * 60
  );
}

export function secondsAfterMidnightToTime(seconds_after_midnight) {
  const seconds = seconds_after_midnight % 60;
  const minutes_after_midnight = Math.floor(seconds_after_midnight / 60);
  const minutes = minutes_after_midnight % 60;
  const hours_after_midnight = Math.floor(minutes_after_midnight / 60);
  const hours = hours_after_midnight % 24;

  return `${hours < 10 ? `0${hours}` : hours}:${
    minutes < 10 ? `0${minutes}` : minutes
  }:${seconds < 10 ? `0${seconds}` : seconds}`;
}

export function timeAddSeconds(time, seconds) {
  const time_seconds_after_midnight = timeToSecondsAfterMidnight(time);
  const result_seconds_after_midnight =
    (time_seconds_after_midnight + seconds) % (60 * 60 * 24);

  return secondsAfterMidnightToTime(result_seconds_after_midnight);
}

export function secondsBetweenTimes(start, end) {
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
