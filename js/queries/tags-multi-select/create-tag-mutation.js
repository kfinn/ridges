import api from "api";

export default function createTagMutation(csrfToken) {
  return {
    mutationFn: async (tag, context) => {
      console.log(tag, csrfToken);
      try {
        const response = await api.post("tags_multi_select/v1/tags/new", {
          ...tag,
          _csrf_token: csrfToken,
        });
        return response.data;
      } finally {
        context.client.invalidateQueries({
          queryKey: ["tags-multi-select", "tags"],
        });
      }
    },
  };
}
