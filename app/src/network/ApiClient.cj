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
        let escapedMessage = escapeJsonString(message)
        let escapedConversationId = escapeJsonString(conversationId)
        let payload = "{\"message\":\"${escapedMessage}\",\"conversation_id\":\"${escapedConversationId}\"}"
        return ApiRequest(endpoint: "${this.baseUrl}/v1/chat", method: "POST", body: payload, clientId: clientId)
    }

    public func postChat(clientId: String, conversationId: String, message: String): ApiResponse {
        let request = this.buildChatRequest(clientId, conversationId, message)
        return this.transport.execute(request)
    }
}

private func escapeJsonString(raw: String): String {
    let step1 = raw.replace("\\", "\\\\")
    let step2 = step1.replace("\"", "\\\"")
    let step3 = step2.replace("\n", "\\n")
    let step4 = step3.replace("\r", "\\r")
    return step4.replace("\t", "\\t")
}
