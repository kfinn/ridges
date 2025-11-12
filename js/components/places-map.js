import { useQuery } from "@tanstack/react-query";
import { html } from "htm/react";
import _ from "lodash";
import placesQuery from "queries/map/places-query";
import { useMemo, useRef, useState } from "react";
import Map, { Layer, Source } from "react-map-gl/maplibre";

export default function PlacesMap() {
  const mapRef = useRef();
  const [filter, setFilter] = useState({});
  const { data: places } = useQuery(placesQuery(filter));
  const placesGeojson = useMemo(
    () =>
      places && {
        type: "FeatureCollection",
        features: places.map((place) => ({
          type: "Feature",
          id: place.id,
          geometry: {
            type: "Point",
            coordinates: [place.location.longitude, place.location.latitude],
          },
          properties: {
            name: place.name,
            name: place.address,
            name: place.url,
          },
        })),
      },
    [places]
  );

  const onMove = useMemo(
    () =>
      _.debounce(() => {
        const mapBounds = mapRef.current.getBounds();
        setFilter({
          inBounds: {
            north: mapBounds.getNorth(),
            east: mapBounds.getEast(),
            south: mapBounds.getSouth(),
            west: mapBounds.getWest(),
          },
        });
      }, 150),
    [setFilter]
  );

  return html`<${Map}
    mapStyle="https://tiles.openfreemap.org/styles/liberty"
    ref=${mapRef}
    onMove=${onMove}
    initialViewState=${{
      longitude: -73.9029527,
      latitude: 40.7014435,
      zoom: 15,
    }}
  >
    ${
      placesGeojson &&
      html`<${Source} id="places-source" type="geojson" data=${placesGeojson}>
        <${Layer} id="places-layer" type="circle" />
      </${Source}>`
    }
  </${Map}>`;
}
