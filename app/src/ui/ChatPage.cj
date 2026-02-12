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
    private let messages: ArrayList<ChatMessage>

    public init(clientId!: String, conversationId!: String, gateway!: ChatGateway, store!: LocalStore) {
        this.clientId = clientId
        this.conversationId = conversationId
        this.gateway = gateway
        this.store = store
        this.messages = this.store.loadMessages(conversationId)
    }

    public func sendMessage(userInput: String): ChatResult {
        let userMessage = ChatMessage(role: "user", content: userInput)
        this.messages.add(userMessage)
        this.store.appendMessage(this.conversationId, userMessage.role, userMessage.content)

        let result = this.gateway.sendMessage(this.clientId, this.conversationId, userInput)
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
}
