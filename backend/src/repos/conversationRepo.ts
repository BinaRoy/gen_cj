import { randomUUID } from 'node:crypto';

export interface ConversationRecord {
  id: string;
  clientId: string;
  title: string;
  createdAt: string;
  updatedAt: string;
}

export interface ConversationListResult {
  items: ConversationRecord[];
  nextCursor: string | null;
}

export interface ConversationRepo {
  createConversation(input: { id?: string; clientId: string; title?: string; now?: string }): ConversationRecord;
  getConversation(id: string): ConversationRecord | null;
  touchConversation(id: string, now?: string): void;
  listConversationsByClient(clientId: string, limit: number, cursor?: string): ConversationListResult;
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

function ensureClientOrder(orderMap: Map<string, string[]>, clientId: string): string[] {
  const existing = orderMap.get(clientId);
  if (existing) {
    return existing;
  }

  const next: string[] = [];
  orderMap.set(clientId, next);
  return next;
}

export function createConversationRepo(_deps?: { d1?: D1Database; kv?: KVNamespace }): ConversationRepo {
  const store = new Map<string, ConversationRecord>();
  const orderByClient = new Map<string, string[]>();

  return {
    createConversation(input: { id?: string; clientId: string; title?: string; now?: string }): ConversationRecord {
      const now = toIso(input.now);
      const record: ConversationRecord = {
        id: input.id ?? randomUUID(),
        clientId: input.clientId,
        title: input.title ?? 'Untitled',
        createdAt: now,
        updatedAt: now
      };

      store.set(record.id, record);
      const order = ensureClientOrder(orderByClient, record.clientId);
      order.unshift(record.id);
      return record;
    },

    getConversation(id: string): ConversationRecord | null {
      return store.get(id) ?? null;
    },

    touchConversation(id: string, now?: string): void {
      const record = store.get(id);
      if (!record) {
        return;
      }

      const nextUpdatedAt = toIso(now);
      store.set(id, {
        ...record,
        updatedAt: nextUpdatedAt
      });

      const order = ensureClientOrder(orderByClient, record.clientId);
      const index = order.indexOf(id);
      if (index >= 0) {
        order.splice(index, 1);
      }
      order.unshift(id);
    },

    listConversationsByClient(clientId: string, limit: number, cursor?: string): ConversationListResult {
      const offset = parseCursor(cursor);
      const safeLimit = Math.max(1, Math.min(limit, 100));
      const order = ensureClientOrder(orderByClient, clientId);
      const pageIds = order.slice(offset, offset + safeLimit);
      const items = pageIds
        .map((id) => store.get(id))
        .filter((record): record is ConversationRecord => !!record);
      const nextOffset = offset + items.length;

      return {
        items,
        nextCursor: nextOffset < order.length ? String(nextOffset) : null
      };
    }
  };
}
