package ohos_app_cangjie_entry

import std.collection.ArrayList

private struct StoredMessage {
    public var conversationId: String
    public var role: String
    public var content: String

    public init(conversationId!: String, role!: String, content!: String) {
        this.conversationId = conversationId
        this.role = role
        this.content = content
    }
}

public interface LocalPersistenceBackend {
    func appendMessage(conversationId: String, role: String, content: String): Unit
    func loadMessages(conversationId: String): ArrayList<ChatMessage>
    func listConversationIds(): ArrayList<String>
    func loadLastPreview(conversationId: String): String
}

public class InMemoryPersistenceBackend <: LocalPersistenceBackend {
    private let messageLog = ArrayList<StoredMessage>()
    private let conversationOrder = ArrayList<String>()

    public init() {}

    public func appendMessage(conversationId: String, role: String, content: String): Unit {
        this.ensureConversationExists(conversationId)
        this.messageLog.add(StoredMessage(conversationId: conversationId, role: role, content: content))
    }

    public func loadMessages(conversationId: String): ArrayList<ChatMessage> {
        let messages = ArrayList<ChatMessage>()
        for (stored in this.messageLog) {
            if (stored.conversationId == conversationId) {
                messages.add(ChatMessage(role: stored.role, content: stored.content))
            }
        }
        return messages
    }

    public func listConversationIds(): ArrayList<String> {
        let result = ArrayList<String>()
        for (conversationId in this.conversationOrder) {
            result.add(conversationId)
        }
        return result
    }

    public func loadLastPreview(conversationId: String): String {
        var preview = ""
        for (stored in this.messageLog) {
            if (stored.conversationId == conversationId) {
                preview = "${stored.role}: ${stored.content}"
            }
        }
        return preview
    }

    private func ensureConversationExists(conversationId: String): Unit {
        var exists = false
        for (id in this.conversationOrder) {
            if (id == conversationId) {
                exists = true
            }
        }

        if (!exists) {
            this.conversationOrder.add(conversationId)
        }
    }
}

public class LocalStore {
    private let backend: LocalPersistenceBackend

    public init() {
        this.backend = InMemoryPersistenceBackend()
    }

    public init(backend!: LocalPersistenceBackend) {
        this.backend = backend
    }

    public func appendMessage(conversationId: String, role: String, content: String): Unit {
        this.backend.appendMessage(conversationId, role, content)
    }

    public func loadMessages(conversationId: String): ArrayList<ChatMessage> {
        return this.backend.loadMessages(conversationId)
    }

    public func listConversationIds(): ArrayList<String> {
        return this.backend.listConversationIds()
    }

    public func loadLastPreview(conversationId: String): String {
        return this.backend.loadLastPreview(conversationId)
    }
}
