import { createRequestId, errorResult, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';
import { validateChatRequestBody } from '../schemas/chat.ts';

export function handleChat(request: RouteRequest): RouteResult {
  const requestId = createRequestId();

  if (request.method !== 'POST') {
    return errorResult(405, 'method_not_allowed', 'method not allowed', requestId);
  }

  const clientError = requireClientId(request, requestId);
  if (clientError) {
    return clientError;
  }

  const validated = validateChatRequestBody(request.body);
  if (!validated.ok) {
    return errorResult(400, 'invalid_request', validated.message, requestId);
  }

  return {
    status: 200,
    body: {
      request_id: requestId,
      conversation_id: 'conv_placeholder',
      reply: {
        id: 'msg_placeholder',
        role: 'assistant',
        content: `placeholder reply: ${validated.value.message}`
      }
    }
  };
}
