package gen_cangjie_app_task5

public interface HttpTransport {
    func execute(request: ApiRequest): ApiResponse
}

public class ApiClient {
    private let baseUrl: String
    private let transport: HttpTransport

    public init(baseUrl!: String, transport!: HttpTransport) {
        this.baseUrl = baseUrl
        this.transport = transport
    }

    public func buildChatRequest(clientId: String, conversationId: String, message: String): ApiRequest {
        let payload = "{\"message\":\"${message}\",\"conversation_id\":\"${conversationId}\"}"
        return ApiRequest(endpoint: "${this.baseUrl}/v1/chat", method: "POST", body: payload, clientId: clientId)
    }

    public func postChat(clientId: String, conversationId: String, message: String): ApiResponse {
        let request = this.buildChatRequest(clientId, conversationId, message)
        return this.transport.execute(request)
    }
}
