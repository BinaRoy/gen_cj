import assert from 'node:assert/strict';
import test from 'node:test';

import { createConversationRepo } from '../src/repos/conversationRepo.ts';
import { createMessageRepo } from '../src/repos/messageRepo.ts';
import { createChatService } from '../src/services/chatService.ts';
import { createOpenAIClient } from '../src/services/openaiClient.ts';
import { handleConversations } from '../src/routes/conversations.ts';
import { handleMessages } from '../src/routes/messages.ts';

test('persistence: create conversation and list by client', () => {
  const conversationRepo = createConversationRepo();

  conversationRepo.createConversation({
    id: 'conv-1',
    clientId: 'client-1',
    title: 'first'
  });

  const result = handleConversations({
    method: 'GET',
    headers: { 'x-client-id': 'client-1' }
  }, {
    conversationRepo
  });

  assert.equal(result.status, 200);
  const body = result.body as { items: Array<{ id: string }> };
  assert.equal(body.items.length, 1);
  assert.equal(body.items[0].id, 'conv-1');
});

test('persistence: chat service appends user and assistant messages', async () => {
  const conversationRepo = createConversationRepo();
  const messageRepo = createMessageRepo();
  const openAIClient = createOpenAIClient(async () => ({
    id: 'cmpl-p1',
    choices: [{ message: { role: 'assistant', content: 'ack' } }]
  }));

  conversationRepo.createConversation({
    id: 'conv-2',
    clientId: 'client-1',
    title: 'chat'
  });

  const chatService = createChatService(openAIClient, {
    conversationRepo,
    messageRepo
  });

  await chatService.generateReply({
    message: 'hello',
    requestId: 'req-1',
    clientId: 'client-1',
    conversationId: 'conv-2'
  });

  const listed = messageRepo.listMessages('conv-2', 20);
  assert.equal(listed.items.length, 2);
  assert.equal(listed.items[0].role, 'user');
  assert.equal(listed.items[1].role, 'assistant');
});

test('persistence: messages route supports pagination cursor', async () => {
  const conversationRepo = createConversationRepo();
  const messageRepo = createMessageRepo();
  const openAIClient = createOpenAIClient(async () => ({
    id: 'cmpl-p2',
    choices: [{ message: { role: 'assistant', content: 'ok' } }]
  }));

  conversationRepo.createConversation({
    id: 'conv-3',
    clientId: 'client-1',
    title: 'paging'
  });

  const chatService = createChatService(openAIClient, {
    conversationRepo,
    messageRepo
  });

  await chatService.generateReply({
    message: 'm1',
    requestId: 'req-p1',
    clientId: 'client-1',
    conversationId: 'conv-3'
  });

  await chatService.generateReply({
    message: 'm2',
    requestId: 'req-p2',
    clientId: 'client-1',
    conversationId: 'conv-3'
  });

  const page1 = handleMessages({
    method: 'GET',
    headers: { 'x-client-id': 'client-1' },
    query: {
      conversation_id: 'conv-3',
      limit: '2'
    }
  }, {
    messageRepo
  });

  assert.equal(page1.status, 200);
  const page1Body = page1.body as { items: Array<{ id: string }>; next_cursor: string | null };
  assert.equal(page1Body.items.length, 2);
  assert.equal(typeof page1Body.next_cursor, 'string');

  const page2 = handleMessages({
    method: 'GET',
    headers: { 'x-client-id': 'client-1' },
    query: {
      conversation_id: 'conv-3',
      limit: '2',
      cursor: page1Body.next_cursor ?? undefined
    }
  }, {
    messageRepo
  });

  assert.equal(page2.status, 200);
  const page2Body = page2.body as { items: Array<{ id: string }> };
  assert.equal(page2Body.items.length, 2);
});

test('persistence: independent repo instances do not share in-memory state', () => {
  const conversationRepoA = createConversationRepo();
  const conversationRepoB = createConversationRepo();
  const messageRepoA = createMessageRepo();
  const messageRepoB = createMessageRepo();

  conversationRepoA.createConversation({
    id: 'conv-isolated',
    clientId: 'client-iso',
    title: 'isolated'
  });
  messageRepoA.appendMessage({
    id: 'msg-isolated',
    conversationId: 'conv-isolated',
    role: 'user',
    content: 'hello'
  });

  const fromRepoBConversations = conversationRepoB.listConversationsByClient('client-iso', 20);
  const fromRepoBMessages = messageRepoB.listMessages('conv-isolated', 20);

  assert.equal(fromRepoBConversations.items.length, 0);
  assert.equal(fromRepoBMessages.items.length, 0);
});
