import { svg } from "gpui-kit"
import { h_flex } from "gpui-base"
import { layout, run, theme } from "herdr"

const PANEL = "panel"
const STACK = "panel-body"
const BLOCK = "todo"

function findBlock(node, id) {
  if (node?.id === id) return node
  for (const child of node?.children ?? []) {
    const block = findBlock(child, id)
    if (block) return block
  }
}

export function isPanelOpen() {
  const panel = findBlock(layout(), PANEL)
  return Boolean(
    panel && !panel.hidden && findBlock(panel, STACK)?.active === BLOCK,
  )
}

export function togglePanel() {
  if (isPanelOpen()) {
    run("layout.hide", { id: PANEL })
    return
  }
  run("layout.select", { stack: STACK, child: BLOCK })
  run("layout.show", { id: PANEL })
}

export function renderButton() {
  const colors = theme()
  const active = isPanelOpen()
  return h_flex()
    .size_full()
    .items_center()
    .justify_center()
    .bg(colors.chrome)
    .border_b(1)
    .border_color(colors.border)
    .child(
      h_flex()
        .id("todo-panel-toggle")
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
        .on_click(togglePanel)
        .child(svg("mods/todo/todo.svg").size(14))
        .child("Todo"),
    )
}
