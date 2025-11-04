import Field from "components/field";
import { html } from "htm/react";
import { useCallback, useEffect, useRef, useState } from "react";
import Map, { Marker } from "react-map-gl/maplibre";

export default function LocationField(props) {
  const [latitude, setLatitude] = useState(props.latitude);
  const [longitude, setLongitude] = useState(props.longitude);

  const onChangeLatitude = useCallback(
    ({ target: { value } }) => setLatitude(value),
    [setLatitude]
  );
  const onChangeLongitude = useCallback(
    ({ target: { value } }) => setLongitude(value),
    [setLongitude]
  );
  const onClickMap = useCallback(
    ({ lngLat: { lng, lat } }) => {
      setLongitude(lng);
      setLatitude(lat);
    },
    [setLongitude, setLatitude]
  );
  const mapRef = useRef();
  useEffect(() => {
    if (!mapRef.current) return;

    const bounds = mapRef.current.getBounds();
    const lngLat = [longitude, latitude];
    if (!bounds.contains(lngLat)) {
      mapRef.current.easeTo({ center: lngLat });
    }
  }, [latitude, longitude]);

  return html`<div className="flex justify-stretch">
    <div className="flex flex-col space-y-2 items-stretch grow">
      <${Field}
        type="number"
        label="latitude"
        name="location[latitude]"
        value=${latitude}
        onChange=${onChangeLatitude}
      />
      <${Field}
        type="number"
        label="longitude"
        name="location[longitude]"
        value=${longitude}
        onChange=${onChangeLongitude}
      />
    </div>
    <div className="rounded w-64">
      <${Map}
        ref=${mapRef}
        initialViewState=${{
          longitude: longitude,
          latitude: latitude,
          zoom: 14,
        }}
        mapStyle="https://tiles.openfreemap.org/styles/liberty"
        onClick=${onClickMap}
      >
        <${Marker} longitude=${longitude} latitude=${latitude} />
      </${Map}>
    </div>
  </div>`;
}
