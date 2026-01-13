import { useEffect, useState } from "react";

const colorSchemeQueryList = window.matchMedia("(prefers-color-scheme: dark)");

export function useColorScheme() {
  const [colorScheme, setColorScheme] = useState(
    colorSchemeQueryList.matches ? "dark" : "light"
  );

  useEffect(() => {
    const handleChange = (event) => {
      console.log(event);
      setColorScheme(event.matches ? "dark" : "light");
    };
    colorSchemeQueryList.addEventListener("change", handleChange);

    return () =>
      colorSchemeQueryList.removeEventListener("change", handleChange);
  }, []);

  return colorScheme;
}
