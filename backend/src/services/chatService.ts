import { createConversationRepo, type ConversationRepo } from '../repos/conversationRepo.ts';
import { createMessageRepo, type MessageRepo } from '../repos/messageRepo.ts';
import { ProviderHttpError, ProviderNotConfiguredError, ProviderTimeoutError, type OpenAIClient } from './openaiClient.ts';

export interface GenerateReplyRequest {
  message: string;
  requestId: string;
  model?: string;
  temperature?: number;
  clientId?: string;
  conversationId?: string;
}

export interface GenerateReplyResponse {
  requestId: string;
  conversationId: string;
  reply: {
    id: string;
    role: string;
    content: string;
  };
}

export class ChatServiceError extends Error {
  readonly code: string;
  readonly status: number;
  readonly requestId: string;

  constructor(code: string, status: number, message: string, requestId: string) {
    super(message);
    this.code = code;
    this.status = status;
    this.requestId = requestId;
  }
}

export interface ChatService {
  generateReply(request: GenerateReplyRequest): Promise<GenerateReplyResponse>;
}

interface ChatServiceDeps {
  conversationRepo?: ConversationRepo;
  messageRepo?: MessageRepo;
}

export function createChatService(openAIClient: OpenAIClient, deps?: ChatServiceDeps): ChatService {
  const conversationRepo = deps?.conversationRepo ?? createConversationRepo();
  const messageRepo = deps?.messageRepo ?? createMessageRepo();

  return {
    async generateReply(request: GenerateReplyRequest): Promise<GenerateReplyResponse> {
      try {
        const completion = await openAIClient.createChatCompletion(request);
        const choice = completion.choices[0];
        const content = choice?.message?.content;
        const role = choice?.message?.role;

        if (typeof content !== 'string' || content.trim().length === 0 || typeof role !== 'string') {
          throw new ChatServiceError(
            'invalid_provider_response',
            502,
            'provider returned invalid response payload',
            request.requestId
          );
        }

        const conversation = resolveConversation(request, conversationRepo);

        messageRepo.appendMessage({
          id: `msg_user_${request.requestId}`,
          conversationId: conversation.id,
          role: 'user',
          content: request.message
        });

        messageRepo.appendMessage({
          id: completion.id,
          conversationId: conversation.id,
          role: 'assistant',
          content
        });

        conversationRepo.touchConversation(conversation.id);

        return {
          requestId: request.requestId,
          conversationId: conversation.id,
          reply: {
            id: completion.id,
            role,
            content
          }
        };
      } catch (error) {
        if (error instanceof ChatServiceError) {
          throw error;
        }

        if (error instanceof ProviderTimeoutError) {
          throw new ChatServiceError('provider_timeout', 504, 'provider timeout', request.requestId);
        }

        if (error instanceof ProviderHttpError) {
          if (error.status === 429) {
            throw new ChatServiceError('rate_limit', 429, 'rate limit', request.requestId);
          }

          throw new ChatServiceError('provider_error', 502, error.message, request.requestId);
        }

        if (error instanceof ProviderNotConfiguredError) {
          throw new ChatServiceError('provider_error', 503, error.message, request.requestId);
        }

        throw new ChatServiceError('provider_error', 502, 'provider request failed', request.requestId);
      }
    }
  };
}

function resolveConversation(request: GenerateReplyRequest, conversationRepo: ConversationRepo) {
  if (request.conversationId) {
    const existing = conversationRepo.getConversation(request.conversationId);
    if (existing) {
      return existing;
    }

    return conversationRepo.createConversation({
      id: request.conversationId,
      clientId: request.clientId ?? 'anonymous',
      title: request.message.slice(0, 32)
    });
  }

  return conversationRepo.createConversation({
    clientId: request.clientId ?? 'anonymous',
    title: request.message.slice(0, 32)
  });
}
