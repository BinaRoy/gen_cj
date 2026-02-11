import assert from 'node:assert/strict';
import test from 'node:test';

import { handleChat } from '../src/routes/chat.ts';
import { handleConversations } from '../src/routes/conversations.ts';
import { handleMessages } from '../src/routes/messages.ts';
import { handleFeedback } from '../src/routes/feedback.ts';
import { createChatService } from '../src/services/chatService.ts';
import { createOpenAIClient } from '../src/services/openaiClient.ts';

function hasNormalizedErrorShape(body: unknown): body is { code: string; message: string; request_id: string } {
  if (!body || typeof body !== 'object') {
    return false;
  }

  const candidate = body as Record<string, unknown>;
  return typeof candidate.code === 'string'
    && typeof candidate.message === 'string'
    && typeof candidate.request_id === 'string'
    && candidate.request_id.length > 0;
}

test('POST /v1/chat returns 400 normalized error when message is missing', async () => {
  const result = await handleChat({
    method: 'POST',
    headers: { 'x-client-id': 'client-1' },
    body: {}
  });

  assert.equal(result.status, 400);
  assert.equal(hasNormalizedErrorShape(result.body), true);
  assert.equal((result.body as { code: string }).code, 'invalid_request');
});

test('POST /v1/chat returns 200 with success shape', async () => {
  const result = await handleChat({
    method: 'POST',
    headers: { 'x-client-id': 'client-1' },
    body: { message: 'hello' }
  }, {
    chatService: createChatService(createOpenAIClient(async () => ({
      id: 'cmpl-contract-1',
      choices: [
        {
          message: {
            role: 'assistant',
            content: 'contract response'
          }
        }
      ]
    })))
  });

  assert.equal(result.status, 200);
  assert.equal(typeof (result.body as Record<string, unknown>).request_id, 'string');
  assert.equal(typeof (result.body as Record<string, unknown>).conversation_id, 'string');
  assert.equal(typeof (result.body as Record<string, unknown>).reply, 'object');
});

test('GET /v1/conversations returns 200 with items array', () => {
  const result = handleConversations({
    method: 'GET',
    headers: { 'x-client-id': 'client-1' }
  });

  assert.equal(result.status, 200);
  assert.equal(Array.isArray((result.body as { items: unknown[] }).items), true);
  assert.equal(typeof (result.body as Record<string, unknown>).request_id, 'string');
});

test('GET /v1/messages returns 400 normalized error when conversation_id is missing', () => {
  const result = handleMessages({
    method: 'GET',
    headers: { 'x-client-id': 'client-1' },
    query: {}
  });

  assert.equal(result.status, 400);
  assert.equal(hasNormalizedErrorShape(result.body), true);
  assert.equal((result.body as { code: string }).code, 'invalid_request');
});

test('POST /v1/feedback returns 400 normalized error when rating is out of range', () => {
  const result = handleFeedback({
    method: 'POST',
    headers: { 'x-client-id': 'client-1' },
    body: { message_id: 'msg-1', rating: 9 }
  });

  assert.equal(result.status, 400);
  assert.equal(hasNormalizedErrorShape(result.body), true);
  assert.equal((result.body as { code: string }).code, 'invalid_request');
});

test('POST /v1/feedback returns 200 with accepted flag on valid payload', () => {
  const result = handleFeedback({
    method: 'POST',
    headers: { 'x-client-id': 'client-1' },
    body: { message_id: 'msg-1', rating: 5, comment: 'good' }
  });

  assert.equal(result.status, 200);
  assert.equal((result.body as { accepted: boolean }).accepted, true);
  assert.equal(typeof (result.body as Record<string, unknown>).request_id, 'string');
});
