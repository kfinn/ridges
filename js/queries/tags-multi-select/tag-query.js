import api from "api";

export default function tagQuery(id) {
  return {
    queryKey: ["tags-multi-select", "tags", id],
    queryFn: async () => {
      const response = await api.get(`tags_multi_select/v1/tags/${id}`);
      return response.data;
    },
    placeholderData: (previousData) => previousData,
  };
}
