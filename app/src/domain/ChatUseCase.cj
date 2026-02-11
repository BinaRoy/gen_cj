package gen_cangjie_app_task5

public class ChatUseCase {
    private let apiClient: ApiClient

    public init(apiClient!: ApiClient) {
        this.apiClient = apiClient
    }

    public func sendMessage(clientId: String, conversationId: String, message: String): ChatResult {
        let response = this.apiClient.postChat(clientId, conversationId, message)
        let category = mapErrorCategory(response.statusCode)

        return ChatResult(
            requestId: response.requestId,
            conversationId: response.conversationId,
            reply: ChatMessage(role: response.role, content: response.content),
            errorCategory: category
        )
    }
}

private func mapErrorCategory(statusCode: Int64): ChatErrorCategory {
    if (statusCode == 200) {
        return ChatErrorCategory.none
    }

    if (statusCode == 0) {
        return ChatErrorCategory.networkError
    }

    if (statusCode == 429) {
        return ChatErrorCategory.rateLimitError
    }

    if (statusCode >= 500) {
        return ChatErrorCategory.serverError
    }

    return ChatErrorCategory.unknownError
}
