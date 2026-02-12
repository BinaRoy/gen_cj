package gen_cangjie_app_task5

public struct FeedbackResult {
    public var requestId: String
    public var accepted: Bool
    public var errorCategory: ChatErrorCategory
    public var message: String

    public init(requestId!: String, accepted!: Bool, errorCategory!: ChatErrorCategory, message!: String) {
        this.requestId = requestId
        this.accepted = accepted
        this.errorCategory = errorCategory
        this.message = message
    }
}

public interface FeedbackUseCase {
    func submitFeedback(clientId: String, messageId: String, rating: Int64, comment: String): FeedbackResult
}

public class NoopFeedbackUseCase <: FeedbackUseCase {
    public init() {}

    public func submitFeedback(clientId: String, messageId: String, rating: Int64, comment: String): FeedbackResult {
        let noopRequestId = "noop-${clientId}-${messageId}-${rating}-${comment.size}"
        return FeedbackResult(
            requestId: noopRequestId,
            accepted: true,
            errorCategory: ChatErrorCategory.none,
            message: "accepted"
        )
    }
}

public class ChatUseCase {
    private let apiClient: ApiClient
    private let feedbackUseCase: FeedbackUseCase

    public init(apiClient!: ApiClient) {
        this.apiClient = apiClient
        this.feedbackUseCase = NoopFeedbackUseCase()
    }

    public init(apiClient!: ApiClient, feedbackUseCase!: FeedbackUseCase) {
        this.apiClient = apiClient
        this.feedbackUseCase = feedbackUseCase
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

    public func submitFeedback(clientId: String, messageId: String, rating: Int64, comment: String): FeedbackResult {
        if (rating < 1 || rating > 5) {
            return FeedbackResult(
                requestId: "",
                accepted: false,
                errorCategory: ChatErrorCategory.unknownError,
                message: "rating must be between 1 and 5"
            )
        }

        return this.feedbackUseCase.submitFeedback(clientId, messageId, rating, comment)
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
