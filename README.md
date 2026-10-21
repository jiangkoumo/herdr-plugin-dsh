# herdr-plugin-dsh

给 [Herdr](https://herdr.dev) 用的 dsh-tui 扩展：一键在旁边的 pane 里拉起
`dsh-tui`，并按当前 pane 的目录启动。

## 它做什么

- `dsh-tui.start`：在当前 pane 右侧分出一个 pane（保持焦点不动），cd 到当前
  pane 的目录，执行 `dsh-tui`。
- `dsh-tui.resume`：同上，但执行 `dsh-tui --resume`，恢复该目录最近一次的会话。

dsh-tui 自己会调 `herdr pane report-agent`，所以 pane 一开出来，Herdr 侧栏就会
显示它的 `idle` / `working` / `blocked`，`herdr agent wait`、`herdr agent prompt`
也都能直接对它用。插件本身不碰状态上报。

## 安装

```sh
herdr plugin link /path/to/herdr-plugin-dsh
```

`plugin link` 只记录路径，不会运行构建命令。目录移动或重命名后需要重新 link。

## 键位

在 `~/.config/herdr/config.toml` 里绑：

```toml
[[keys.command]]
key = "prefix+alt+d"
type = "plugin_action"
command = "dsh-tui.start"
description = "start dsh-tui"

[[keys.command]]
key = "prefix+alt+shift+d"
type = "plugin_action"
command = "dsh-tui.resume"
description = "resume dsh-tui"
```

改完跑 `herdr server reload-config`。也可以不绑键，直接：

```sh
herdr plugin action invoke start --plugin dsh-tui
herdr plugin action invoke resume --plugin dsh-tui
```

## 依赖

- `dsh-tui` 在 `PATH` 上。
- `python3`：只用来从 `HERDR_PLUGIN_CONTEXT_JSON` 里取当前 pane 的目录
  （插件命令的 cwd 是插件目录，不是你的工作目录）。

## 卸载

```sh
herdr plugin unlink dsh-tui
```

## 边界

这不是真正的 "kind"：`herdr agent start --kind dsh-tui` 仍然不可用，因为 kind
列表编译在 Herdr 里（`src/detect/mod.rs` 的 `Agent` 枚举）。本插件走的是
`pane split` + `pane run`，效果上是「一键起一个被 Herdr 识别的 dsh-tui」，
但不是 `agent start` 这条 API。

另外，Herdr 服务器重启后的会话恢复依赖 agent 上报 resume 命令；dsh-tui 目前
只报 state，没报 resume 命令，所以重启后不会自动回到原来的会话（插件只能
帮你手动 `--resume`）。
