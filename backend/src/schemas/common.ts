import { randomUUID } from 'node:crypto';

export type HeaderMap = Record<string, string | undefined>;
export type QueryMap = Record<string, string | undefined>;

export interface RouteRequest {
  method: 'GET' | 'POST';
  headers?: HeaderMap;
  query?: QueryMap;
  body?: unknown;
}

export interface NormalizedErrorBody {
  code: string;
  message: string;
  request_id: string;
}

export interface RouteResult {
  status: number;
  body: Record<string, unknown> | NormalizedErrorBody;
}

export function createRequestId(): string {
  return randomUUID();
}

export function getHeader(headers: HeaderMap | undefined, name: string): string | undefined {
  if (!headers) {
    return undefined;
  }

  const needle = name.toLowerCase();
  for (const [key, value] of Object.entries(headers)) {
    if (key.toLowerCase() === needle) {
      return value;
    }
  }

  return undefined;
}

export function errorResult(status: number, code: string, message: string, requestId: string): RouteResult {
  return {
    status,
    body: {
      code,
      message,
      request_id: requestId
    }
  };
}

export function requireClientId(request: RouteRequest, requestId: string): RouteResult | null {
  const clientId = getHeader(request.headers, 'x-client-id');
  if (!clientId || clientId.trim().length === 0) {
    return errorResult(400, 'invalid_request', 'x-client-id header is required', requestId);
  }

  return null;
}
