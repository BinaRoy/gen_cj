import { createRequestContext } from '../middlewares/requestContext.ts';
import { errorResult, getHeader, requireClientId, type RouteRequest, type RouteResult } from '../schemas/common.ts';
import { validateChatRequestBody } from '../schemas/chat.ts';
import { ChatServiceError, createChatService, type ChatService } from '../services/chatService.ts';
import { createOpenAIClient } from '../services/openaiClient.ts';

const defaultChatService = createChatService(createOpenAIClient());

interface ChatRouteDeps {
  chatService?: ChatService;
}

export async function handleChat(request: RouteRequest, deps?: ChatRouteDeps): Promise<RouteResult> {
  const requestId = createRequestContext(request).requestId;
  const chatService = deps?.chatService ?? defaultChatService;

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
  const clientId = getHeader(request.headers, 'x-client-id');

  try {
    const result = await chatService.generateReply({
      message: validated.value.message,
      clientId,
      conversationId: validated.value.conversation_id,
      model: validated.value.model,
      temperature: validated.value.temperature,
      requestId
    });

    return {
      status: 200,
      body: {
        request_id: requestId,
        conversation_id: result.conversationId,
        reply: result.reply
      }
    };
  } catch (error) {
    if (error instanceof ChatServiceError) {
      return errorResult(error.status, error.code, error.message, error.requestId);
    }

    return errorResult(502, 'provider_error', 'provider request failed', requestId);
  }
}
