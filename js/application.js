import { ALL_COMPONENTS } from "components";
import { html } from "htm/react";
import { createRoot } from "react-dom/client";
import { onDocumentReady } from "utils";

onDocumentReady(() => {
  document
    .querySelectorAll("[data-react-component-name]")
    .forEach((element) => {
      const root = createRoot(element);

      const Component =
        ALL_COMPONENTS[element.getAttribute("data-react-component-name")];
      if (element.hasAttribute("data-react-component-props")) {
        const props = JSON.parse(
          element.getAttribute("data-react-component-props")
        );
        root.render(html`<${Component} ...${props} />`);
      } else {
        root.render(html`<${Component} />`);
      }
    });
});
