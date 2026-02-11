import { createRequestId, errorResult, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';

function isObject(value: unknown): value is Record<string, unknown> {
  return !!value && typeof value === 'object';
}

export function handleFeedback(request: RouteRequest): RouteResult {
  const requestId = createRequestId();

  if (request.method !== 'POST') {
    return errorResult(405, 'method_not_allowed', 'method not allowed', requestId);
  }

  const clientError = requireClientId(request, requestId);
  if (clientError) {
    return clientError;
  }

  if (!isObject(request.body)) {
    return errorResult(400, 'invalid_request', 'request body must be an object', requestId);
  }

  const messageId = request.body.message_id;
  const rating = request.body.rating;
  const comment = request.body.comment;

  if (typeof messageId !== 'string' || messageId.trim().length === 0) {
    return errorResult(400, 'invalid_request', 'message_id is required', requestId);
  }

  if (typeof rating !== 'number' || !Number.isInteger(rating) || rating < 1 || rating > 5) {
    return errorResult(400, 'invalid_request', 'rating must be an integer between 1 and 5', requestId);
  }

  if (comment !== undefined && typeof comment !== 'string') {
    return errorResult(400, 'invalid_request', 'comment must be a string', requestId);
  }

  return {
    status: 200,
    body: {
      request_id: requestId,
      accepted: true
    }
  };
}
