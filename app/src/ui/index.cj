package ohos_app_cangjie_entry

internal import ohos.arkui.component.*
internal import ohos.arkui.state_management.*
import ohos.arkui.state_macro_manage.*

class DemoGateway <: ChatGateway {
    public func sendMessage(clientId: String, conversationId: String, message: String): ChatResult {
        return ChatResult(
            requestId: "req-demo-1",
            conversationId: conversationId,
            reply: ChatMessage(role: "assistant", content: "Echo: ${message}"),
            errorCategory: ChatErrorCategory.none
        )
    }
}

@Entry
@Component
class EntryView {
    @State var inputText: String = ""
    @State var transcript: String = ""

    private let page = ChatPage(
        clientId: "dev-client",
        conversationId: "conv-1",
        gateway: DemoGateway(),
        store: LocalStore()
    )

    func build() {
        Column(space: 12) {
            Text("GenCJ Chat").fontSize(24)

            TextInput(text: this.inputText)
                .onChange({ text =>
                    this.inputText = text
                })
                .width(90.percent)

            Button("发送")
                .onClick({ _ =>
                    _ = this.page.sendMessage(this.inputText)
                    this.transcript = this.page.renderTranscript()
                    this.inputText = ""
                })

            Text(this.transcript).width(90.percent)
        }
        .width(100.percent)
        .padding(16)
    }
}
