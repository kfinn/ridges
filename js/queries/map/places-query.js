import api from "api";

export default function placesQuery(params) {
  return {
    queryKey: ["map", "places", params],
    queryFn: async () => {
      const response = await api.get("map/v1/places", { params });
      return response.data;
    },
    placeholderData: (previousData) => previousData,
  };
}
