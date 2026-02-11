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
    let escaped = StringBuilder("")
    for (b in raw.toArray()) {
        let current = String.fromUtf8([b])
        if (current == "\\") {
            escaped.append("\\\\")
        } else if (current == "\"") {
            escaped.append("\\\"")
        } else if (current == "\n") {
            escaped.append("\\n")
        } else if (current == "\r") {
            escaped.append("\\r")
        } else if (current == "\t") {
            escaped.append("\\t")
        } else {
            escaped.append(current)
        }
    }
    return escaped.toString()
}
