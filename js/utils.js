export const BASE_CLASS_NAME =
  "bg-gray-50 dark:bg-gray-900 text-gray-800 dark:text-gray-100";

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
  let nextDays = [];
  let currentDay = nextDay(day);
  while (currentDay !== "monday") {
    nextDays.push(currentDay);
    currentDay = nextDay(currentDay);
  }
  return nextDays;
}

export function previousDays(day) {
  let previousDays = [];
  let currentDay = previousDay(day);
  while (currentDay !== "sunday") {
    previousDays.push(currentDay);
    currentDay = previousDay(currentDay);
  }
  return previousDays;
}

export function timeToSecondsAfterMidnight(time) {
  const [timeHours, timeMinutes, timeSeconds] = time.split(":");
  return (
    (parseInt(timeSeconds) || 0) +
    (parseInt(timeMinutes) || 0) * 60 +
    (parseInt(timeHours) || 0) * 60 * 60
  );
}

export function secondsAfterMidnightToTime(secondsAfterMidnight) {
  const seconds = secondsAfterMidnight % 60;
  const minutesAfterMidnight = Math.floor(secondsAfterMidnight / 60);
  const minutes = minutesAfterMidnight % 60;
  const hoursAfterMidnight = Math.floor(minutesAfterMidnight / 60);
  const hours = hoursAfterMidnight % 24;

  return `${hours < 10 ? `0${hours}` : hours}:${
    minutes < 10 ? `0${minutes}` : minutes
  }:${seconds < 10 ? `0${seconds}` : seconds}`;
}

export function timeAddSeconds(time, seconds) {
  const timeSecondsAfterMidnight = timeToSecondsAfterMidnight(time);
  const resultSecondsAfterMidnight =
    (timeSecondsAfterMidnight + seconds) % (60 * 60 * 24);

  return secondsAfterMidnightToTime(resultSecondsAfterMidnight);
}

export function secondsBetweenTimes(start, end) {
  if (start.length === 0 || end.length === 0) {
    return 0;
  }

  const startTimeSecondsAfterMidnght = timeToSecondsAfterMidnight(start);
  const endTimeSecondsAfterMidnight = timeToSecondsAfterMidnight(end);

  let secondsBetweenTime =
    endTimeSecondsAfterMidnight - startTimeSecondsAfterMidnght;
  while (secondsBetweenTime < 0) {
    secondsBetweenTime += 60 * 60 * 24;
  }
  return secondsBetweenTime;
}
