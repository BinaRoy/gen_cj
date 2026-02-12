package gen_cangjie_app_task5

import std.unittest.testmacro.Test
import std.unittest.testmacro.TestCase
import std.unittest.testmacro.Expect

class EchoChatGateway <: ChatGateway {
    public func sendMessage(clientId: String, conversationId: String, message: String): ChatResult {
        return ChatResult(
            requestId: "req-${clientId}-${conversationId}",
            conversationId: conversationId,
            reply: ChatMessage(role: "assistant", content: "reply:${message}"),
            errorCategory: ChatErrorCategory.none
        )
    }
}

class AcceptFeedbackUseCase <: FeedbackUseCase {
    public func submitFeedback(clientId: String, messageId: String, rating: Int64, comment: String): FeedbackResult {
        let feedbackRequestId = "feedback-${clientId}-${messageId}-${rating}-${comment.size}"
        return FeedbackResult(
            requestId: feedbackRequestId,
            accepted: true,
            errorCategory: ChatErrorCategory.none,
            message: "ok"
        )
    }
}

@Test
class ChatPageSmokeTest {
    @TestCase
    func sendMessageRenderAssistantReply(): Unit {
        let store = LocalStore()
        let page = ChatPage(
            clientId: "client-task6-1",
            conversationId: "conv-task6-1",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )

        let result = page.sendMessage("hello")
        let rendered = page.renderTranscript()

        @Expect(result.reply.content, "reply:hello")
        @Expect(rendered.contains("user: hello"))
        @Expect(rendered.contains("assistant: reply:hello"))
        @Expect(page.renderedMessageCount(), Int64(2))
    }

    @TestCase
    func appRestartWithSharedBackendRestoresConversationHistory(): Unit {
        let backend = InMemoryPersistenceBackend()
        let firstStore = LocalStore(backend: backend)
        let firstPage = ChatPage(
            clientId: "client-task6-2",
            conversationId: "conv-task6-2",
            gateway: EchoChatGateway(),
            store: firstStore,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        _ = firstPage.sendMessage("persist me")

        let restartedStore = LocalStore(backend: backend)
        let restartedPage = ChatPage(
            clientId: "client-task6-2",
            conversationId: "conv-task6-2",
            gateway: EchoChatGateway(),
            store: restartedStore,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        let rendered = restartedPage.renderTranscript()

        @Expect(rendered.contains("user: persist me"))
        @Expect(rendered.contains("assistant: reply:persist me"))
        @Expect(restartedPage.renderedMessageCount(), Int64(2))
    }

    @TestCase
    func conversationListShowsSavedConversations(): Unit {
        let store = LocalStore()
        let pageA = ChatPage(
            clientId: "client-task6-3",
            conversationId: "conv-task6-a",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        _ = pageA.sendMessage("first")

        let pageB = ChatPage(
            clientId: "client-task6-3",
            conversationId: "conv-task6-b",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        _ = pageB.sendMessage("second")

        let listPage = ConversationListPage(store: store)
        let renderedList = listPage.renderConversationList()

        @Expect(renderedList.contains("conv-task6-a"))
        @Expect(renderedList.contains("assistant: reply:first"))
        @Expect(renderedList.contains("conv-task6-b"))
        @Expect(renderedList.contains("assistant: reply:second"))
    }

    @TestCase
    func submitFeedbackShowsConfirmationWithoutLeakingComment(): Unit {
        let store = LocalStore()
        let page = ChatPage(
            clientId: "client-task7-1",
            conversationId: "conv-task7-1",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        _ = page.sendMessage("hello feedback")

        let feedbackResult = page.submitLastAssistantFeedback(Int64(5), "private-comment")

        @Expect(feedbackResult.accepted)
        @Expect(page.renderFeedbackStatus(), "feedback_submitted")
        @Expect(!page.renderFeedbackStatus().contains("private-comment"))
    }

    @TestCase
    func debugModeShowsRequestIdOnlyWhenEnabled(): Unit {
        let store = LocalStore()
        let normalPage = ChatPage(
            clientId: "client-task7-2",
            conversationId: "conv-task7-2",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: false
        )
        _ = normalPage.sendMessage("normal")
        @Expect(normalPage.renderDebugTrace(), "")

        let debugPage = ChatPage(
            clientId: "client-task7-3",
            conversationId: "conv-task7-3",
            gateway: EchoChatGateway(),
            store: store,
            feedbackUseCase: AcceptFeedbackUseCase(),
            debugMode: true
        )
        _ = debugPage.sendMessage("debug")

        let trace = debugPage.renderDebugTrace()
        @Expect(trace.contains("request_id:"))
        @Expect(trace.contains("req-client-task7-3-conv-task7-3"))
    }
}
