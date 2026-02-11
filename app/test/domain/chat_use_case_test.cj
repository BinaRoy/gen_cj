package gen_cangjie_app_task5

import std.unittest.testmacro.Test
import std.unittest.testmacro.TestCase
import std.unittest.testmacro.Expect

class RecordingTransport <: HttpTransport {
    var lastRequest: ApiRequest = ApiRequest(endpoint: "", method: "", body: "", clientId: "")
    let plannedResponse: ApiResponse

    public init(plannedResponse!: ApiResponse) {
        this.plannedResponse = plannedResponse
    }

    public func execute(request: ApiRequest): ApiResponse {
        this.lastRequest = request
        return this.plannedResponse
    }
}

@Test
class ChatUseCaseTest {
    @TestCase
    func buildRequestForPostChat(): Unit {
        let transport = RecordingTransport(plannedResponse: ApiResponse(
            statusCode: 200,
            requestId: "req1",
            conversationId: "conv1",
            role: "assistant",
            content: "ok",
            message: ""
        ))
        let apiClient = ApiClient(baseUrl: "https://api.example.dev", transport: transport)
        let useCase = ChatUseCase(apiClient: apiClient)

        _ = useCase.sendMessage("client-1", "conv-1", "hello")

        @Expect(transport.lastRequest.method, "POST")
        @Expect(transport.lastRequest.endpoint, "/v1/chat")
        @Expect(transport.lastRequest.clientId, "client-1")
        @Expect(transport.lastRequest.body.contains("message=hello"))
        @Expect(transport.lastRequest.body.contains("conversation_id=conv-1"))
    }

    @TestCase
    func mapSuccessResponseToDomain(): Unit {
        let transport = RecordingTransport(plannedResponse: ApiResponse(
            statusCode: 200,
            requestId: "req2",
            conversationId: "conv-2",
            role: "assistant",
            content: "hello_back",
            message: ""
        ))
        let apiClient = ApiClient(baseUrl: "https://api.example.dev", transport: transport)
        let useCase = ChatUseCase(apiClient: apiClient)

        let result = useCase.sendMessage("client-2", "conv-2", "hello")

        @Expect(result.requestId, "req2")
        @Expect(result.conversationId, "conv-2")
        @Expect(result.reply.role, "assistant")
        @Expect(result.reply.content, "hello_back")
        @Expect(result.errorCategory.toString(), "none")
    }

    @TestCase
    func mapRateLimitToDomainErrorCategory(): Unit {
        let transport = RecordingTransport(plannedResponse: ApiResponse(
            statusCode: 429,
            requestId: "req3",
            conversationId: "conv-3",
            role: "assistant",
            content: "",
            message: "rate_limit"
        ))
        let apiClient = ApiClient(baseUrl: "https://api.example.dev", transport: transport)
        let useCase = ChatUseCase(apiClient: apiClient)

        let result = useCase.sendMessage("client-3", "conv-3", "hello")
        @Expect(result.errorCategory.toString(), "rateLimitError")
    }

    @TestCase
    func mapNetworkFailureToDomainErrorCategory(): Unit {
        let transport = RecordingTransport(plannedResponse: ApiResponse(
            statusCode: 0,
            requestId: "req4",
            conversationId: "conv-4",
            role: "assistant",
            content: "",
            message: "network_down"
        ))
        let apiClient = ApiClient(baseUrl: "https://api.example.dev", transport: transport)
        let useCase = ChatUseCase(apiClient: apiClient)

        let result = useCase.sendMessage("client-4", "conv-4", "hello")
        @Expect(result.errorCategory.toString(), "networkError")
    }
}
