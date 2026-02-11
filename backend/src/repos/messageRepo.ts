import { randomUUID } from 'node:crypto';

export interface MessageRecord {
  id: string;
  conversationId: string;
  role: 'user' | 'assistant';
  content: string;
  createdAt: string;
}

export interface MessageListResult {
  items: MessageRecord[];
  nextCursor: string | null;
}

export interface MessageRepo {
  appendMessage(input: { id?: string; conversationId: string; role: 'user' | 'assistant'; content: string; now?: string }): MessageRecord;
  listMessages(conversationId: string, limit: number, cursor?: string): MessageListResult;
}

export interface D1Database {
  exec(sql: string, params?: unknown[]): void;
}

export interface KVNamespace {
  get(key: string): string | null;
  put(key: string, value: string): void;
}

function toIso(now?: string): string {
  return now ?? new Date().toISOString();
}

function parseCursor(cursor: string | undefined): number {
  if (!cursor) {
    return 0;
  }

  const parsed = Number.parseInt(cursor, 10);
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : 0;
}

function getBucket(store: Map<string, MessageRecord[]>, conversationId: string): MessageRecord[] {
  const existing = store.get(conversationId);
  if (existing) {
    return existing;
  }

  const next: MessageRecord[] = [];
  store.set(conversationId, next);
  return next;
}

export function createMessageRepo(_deps?: { d1?: D1Database; kv?: KVNamespace }): MessageRepo {
  const store = new Map<string, MessageRecord[]>();

  return {
    appendMessage(input: { id?: string; conversationId: string; role: 'user' | 'assistant'; content: string; now?: string }): MessageRecord {
      const record: MessageRecord = {
        id: input.id ?? randomUUID(),
        conversationId: input.conversationId,
        role: input.role,
        content: input.content,
        createdAt: toIso(input.now)
      };

      getBucket(store, input.conversationId).push(record);
      return record;
    },

    listMessages(conversationId: string, limit: number, cursor?: string): MessageListResult {
      const offset = parseCursor(cursor);
      const safeLimit = Math.max(1, Math.min(limit, 100));
      const bucket = getBucket(store, conversationId);
      const items = bucket.slice(offset, offset + safeLimit);
      const nextOffset = offset + items.length;

      return {
        items,
        nextCursor: nextOffset < bucket.length ? String(nextOffset) : null
      };
    }
  };
}
