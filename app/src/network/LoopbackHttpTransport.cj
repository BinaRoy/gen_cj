package ohos_app_cangjie_entry

public class LoopbackHttpTransport <: HttpTransport {
    public init() {}

    public func execute(request: ApiRequest): ApiResponse {
        return ApiResponse(
            statusCode: 200,
            requestId: "req-live-${request.clientId}",
            conversationId: "",
            role: "assistant",
            content: "transport-live-reply",
            message: ""
        )
    }
}
