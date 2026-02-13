# 2026-02-13 当前仓库 -> DevEco entry 路径映射清单

## 1. 范围

- 当前仓库根目录：`/home/gloria/Cangjie/gen_cangjie`
- 参考工程根目录：`/mnt/d/DevEvo_Projects/Helloworld`
- 目标模块目录：`/mnt/d/DevEvo_Projects/Helloworld/entry/src/main/cangjie`

## 2. 文件级映射（app/src -> entry/src/main/cangjie）

| 当前仓库路径 | DevEco entry 路径 |
| --- | --- |
| `app/src/domain/models/ChatModels.cj` | `entry/src/main/cangjie/domain/models/ChatModels.cj` |
| `app/src/domain/ChatUseCase.cj` | `entry/src/main/cangjie/domain/ChatUseCase.cj` |
| `app/src/network/ApiClient.cj` | `entry/src/main/cangjie/network/ApiClient.cj` |
| `app/src/storage/LocalStore.cj` | `entry/src/main/cangjie/storage/LocalStore.cj` |
| `app/src/ui/ChatPage.cj` | `entry/src/main/cangjie/ui/ChatPage.cj` |
| `app/src/ui/ConversationListPage.cj` | `entry/src/main/cangjie/ui/ConversationListPage.cj` |
| `app/src/ui/index.cj` | `entry/src/main/cangjie/index.cj` |

## 3. 入口约束（不迁移，仅保持一致）

- 保留参考工程现有能力入口文件：
- `entry/src/main/cangjie/ability_stage.cj`
- `entry/src/main/cangjie/main_ability.cj`
- 对齐规则：
- `main_ability.cj` 中 `windowStage.loadContent("EntryView")`
- `index.cj` 中 `@Entry @Component` 类名应为 `EntryView`

## 4. 非目标范围

- 不迁移 `backend/`。
- 不在当前仓库引入 `.hvigor/`、`.idea/`、`oh_modules/`。
- 不启动 Task 8+ 新功能。
