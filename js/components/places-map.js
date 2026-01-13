import { useQuery } from "@tanstack/react-query";
import classNames from "classnames";
import { html } from "htm/react";
import _ from "lodash";
import placesQuery from "queries/map/places-query";
import { useCallback, useMemo, useRef, useState } from "react";
import Map, { Layer, Popup, Source } from "react-map-gl/maplibre";
import { useColorScheme } from "utils/use-color-scheme";

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
          properties: _.pick(place, "id", "name", "address", "url"),
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

  const [hoveredPlaceId, setHoveredPlaceId] = useState(null);
  const onMouseMove = useCallback(({ features }) => {
    if (_.isEmpty(features)) {
      setHoveredPlaceId(null);
    } else {
      setHoveredPlaceId(features[0].properties.id);
    }
  }, []);

  const [selectedPlaceId, setSelectedPlaceId] = useState(null);
  const onClick = useCallback(({ features }) => {
    setSelectedPlaceId((oldSelectedPlaceId) => {
      if (_.isEmpty(features) || oldSelectedPlaceId) {
        return null;
      } else {
        return features[0].properties.id;
      }
    });
  }, []);
  const selectedPlace = useMemo(() => {
    return places && _.find(places, (place) => place.id === selectedPlaceId);
  }, [places, selectedPlaceId]);

  const colorScheme = useColorScheme();

  return html`<${Map}
    style=${{ height: undefined }}
    cursor=${hoveredPlaceId !== null ? "pointer" : undefined}
    mapStyle=${
      colorScheme === "light"
        ? "https://tiles.openfreemap.org/styles/positron"
        : "https://tiles.openfreemap.org/styles/dark"
    }
    ref=${mapRef}
    onMove=${onMove}
    onMouseMove=${onMouseMove}
    interactiveLayerIds=${["places-layer"]}
    onClick=${onClick}
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
    ${
      selectedPlace &&
      html`<${Popup}
        longitude=${selectedPlace.location.longitude}
        latitude=${selectedPlace.location.latitude}
        onClose=${() => setSelectedPlaceId(null)}
        className=${classNames(
          "[&_.maplibregl-popup-content]:!bg-gray-50",
          "[&_.maplibregl-popup-content]:dark:!bg-gray-900",
          "[&_.maplibregl-popup-content]:!text-gray-800",
          "[&_.maplibregl-popup-content]:dark:!text-gray-100",
          "[&_.maplibregl-popup-tip]:!border-t-gray-50",
          "[&_.maplibregl-popup-tip]:dark:!border-t-gray-900"
        )}
        closeOnClick=${false}
      >
        ${selectedPlace.name}
      </${Popup}>`
    }
  </${Map}>`;
}
