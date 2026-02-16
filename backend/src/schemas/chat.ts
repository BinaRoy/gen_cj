export interface ChatRequestBody {
  message: string;
  conversation_id?: string;
  model?: string;
  temperature?: number;
  stream?: boolean;
}

export interface ValidationResult {
  ok: true;
  value: ChatRequestBody;
}

export interface ValidationError {
  ok: false;
  message: string;
}

export function validateChatRequestBody(body: unknown): ValidationResult | ValidationError {
  if (!body || typeof body !== 'object') {
    return { ok: false, message: 'request body must be an object' };
  }

  const candidate = body as Record<string, unknown>;
  if (typeof candidate.message !== 'string' || candidate.message.trim().length === 0) {
    return { ok: false, message: 'message is required' };
  }

  if ('temperature' in candidate && typeof candidate.temperature !== 'number') {
    return { ok: false, message: 'temperature must be a number' };
  }

  if ('stream' in candidate && typeof candidate.stream !== 'boolean') {
    return { ok: false, message: 'stream must be a boolean' };
  }

  if ('model' in candidate && typeof candidate.model !== 'string') {
    return { ok: false, message: 'model must be a string' };
  }

  if ('conversation_id' in candidate && typeof candidate.conversation_id !== 'string') {
    return { ok: false, message: 'conversation_id must be a string' };
  }

  return {
    ok: true,
    value: {
      message: candidate.message,
      conversation_id: typeof candidate.conversation_id === 'string' ? candidate.conversation_id : undefined,
      model: typeof candidate.model === 'string' ? candidate.model : undefined,
      temperature: typeof candidate.temperature === 'number' ? candidate.temperature : undefined,
      stream: typeof candidate.stream === 'boolean' ? candidate.stream : undefined
    }
  };
}
