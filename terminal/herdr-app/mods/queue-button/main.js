import { View, svg } from "gpui-kit"
import { h_flex } from "gpui-base"
import { layout, nextCommand, run, theme } from "herdr"

function findBlock(node, id) {
  if (node?.id === id) return node

  for (const child of node?.children ?? []) {
    const block = findBlock(child, id)
    if (block) return block
  }
}

function isQueueOpen() {
  const panel = findBlock(layout(), "panel")
  return Boolean(
    panel && !panel.hidden && findBlock(panel, "panel-body")?.active === "todo",
  )
}

function toggleQueue() {
  if (isQueueOpen()) {
    run("layout.hide", { id: "panel" })
    return
  }

  run("layout.select", { stack: "panel-body", child: "todo" })
  run("layout.show", { id: "panel" })
}

export default class QueueButton extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const command = await nextCommand()
        if (command === "toggle") toggleQueue()
      }
    })
  }

  render() {
    const colors = theme()
    const active = isQueueOpen()

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
          .on_click(toggleQueue)
          .child(svg("mods/todo/queue.svg").size(14))
          .child("Queue"),
      )
  }
}
