# 2026-02-13 Helloworld 工程结构分析与本仓库映射

## 1. 参考工程（`D:\DevEvo_Projects\Helloworld`）真实结构要点

对应 Linux 路径：`/mnt/d/DevEvo_Projects/Helloworld`

顶层关键文件与目录：

- `AppScope/app.json5`
- `build-profile.json5`
- `hvigor/`
- `hvigorfile.ts`
- `oh-package.json5`
- `oh-package-lock.json5`
- `entry/`

`entry/` 关键文件：

- `entry/cjpm.toml`
- `entry/cjpm.lock`
- `entry/build-profile.json5`
- `entry/hvigorfile.ts`
- `entry/src/main/module.json5`
- `entry/src/main/cangjie/*.cj`
- `entry/src/main/resources/...`

能力入口约定（来自 `module.json5`）：

- `srcEntry`: `ohos_app_cangjie_entry.MyAbilityStage`
- `abilities[].srcEntry`: `ohos_app_cangjie_entry.MainAbility`

窗口加载约定（来自 `main_ability.cj`）：

- `windowStage.loadContent("EntryView")`

## 2. 当前仓库（`/home/gloria/Cangjie/gen_cangjie`）现状

当前是多目录工作区，不是 DevEco Stage 工程：

- `app/`（仓颉领域/网络/UI 代码 + 测试）
- `backend/`（Node/TS 服务）
- `docs/`（计划、流程、引用资料、编译日志）

已完成包名统一（app 侧）：

- `package ohos_app_cangjie_entry`

## 3. 映射规则（本仓库 -> DevEco entry 模块）

### 3.1 仓颉源码

- `app/src/domain/models/ChatModels.cj`
  -> `entry/src/main/cangjie/domain/models/ChatModels.cj`
- `app/src/domain/ChatUseCase.cj`
  -> `entry/src/main/cangjie/domain/ChatUseCase.cj`
- `app/src/network/ApiClient.cj`
  -> `entry/src/main/cangjie/network/ApiClient.cj`
- `app/src/storage/LocalStore.cj`
  -> `entry/src/main/cangjie/storage/LocalStore.cj`
- `app/src/ui/ChatPage.cj`
  -> `entry/src/main/cangjie/ui/ChatPage.cj`
- `app/src/ui/ConversationListPage.cj`
  -> `entry/src/main/cangjie/ui/ConversationListPage.cj`
- `app/src/ui/index.cj`
  -> `entry/src/main/cangjie/index.cj`

### 3.2 能力入口文件

保持 Helloworld 自带：

- `entry/src/main/cangjie/ability_stage.cj`
- `entry/src/main/cangjie/main_ability.cj`

仅确保 `main_ability.cj` 的 `loadContent(...)` 与 `index.cj` 的 `@Entry @Component` 类名一致。

### 3.3 测试与产物

- 本仓库测试继续留在：`app/test/...`
- 编译/测试日志统一归档：`docs/process/compile-logs/`
- 参考仓库与文档统一归档：`docs/references/`

## 4. 输出结构与 references 结构对齐

本次输出统一采用两层视图：

- `docs/references/`：只存“外部参考工程/官方参考资料”。
- `docs/process/`：只存“本仓库执行产物（映射、迁移命令、验证日志）”。

对应落地文件：

- 路径映射清单：`docs/process/2026-02-13-current-repo-to-deveco-entry-mapping.md`
- 迁移命令清单：`docs/process/2026-02-13-app-src-to-entry-migration-commands.md`
- 本次最小验证日志：`docs/process/compile-logs/20260213-114753-structure-mapping-min-verify.log`

## 5. 结构调整边界（执行约束）

- 不在本仓库引入 DevEco 生成产物（`.hvigor/`, `.idea/`, `oh_modules/`）。
- 不改动 `backend/` 目录结构。
- 本次只做结构映射与可编译入口对齐，不扩展新功能。

## 6. 执行完成判定

- 映射后的仓颉文件在 DevEco entry 结构中可被编译识别。
- 入口页面可通过 `loadContent(<EntryClassName>)` 正确加载。
- 变更有日志记录和文件清单记录。
