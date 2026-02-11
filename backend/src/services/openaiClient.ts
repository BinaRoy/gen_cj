export interface OpenAIChatCompletionRequest {
  message: string;
  requestId: string;
  model?: string;
  temperature?: number;
}

export interface OpenAIChatCompletionResponse {
  id: string;
  choices: Array<{
    message: {
      role: string;
      content: string;
    };
  }>;
}

export class ProviderTimeoutError extends Error {}

export class ProviderHttpError extends Error {
  readonly status: number;

  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export class ProviderNotConfiguredError extends Error {}

export interface OpenAIClient {
  createChatCompletion(request: OpenAIChatCompletionRequest): Promise<OpenAIChatCompletionResponse>;
}

type Transport = (request: OpenAIChatCompletionRequest) => Promise<OpenAIChatCompletionResponse>;

export function createOpenAIClient(transport?: Transport): OpenAIClient {
  return {
    async createChatCompletion(request: OpenAIChatCompletionRequest): Promise<OpenAIChatCompletionResponse> {
      if (transport) {
        return transport(request);
      }

      throw new ProviderNotConfiguredError('openai transport is not configured');
    }
  };
}
