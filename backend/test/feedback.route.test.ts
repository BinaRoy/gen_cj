import assert from 'node:assert/strict';
import test from 'node:test';

import { handleFeedback } from '../src/routes/feedback.ts';

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

test('POST /v1/feedback reuses x-request-id for traceability', () => {
  const result = handleFeedback({
    method: 'POST',
    headers: {
      'x-client-id': 'client-feedback-1',
      'x-request-id': 'req-feedback-123'
    },
    body: {
      message_id: 'msg-1',
      rating: 5,
      comment: 'helpful'
    }
  });

  assert.equal(result.status, 200);
  assert.equal((result.body as { accepted: boolean }).accepted, true);
  assert.equal((result.body as { request_id: string }).request_id, 'req-feedback-123');
});

test('POST /v1/feedback keeps normalized error shape', () => {
  const result = handleFeedback({
    method: 'POST',
    headers: { 'x-client-id': 'client-feedback-2' },
    body: { message_id: '', rating: 5 }
  });

  assert.equal(result.status, 400);
  assert.equal(hasNormalizedErrorShape(result.body), true);
  assert.equal((result.body as { code: string }).code, 'invalid_request');
});
