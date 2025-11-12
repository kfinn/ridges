import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import camelize from "camelize";
import { ALL_COMPONENTS } from "components";
import { html } from "htm/react";
import { createRoot } from "react-dom/client";
import { onDocumentReady } from "utils";

const queryClient = new QueryClient();

onDocumentReady(() => {
  document
    .querySelectorAll("[data-react-component-name]")
    .forEach((element) => {
      const root = createRoot(element);

      const Component =
        ALL_COMPONENTS[element.getAttribute("data-react-component-name")];
      if (element.hasAttribute("data-react-component-props")) {
        const snakeCaseProps = JSON.parse(
          element.getAttribute("data-react-component-props")
        );
        const props = camelize(snakeCaseProps);
        root.render(
          html`<${QueryClientProvider} client=${queryClient}>
            <${Component} ...${props}
          /></${QueryClientProvider}>`
        );
      } else {
        root.render(
          html`<${QueryClientProvider}  client=${queryClient}>
            <${Component} />
          </${QueryClientProvider}>`
        );
      }
    });
});
