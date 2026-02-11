import { createRequestId, errorResult, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';

export function handleMessages(request: RouteRequest): RouteResult {
  const requestId = createRequestId();

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

  return {
    status: 200,
    body: {
      request_id: requestId,
      items: [],
      next_cursor: null
    }
  };
}
