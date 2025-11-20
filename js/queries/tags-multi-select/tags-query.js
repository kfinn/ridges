import api from "api";

export default function tagsQuery(params) {
  return {
    queryKey: ["tags-multi-select", "tags", params],
    queryFn: async () => {
      const response = await api.get(`tags_multi_select/v1/tags`, { params });
      return response.data;
    },
    placeholderData: (previousData) => previousData,
  };
}
