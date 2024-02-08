import ComposableArchitecture

@Reducer
struct SyncUpDetail {
  @ObservableState
  struct State {
    @Presents var editSyncUp: SyncUpForm.State?
    @Shared var syncUp: SyncUp
  }

  enum Action {
    case deleteButtonTapped
    case editButtonTapped
    case editSyncUp(PresentationAction<SycnUpForm.Action>)
    case startMeetingButtonTapped
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .deleteButtonTapped:
        return .none

      case .editButtonTapped:
        return .none

      case .startMeetingButtonTapped:
        return .none
      }
    }
  }
}

struct SyncUpDetailView: View {
  // ...
}
