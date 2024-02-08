import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    var syncUpsList = SyncUpsList.State()
  }

  enum Action {
    case path(StackAction<Path.State, Path.Action>)
    case syncUpsList(SyncUpsList.Action)
  }

  @Dependency(\.date.now) var now
  @Dependency(\.uuid) var uuid

  private enum CancelID {
    case saveDebounce
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.syncUpsList, action: \.syncUpsList) {
      SyncUpsList()
    }
    Reduce<State, Action> { state, action in
      switch action {
      case let .path(.element(id, .detail(.delegate(delegateAction)))):
        guard case let .some(.detail(detailState)) = state.path[id: id]
        else { return .none }

        switch delegateAction {
        case .startMeeting:
          state.path.append(.record(RecordMeeting.State(syncUp: detailState.$syncUp)))
          return .none
        }

      case .path:
        return .none

      case .syncUpsList:
        return .none
      }
    }
    .forEach(\.path, action: \.path) {
      Path()
    }
  }

  @Reducer
  struct Path {
    @ObservableState
    enum State: Equatable {
      case detail(SyncUpDetail.State)
      case meeting(Meeting, syncUp: SyncUp)
      case record(RecordMeeting.State)
    }

    enum Action {
      case detail(SyncUpDetail.Action)
      case record(RecordMeeting.Action)
    }

    var body: some Reducer<State, Action> {
      Scope(state: \.detail, action: \.detail) {
        SyncUpDetail()
      }
      Scope(state: \.record, action: \.record) {
        RecordMeeting()
      }
    }
  }
}

struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      SyncUpsListView(
        store: store.scope(state: \.syncUpsList, action: \.syncUpsList)
      )
    } destination: { store in
      switch store.state {
      case .detail:
        if let store = store.scope(state: \.detail, action: \.detail) {
          SyncUpDetailView(store: store)
        }
      case let .meeting(meeting, syncUp: syncUp):
        MeetingView(meeting: meeting, syncUp: syncUp)
      case .record:
        if let store = store.scope(state: \.record, action: \.record) {
          RecordMeetingView(store: store)
        }
      }
    }
  }
}

extension URL {
  static let syncUps = Self.documentsDirectory.appending(component: "sync-ups.json")
}

#Preview {
  let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
  // TODO: Why is this necessary in previews?
  store.syncUpsList.syncUps = [.mock, .designMock, .engineeringMock]
  return AppView(store: store)
}
