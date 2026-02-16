import assert from 'node:assert/strict';
import test from 'node:test';

import { ProviderHttpError, ProviderTimeoutError, createOpenAIClient } from '../src/services/openaiClient.ts';
import { ChatServiceError, createChatService } from '../src/services/chatService.ts';
import { handleChat } from '../src/routes/chat.ts';

const REQUEST_ID = 'req_test_123';

test('chat service returns assistant message on provider success', async () => {
  const openAIClient = createOpenAIClient(async () => ({
    id: 'cmpl-1',
    choices: [
      {
        message: {
          role: 'assistant',
          content: 'hello from provider'
        }
      }
    ]
  }));

  const service = createChatService(openAIClient);
  const result = await service.generateReply({
    message: 'hello',
    requestId: REQUEST_ID
  });

  assert.equal(result.reply.role, 'assistant');
  assert.equal(result.reply.content, 'hello from provider');
  assert.equal(result.requestId, REQUEST_ID);
});

test('chat service maps provider timeout to timeout service error', async () => {
  const openAIClient = createOpenAIClient(async () => {
    throw new ProviderTimeoutError('provider timed out');
  });

  const service = createChatService(openAIClient);

  await assert.rejects(
    () => service.generateReply({ message: 'hello', requestId: REQUEST_ID }),
    (error: unknown) => {
      assert.equal(error instanceof ChatServiceError, true);
      assert.equal((error as ChatServiceError).code, 'provider_timeout');
      return true;
    }
  );
});

test('chat service maps invalid provider payload to invalid_provider_response error', async () => {
  const openAIClient = createOpenAIClient(async () => ({
    id: 'cmpl-2',
    choices: []
  }));

  const service = createChatService(openAIClient);

  await assert.rejects(
    () => service.generateReply({ message: 'hello', requestId: REQUEST_ID }),
    (error: unknown) => {
      assert.equal(error instanceof ChatServiceError, true);
      assert.equal((error as ChatServiceError).code, 'invalid_provider_response');
      return true;
    }
  );
});

test('chat route forwards provider rate limit to normalized 429 error with request_id', async () => {
  const openAIClient = createOpenAIClient(async () => {
    throw new ProviderHttpError(429, 'rate limit');
  });

  const response = await handleChat(
    {
      method: 'POST',
      headers: {
        'x-client-id': 'client-1',
        'x-request-id': REQUEST_ID
      },
      body: {
        message: 'hello'
      }
    },
    {
      chatService: createChatService(openAIClient)
    }
  );

  assert.equal(response.status, 429);
  assert.equal((response.body as { code: string }).code, 'rate_limit');
  assert.equal((response.body as { request_id: string }).request_id, REQUEST_ID);
});

test('chat route returns normalized 503 provider_error when transport is not configured', async () => {
  const response = await handleChat({
    method: 'POST',
    headers: {
      'x-client-id': 'client-1',
      'x-request-id': REQUEST_ID
    },
    body: {
      message: 'hello'
    }
  });

  assert.equal(response.status, 503);
  assert.equal((response.body as { code: string }).code, 'provider_error');
  assert.equal((response.body as { request_id: string }).request_id, REQUEST_ID);
});

test('chat route forwards request conversation_id and client header to service', async () => {
  let captured: { clientId?: string; conversationId?: string } | null = null;

  const response = await handleChat({
    method: 'POST',
    headers: {
      'x-client-id': 'client-2',
      'x-request-id': REQUEST_ID
    },
    body: {
      message: 'hello',
      conversation_id: 'conv-track-1'
    }
  }, {
    chatService: {
      async generateReply(request) {
        captured = {
          clientId: request.clientId,
          conversationId: request.conversationId
        };
        return {
          requestId: request.requestId,
          conversationId: request.conversationId ?? 'conv-generated',
          reply: {
            id: 'cmpl-track-1',
            role: 'assistant',
            content: 'tracked'
          }
        };
      }
    }
  });

  assert.equal(response.status, 200);
  assert.deepEqual(captured, {
    clientId: 'client-2',
    conversationId: 'conv-track-1'
  });
  assert.equal((response.body as { conversation_id: string }).conversation_id, 'conv-track-1');
});
