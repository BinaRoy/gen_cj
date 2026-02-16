package ohos_app_cangjie_entry

let entryViewDefaultBaseUrl = "https://api.example.dev"

public func createDefaultChatGateway(baseUrl: String, transport: HttpTransport): ChatGateway {
    let apiClient = ApiClient(baseUrl: baseUrl, transport: transport)
    let useCase = ChatUseCase(apiClient: apiClient)
    return ChatUseCaseGateway(useCase: useCase)
}

public func createEntryViewDefaultGateway(transport: HttpTransport): ChatGateway {
    return createDefaultChatGateway(entryViewDefaultBaseUrl, transport)
}
