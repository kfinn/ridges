import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import camelize from "camelize";
import { html } from "htm/react";
import { createRoot } from "react-dom/client";
import { onDocumentReady } from "utils";

const queryClient = new QueryClient();

const COMPONENT_IMPORT_PATHS = {
  HoursFields: "components/hours-fields",
  LocationField: "components/location-field",
  LocationMap: "components/location-map",
  PlacesMap: "components/places-map",
  TagsField: "components/tags-field",
};

onDocumentReady(() => {
  document
    .querySelectorAll("[data-react-component-name]")
    .forEach((element) => {
      const componentImportPath =
        COMPONENT_IMPORT_PATHS[
          element.getAttribute("data-react-component-name")
        ];
      import(componentImportPath)
        .then(({ default: Component }) => {
          const root = createRoot(element);
          if (element.hasAttribute("data-react-component-props")) {
            const snakeCaseProps = JSON.parse(
              element.getAttribute("data-react-component-props")
            );
            const props = camelize(snakeCaseProps);
            root.render(
              html`<${QueryClientProvider} client=${queryClient}>
              <${Component} ...${props} />
            </${QueryClientProvider}>`
            );
          } else {
            root.render(
              html`<${QueryClientProvider}  client=${queryClient}>
              <${Component} />
            </${QueryClientProvider}>`
            );
          }
        })
        .catch((error) => console.error(error));
    });
});
