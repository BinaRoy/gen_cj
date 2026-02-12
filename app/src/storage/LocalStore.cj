package gen_cangjie_app_task5

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

public class LocalStore {
    private static let messageLog = ArrayList<StoredMessage>()
    private static let conversationOrder = ArrayList<String>()

    public init() {}

    public func appendMessage(conversationId: String, role: String, content: String): Unit {
        this.ensureConversationExists(conversationId)
        LocalStore.messageLog.add(StoredMessage(conversationId: conversationId, role: role, content: content))
    }

    public func loadMessages(conversationId: String): ArrayList<ChatMessage> {
        let messages = ArrayList<ChatMessage>()
        for (stored in LocalStore.messageLog) {
            if (stored.conversationId == conversationId) {
                messages.add(ChatMessage(role: stored.role, content: stored.content))
            }
        }
        return messages
    }

    public func listConversationIds(): ArrayList<String> {
        let result = ArrayList<String>()
        for (conversationId in LocalStore.conversationOrder) {
            result.add(conversationId)
        }
        return result
    }

    public func loadLastPreview(conversationId: String): String {
        var preview = ""
        for (stored in LocalStore.messageLog) {
            if (stored.conversationId == conversationId) {
                preview = "${stored.role}: ${stored.content}"
            }
        }
        return preview
    }

    private func ensureConversationExists(conversationId: String): Unit {
        var exists = false
        for (id in LocalStore.conversationOrder) {
            if (id == conversationId) {
                exists = true
            }
        }

        if (!exists) {
            LocalStore.conversationOrder.add(conversationId)
        }
    }
}
