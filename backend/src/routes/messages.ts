import { createMessageRepo, type MessageRepo } from '../repos/messageRepo.ts';
import { createRequestId, errorResult, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';

interface MessagesRouteDeps {
  messageRepo?: MessageRepo;
}

const defaultMessageRepo = createMessageRepo();

export function handleMessages(request: RouteRequest, deps?: MessagesRouteDeps): RouteResult {
  const requestId = createRequestId();
  const messageRepo = deps?.messageRepo ?? defaultMessageRepo;

  if (request.method !== 'GET') {
    return errorResult(405, 'method_not_allowed', 'method not allowed', requestId);
  }

  const clientError = requireClientId(request, requestId);
  if (clientError) {
    return clientError;
  }

  const conversationId = request.query?.conversation_id;
  if (!conversationId || conversationId.trim().length === 0) {
    return errorResult(400, 'invalid_request', 'conversation_id is required', requestId);
  }

  const limit = parseLimit(request.query?.limit);
  const cursor = request.query?.cursor;
  const listed = messageRepo.listMessages(conversationId, limit, cursor);

  return {
    status: 200,
    body: {
      request_id: requestId,
      items: listed.items.map((item) => ({
        id: item.id,
        role: item.role,
        content: item.content,
        created_at: item.createdAt
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
