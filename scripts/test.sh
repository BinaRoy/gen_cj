#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "[test] backend tests"
npm test -- backend/test/routes.contract.test.ts
npm test -- backend/test/chat.service.test.ts
npm test -- backend/test/persistence.integration.test.ts
npm test -- backend/test/feedback.route.test.ts

if [[ -f "/usr/local/bin/cangjie/envsetup.sh" ]]; then
  echo "[test] cangjie smoke tests"
  # Keep this command aligned with current app baseline test set.
  # shellcheck disable=SC1091
  source /usr/local/bin/cangjie/envsetup.sh
  cjc --test \
    app/src/domain/models/ChatModels.cj \
    app/src/network/ApiClient.cj \
    app/src/network/LoopbackHttpTransport.cj \
    app/src/domain/ChatUseCase.cj \
    app/src/storage/LocalStore.cj \
    app/src/ui/ChatPage.cj \
    app/src/ui/ConversationListPage.cj \
    app/src/ui/DefaultGatewayFactory.cj \
    app/test/domain/chat_use_case_test.cj \
    app/test/ui/chat_page_smoke_test.cj \
    app/test/ui/default_gateway_factory_test.cj \
    -o /tmp/gen_cangjie_app_test
  /tmp/gen_cangjie_app_test
else
  echo "[test] skip cangjie smoke: /usr/local/bin/cangjie/envsetup.sh not found"
fi
