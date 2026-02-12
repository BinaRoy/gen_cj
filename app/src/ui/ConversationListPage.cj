package gen_cangjie_app_task5

public class ConversationListPage {
    private let store: LocalStore

    public init(store!: LocalStore) {
        this.store = store
    }

    public func renderConversationList(): String {
        let ids = this.store.listConversationIds()
        let sb = StringBuilder()

        for (conversationId in ids) {
            if (sb.size > 0) {
                sb.append("\n")
            }
            let preview = this.store.loadLastPreview(conversationId)
            sb.append("${conversationId} | ${preview}")
        }

        return sb.toString()
    }
}
