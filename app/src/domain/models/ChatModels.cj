package ohos_app_cangjie_entry

public enum ChatErrorCategory <: ToString {
    none | networkError | serverError | rateLimitError | unknownError

    public func toString(): String {
        return match (this) {
            case none => "none"
            case networkError => "networkError"
            case serverError => "serverError"
            case rateLimitError => "rateLimitError"
            case unknownError => "unknownError"
        }
    }

    public operator func ==(r: ChatErrorCategory): Bool {
        return this.toString() == r.toString()
    }
}

public struct ApiRequest {
    public var endpoint: String
    public var method: String
    public var body: String
    public var clientId: String

    public init(endpoint!: String, method!: String, body!: String, clientId!: String) {
        this.endpoint = endpoint
        this.method = method
        this.body = body
        this.clientId = clientId
    }
}

public struct ApiResponse {
    public var statusCode: Int64
    public var requestId: String
    public var conversationId: String
    public var role: String
    public var content: String
    public var message: String

    public init(statusCode!: Int64, requestId!: String, conversationId!: String, role!: String, content!: String, message!: String) {
        this.statusCode = statusCode
        this.requestId = requestId
        this.conversationId = conversationId
        this.role = role
        this.content = content
        this.message = message
    }
}

public struct ChatMessage {
    public var role: String
    public var content: String

    public init(role!: String, content!: String) {
        this.role = role
        this.content = content
    }
}

public struct ChatResult {
    public var requestId: String
    public var conversationId: String
    public var reply: ChatMessage
    public var errorCategory: ChatErrorCategory

    public init(requestId!: String, conversationId!: String, reply!: ChatMessage, errorCategory!: ChatErrorCategory) {
        this.requestId = requestId
        this.conversationId = conversationId
        this.reply = reply
        this.errorCategory = errorCategory
    }
}
