package ohos_app_cangjie_entry

public func createDefaultChatGateway(baseUrl: String, transport: HttpTransport): ChatGateway {
    let apiClient = ApiClient(baseUrl: baseUrl, transport: transport)
    let useCase = ChatUseCase(apiClient: apiClient)
    return ChatUseCaseGateway(useCase: useCase)
}
