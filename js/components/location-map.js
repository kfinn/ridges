import { html } from "htm/react";
import { forwardRef } from "react";
import Map, { Marker } from "react-map-gl/maplibre";

const LocationMap = forwardRef(
  ({ latitude, longitude, onClick }, ref) =>
    html`<${Map}
      ref=${ref}
      initialViewState=${{
        longitude: longitude,
        latitude: latitude,
        zoom: 15,
      }}
      mapStyle="https://tiles.openfreemap.org/styles/liberty"
      onClick=${onClick}
    >
      <${Marker} longitude=${longitude} latitude=${latitude} />
    </${Map}>`
);
export default LocationMap;
