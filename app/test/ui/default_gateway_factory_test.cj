package ohos_app_cangjie_entry

import std.unittest.testmacro.Test
import std.unittest.testmacro.TestCase
import std.unittest.testmacro.Expect

class FactoryRecordingTransport <: HttpTransport {
    let plannedResponse: ApiResponse
    var lastRequest: ApiRequest = ApiRequest(endpoint: "", method: "", body: "", clientId: "")

    public init(plannedResponse!: ApiResponse) {
        this.plannedResponse = plannedResponse
    }

    public func execute(request: ApiRequest): ApiResponse {
        this.lastRequest = request
        return this.plannedResponse
    }
}

@Test
class DefaultGatewayFactoryTest {
    @TestCase
    func gatewayUsesApiClientTransportResponse(): Unit {
        let transport = FactoryRecordingTransport(plannedResponse: ApiResponse(
            statusCode: 200,
            requestId: "req-real-1",
            conversationId: "conv-real-1",
            role: "assistant",
            content: "from-real-transport",
            message: ""
        ))

        let gateway = createDefaultChatGateway("https://api.example.dev", transport)
        let result = gateway.sendMessage("client-real-1", "conv-real-1", "hello")

        @Expect(transport.lastRequest.endpoint, "https://api.example.dev/v1/chat")
        @Expect(result.reply.content, "from-real-transport")
        @Expect(result.errorCategory.toString(), "none")
    }
}
