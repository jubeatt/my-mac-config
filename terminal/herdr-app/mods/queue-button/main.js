import { View, svg } from "gpui-kit"
import { h_flex } from "gpui-base"
import { layout, run, theme } from "herdr"

function findBlock(node, id) {
  if (node?.id === id) return node

  for (const child of node?.children ?? []) {
    const block = findBlock(child, id)
    if (block) return block
  }
}

export default class QueueButton extends View {
  render() {
    const colors = theme()
    const root = layout()
    const panel = findBlock(root, "panel")
    const panelBody = findBlock(panel, "panel-body")
    const active = Boolean(
      panel && !panel.hidden && panelBody?.active === "queue",
    )

    return h_flex()
      .size_full()
      .items_center()
      .justify_center()
      .bg(colors.chrome)
      .border_b(1)
      .border_color(colors.border)
      .child(
        h_flex()
          .id("queue-panel-toggle")
          .role("button")
          .h(26)
          .px(8)
          .gap(5)
          .items_center()
          .rounded(6)
          .text_size(12)
          .bg(active ? colors.selected : colors.chrome)
          .text_color(active ? colors.foreground : colors.muted)
          .hover((style) => style.bg(colors.hover))
          .on_mouse_down("left", (_event, cx) => cx.stop_propagation())
          .on_click(() => {
            if (active) {
              run("layout.hide", { id: "panel" })
              return
            }

            run("layout.select", { stack: "panel-body", child: "queue" })
            run("layout.show", { id: "panel" })
          })
          .child(svg("mods/queue/queue.svg").size(14))
          .child("Queue"),
      )
  }
}
