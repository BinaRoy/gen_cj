import { createConversationRepo, type ConversationRepo } from '../repos/conversationRepo.ts';
import { createRequestId, errorResult, getHeader, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';

interface ConversationsRouteDeps {
  conversationRepo?: ConversationRepo;
}

const defaultConversationRepo = createConversationRepo();

export function handleConversations(request: RouteRequest, deps?: ConversationsRouteDeps): RouteResult {
  const requestId = createRequestId();
  const conversationRepo = deps?.conversationRepo ?? defaultConversationRepo;

  if (request.method !== 'GET') {
    return errorResult(405, 'method_not_allowed', 'method not allowed', requestId);
  }

  const clientError = requireClientId(request, requestId);
  if (clientError) {
    return clientError;
  }

  const clientId = getHeader(request.headers, 'x-client-id') ?? 'anonymous';
  const limit = parseLimit(request.query?.limit);
  const cursor = request.query?.cursor;
  const listed = conversationRepo.listConversationsByClient(clientId, limit, cursor);

  return {
    status: 200,
    body: {
      request_id: requestId,
      items: listed.items.map((item) => ({
        id: item.id,
        title: item.title,
        updated_at: item.updatedAt
      })),
      next_cursor: listed.nextCursor
    }
  };
}

function parseLimit(raw: string | undefined): number {
  if (!raw) {
    return 20;
  }

  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed)) {
    return 20;
  }

  return Math.max(1, Math.min(parsed, 100));
}
