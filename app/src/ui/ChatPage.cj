package gen_cangjie_app_task5

import std.collection.ArrayList

public interface ChatGateway {
    func sendMessage(clientId: String, conversationId: String, message: String): ChatResult
}

public class ChatUseCaseGateway <: ChatGateway {
    private let useCase: ChatUseCase

    public init(useCase!: ChatUseCase) {
        this.useCase = useCase
    }

    public func sendMessage(clientId: String, conversationId: String, message: String): ChatResult {
        return this.useCase.sendMessage(clientId, conversationId, message)
    }
}

public class ChatPage {
    private let clientId: String
    private let conversationId: String
    private let gateway: ChatGateway
    private let store: LocalStore
    private let feedbackUseCase: FeedbackUseCase
    private let debugMode: Bool
    private let messages: ArrayList<ChatMessage>
    private var lastChatRequestId: String = ""
    private var lastFeedbackRequestId: String = ""
    private var lastFeedbackStatus: String = "feedback_idle"

    public init(clientId!: String, conversationId!: String, gateway!: ChatGateway, store!: LocalStore) {
        this.clientId = clientId
        this.conversationId = conversationId
        this.gateway = gateway
        this.store = store
        this.feedbackUseCase = NoopFeedbackUseCase()
        this.debugMode = false
        this.messages = this.store.loadMessages(conversationId)
    }

    public init(clientId!: String, conversationId!: String, gateway!: ChatGateway, store!: LocalStore, feedbackUseCase!: FeedbackUseCase, debugMode!: Bool) {
        this.clientId = clientId
        this.conversationId = conversationId
        this.gateway = gateway
        this.store = store
        this.feedbackUseCase = feedbackUseCase
        this.debugMode = debugMode
        this.messages = this.store.loadMessages(conversationId)
    }

    public func sendMessage(userInput: String): ChatResult {
        let userMessage = ChatMessage(role: "user", content: userInput)
        this.messages.add(userMessage)
        this.store.appendMessage(this.conversationId, userMessage.role, userMessage.content)

        let result = this.gateway.sendMessage(this.clientId, this.conversationId, userInput)
        this.lastChatRequestId = result.requestId
        let assistantMessage = ChatMessage(role: result.reply.role, content: result.reply.content)
        this.messages.add(assistantMessage)
        this.store.appendMessage(this.conversationId, assistantMessage.role, assistantMessage.content)

        return result
    }

    public func renderTranscript(): String {
        let sb = StringBuilder()
        for (message in this.messages) {
            if (sb.size > 0) {
                sb.append("\n")
            }
            sb.append("${message.role}: ${message.content}")
        }
        return sb.toString()
    }

    public func renderedMessageCount(): Int64 {
        return Int64(this.messages.size)
    }

    public func submitLastAssistantFeedback(rating: Int64, comment: String): FeedbackResult {
        if (this.lastChatRequestId.size == 0) {
            this.lastFeedbackStatus = "feedback_failed"
            return FeedbackResult(
                requestId: "",
                accepted: false,
                errorCategory: ChatErrorCategory.unknownError,
                message: "no assistant message available for feedback"
            )
        }

        // TODO(task8+): replace lastChatRequestId with persisted assistant message_id
        // once message-level IDs are available from storage/sync layer.
        let result = this.feedbackUseCase.submitFeedback(this.clientId, this.lastChatRequestId, rating, comment)
        this.lastFeedbackRequestId = result.requestId
        this.lastFeedbackStatus = if (result.accepted) { "feedback_submitted" } else { "feedback_failed" }
        return result
    }

    public func renderFeedbackStatus(): String {
        return this.lastFeedbackStatus
    }

    public func renderDebugTrace(): String {
        if (!this.debugMode) {
            return ""
        }

        if (this.lastFeedbackRequestId.size > 0) {
            return "request_id: ${this.lastFeedbackRequestId}"
        }

        if (this.lastChatRequestId.size > 0) {
            return "request_id: ${this.lastChatRequestId}"
        }

        return ""
    }
}
