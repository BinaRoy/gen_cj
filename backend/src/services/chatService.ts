import { ProviderHttpError, ProviderTimeoutError, type OpenAIClient } from './openaiClient.ts';

export interface GenerateReplyRequest {
  message: string;
  requestId: string;
  model?: string;
  temperature?: number;
}

export interface GenerateReplyResponse {
  requestId: string;
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

export function createChatService(openAIClient: OpenAIClient): ChatService {
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

        return {
          requestId: request.requestId,
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

        throw new ChatServiceError('provider_error', 502, 'provider request failed', request.requestId);
      }
    }
  };
}
