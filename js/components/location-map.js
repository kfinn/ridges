import { html } from "htm/react";
import { forwardRef } from "react";
import Map, { GeolocateControl, Marker } from "react-map-gl/maplibre";
import { useColorScheme } from "utils/use-color-scheme";

const LocationMap = forwardRef(({ latitude, longitude, onClick }, ref) => {
  const colorScheme = useColorScheme();

  return html`<${Map}
      ref=${ref}
      initialViewState=${{
        longitude: longitude,
        latitude: latitude,
        zoom: 15,
      }}
      mapStyle=${
        colorScheme === "light"
          ? "https://tiles.openfreemap.org/styles/positron"
          : "https://tiles.openfreemap.org/styles/dark"
      }
      onClick=${onClick}
    >
      <${Marker} longitude=${longitude} latitude=${latitude} anchor="bottom">
        <img
          width="16"
          src=${
            colorScheme === "light"
              ? MANTLE_ASSET_URL("images/pin-light.png")
              : MANTLE_ASSET_URL("images/pin-dark.png")
          }
        />
      </${Marker}>
      <${GeolocateControl} />
    </${Map}>`;
});
export default LocationMap;
