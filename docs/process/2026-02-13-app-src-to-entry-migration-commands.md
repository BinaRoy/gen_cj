# 2026-02-13 app/src -> entry/src/main/cangjie 迁移命令

## 1. 可执行迁移命令（实际复制）

```bash
set -euo pipefail

SRC_ROOT="/home/gloria/Cangjie/gen_cangjie/app/src"
DST_ROOT="/mnt/d/DevEvo_Projects/Helloworld/entry/src/main/cangjie"

mkdir -p \
  "$DST_ROOT/domain/models" \
  "$DST_ROOT/network" \
  "$DST_ROOT/storage" \
  "$DST_ROOT/ui"

install -m 0644 "$SRC_ROOT/domain/models/ChatModels.cj" "$DST_ROOT/domain/models/ChatModels.cj"
install -m 0644 "$SRC_ROOT/domain/ChatUseCase.cj" "$DST_ROOT/domain/ChatUseCase.cj"
install -m 0644 "$SRC_ROOT/network/ApiClient.cj" "$DST_ROOT/network/ApiClient.cj"
install -m 0644 "$SRC_ROOT/storage/LocalStore.cj" "$DST_ROOT/storage/LocalStore.cj"
install -m 0644 "$SRC_ROOT/ui/ChatPage.cj" "$DST_ROOT/ui/ChatPage.cj"
install -m 0644 "$SRC_ROOT/ui/ConversationListPage.cj" "$DST_ROOT/ui/ConversationListPage.cj"
install -m 0644 "$SRC_ROOT/ui/index.cj" "$DST_ROOT/index.cj"
```

## 2. 可执行预演命令（仅校验，不落盘）

```bash
set -euo pipefail

SRC_ROOT="/home/gloria/Cangjie/gen_cangjie/app/src"
DST_ROOT="/mnt/d/DevEvo_Projects/Helloworld/entry/src/main/cangjie"

for rel in \
  "domain/models/ChatModels.cj" \
  "domain/ChatUseCase.cj" \
  "network/ApiClient.cj" \
  "storage/LocalStore.cj" \
  "ui/ChatPage.cj" \
  "ui/ConversationListPage.cj" \
  "ui/index.cj"
do
  test -f "$SRC_ROOT/$rel"
done

test -d "$DST_ROOT"
echo "DRY-RUN PASS: source files and destination root are ready."
```

## 3. 入口一致性校验命令

```bash
set -euo pipefail

ENTRY_MAIN_ABILITY="/mnt/d/DevEvo_Projects/Helloworld/entry/src/main/cangjie/main_ability.cj"
APP_INDEX="/home/gloria/Cangjie/gen_cangjie/app/src/ui/index.cj"

grep -n 'loadContent("EntryView")' "$ENTRY_MAIN_ABILITY"
grep -n '@Entry' "$APP_INDEX"
grep -n 'class EntryView' "$APP_INDEX"
```
