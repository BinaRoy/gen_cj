import { createRequestId, errorResult, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';

export function handleConversations(request: RouteRequest): RouteResult {
  const requestId = createRequestId();

  if (request.method !== 'GET') {
    return errorResult(405, 'method_not_allowed', 'method not allowed', requestId);
  }

  const clientError = requireClientId(request, requestId);
  if (clientError) {
    return clientError;
  }

  return {
    status: 200,
    body: {
      request_id: requestId,
      items: []
    }
  };
}
