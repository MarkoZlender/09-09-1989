class_name Quest extends Resource

enum QuestState {
    NOT_STARTED,
    IN_PROGRESS,
    COMPLETED
}

@export var name: String
@export var quest_state: QuestState = QuestState.NOT_STARTED
