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

@Test
class ChatPageSmokeTest {
    @TestCase
    func sendMessageRenderAssistantReply(): Unit {
        let store = LocalStore()
        let page = ChatPage(
            clientId: "client-task6-1",
            conversationId: "conv-task6-1",
            gateway: EchoChatGateway(),
            store: store
        )

        let result = page.sendMessage("hello")
        let rendered = page.renderTranscript()

        @Expect(result.reply.content, "reply:hello")
        @Expect(rendered.contains("user: hello"))
        @Expect(rendered.contains("assistant: reply:hello"))
        @Expect(page.renderedMessageCount(), Int64(2))
    }

    @TestCase
    func appRestartRestoresConversationHistory(): Unit {
        let store = LocalStore()
        let firstPage = ChatPage(
            clientId: "client-task6-2",
            conversationId: "conv-task6-2",
            gateway: EchoChatGateway(),
            store: store
        )
        _ = firstPage.sendMessage("persist me")

        let restartedPage = ChatPage(
            clientId: "client-task6-2",
            conversationId: "conv-task6-2",
            gateway: EchoChatGateway(),
            store: store
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
            store: store
        )
        _ = pageA.sendMessage("first")

        let pageB = ChatPage(
            clientId: "client-task6-3",
            conversationId: "conv-task6-b",
            gateway: EchoChatGateway(),
            store: store
        )
        _ = pageB.sendMessage("second")

        let listPage = ConversationListPage(store: store)
        let renderedList = listPage.renderConversationList()

        @Expect(renderedList.contains("conv-task6-a"))
        @Expect(renderedList.contains("assistant: reply:first"))
        @Expect(renderedList.contains("conv-task6-b"))
        @Expect(renderedList.contains("assistant: reply:second"))
    }
}
