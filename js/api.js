import axios from "axios";
import camelize from "camelize";
import toSnakeCase from "to-snake-case";

const api = axios.create({
  baseURL: "/api",
  paramSerializer: {
    encode: toSnakeCase,
  },
});

api.interceptors.response.use((response) => {
  return {
    ...response,
    ...(response.data !== undefined ? { data: camelize(response.data) } : {}),
  };
});

export default api;
