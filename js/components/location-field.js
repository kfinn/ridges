import Field from "components/field";
import LocationMap from "components/location-map";
import { html } from "htm/react";
import { useCallback, useEffect, useRef, useState } from "react";

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

  return html`<div className="flex flex-col space-y-2 justify-stretch">
    <div className="rounded h-72">
      <${LocationMap}
        latitude=${latitude}
        longitude=${longitude}
        onClick=${onClickMap}
        ref=${mapRef}
      />
    </div>
    <div className="flex space-x-2 items-stretch justify-stretch">
      <${Field}
        type="number"
        label="latitude"
        name="location[latitude]"
        value=${latitude}
        onChange=${onChangeLatitude}
        className="min-w-0 shrink grow"
      />
      <${Field}
        type="number"
        label="longitude"
        name="location[longitude]"
        value=${longitude}
        onChange=${onChangeLongitude}
        className="min-w-0 shrink grow"
      />
    </div>
  </div>`;
}
