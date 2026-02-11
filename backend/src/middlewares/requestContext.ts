import { createRequestId, getHeader, type RouteRequest } from '../schemas/common.ts';

export interface RequestContext {
  requestId: string;
}

export function createRequestContext(request: RouteRequest): RequestContext {
  const requestIdFromHeader = getHeader(request.headers, 'x-request-id');

  if (requestIdFromHeader && requestIdFromHeader.trim().length > 0) {
    return {
      requestId: requestIdFromHeader
    };
  }

  return {
    requestId: createRequestId()
  };
}
