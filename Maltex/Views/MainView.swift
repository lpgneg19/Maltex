import SwiftUI
import AppKit

struct MainView: View {
    @State private var selection: String? = "downloading"
    @State private var isShowingAddTask = false
    @State private var selectedTaskGids: Set<String> = []
    @State private var confirmGid: String? = nil
    @EnvironmentObject var taskStore: TaskStore
    @EnvironmentObject var settings: SettingsStore

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("下载状态") {
                    NavigationLink(value: "all") {
                        Label("所有任务", systemImage: "tray.2")
                    }
                    NavigationLink(value: "downloading") {
                        Label("正在下载", systemImage: "arrow.down.circle")
                    }
                    NavigationLink(value: "waiting") {
                        Label("等待下载", systemImage: "clock")
                    }
                    NavigationLink(value: "paused") {
                        Label("已暂停", systemImage: "pause.circle")
                    }
                    NavigationLink(value: "stopped") {
                        Label("已停止", systemImage: "stop.circle")
                    }
                    NavigationLink(value: "completed") {
                        Label("已完成", systemImage: "checkmark.circle")
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        } detail: {
            ZStack(alignment: .bottom) {
                if let selection = selection {
                    TaskListView(
                        status: selection,
                        selectedTaskGids: $selectedTaskGids,
                        isShowingAddTask: $isShowingAddTask
                    )
                } else {
                    ContentUnavailableView(
                        "请选择一个分类", systemImage: "sidebar.left")
                }

                // Bottom-up Task Details Popup
                if selectedTaskGids.count == 1,
                    let gid = selectedTaskGids.first,
                    let task = taskStore.tasks.first(where: { $0.gid == gid })
                {

                    TaskDetailView(task: task) {
                        withAnimation(.spring()) {
                            selectedTaskGids.removeAll()
                        }
                    }
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .zIndex(10)
                }
            }
        }
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea())
        .sheet(isPresented: $isShowingAddTask) {
            AddTaskView()
                .environmentObject(taskStore)
        }
        .sheet(
            item: Binding(
                get: { confirmGid.map { IdentifiableString(id: $0) } },
                set: { confirmGid = $0?.id }
            )
        ) { item in
            if let task = taskStore.tasks.first(where: { $0.gid == item.id }) {
                TorrentConfirmView(task: task) { path, selectedIndices in
                    var options = ["dir": path]
                    if !selectedIndices.isEmpty {
                        // Sort numerically: "1", "2", "10" -> 1, 2, 10
                        let sortedIndices = selectedIndices.compactMap { Int($0) }.sorted()
                        let indexString = sortedIndices.map { String($0) }.joined(separator: ",")
                        options["select-file"] = indexString
                    }
                    taskStore.resumeTask(gid: item.id, options: options)
                    confirmGid = nil
                } onCancel: {
                    taskStore.removeTasks(gids: [item.id])
                    confirmGid = nil
                }
                .environmentObject(taskStore)
                .environmentObject(settings)
            }
        }
        .dropDestination(for: URL.self) { items, location in
            let torrents = items.filter { $0.pathExtension.lowercased() == "torrent" }
            for torrent in torrents {
                taskStore.addTorrent(at: torrent.path)
            }
            return !torrents.isEmpty
        }
        .onChange(of: taskStore.lastAddedGid) {
            if let gid = taskStore.lastAddedGid {
                let task = taskStore.tasks.first(where: { $0.gid == gid })
                let isTorrent = task?.bittorrent != nil

                withAnimation(.spring()) {
                    if isTorrent && task?.status == .paused {
                        confirmGid = gid
                    } else {
                        selectedTaskGids = [gid]
                    }
                    taskStore.lastAddedGid = nil
                }
            }
        }
        .onChange(of: selection) {
            withAnimation(.spring()) {
                selectedTaskGids.removeAll()
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .alert("引擎错误", isPresented: Binding(
            get: { taskStore.lastError != nil },
            set: { if !$0 { taskStore.lastError = nil } }
        )) {
            Button("重试") {
                taskStore.lastError = nil
                EngineManager.shared.restart()
            }
            Button("取消", role: .cancel) {
                taskStore.lastError = nil
            }
        } message: {
            if let error = taskStore.lastError {
                Text(error)
            }
        }
    }
}

struct IdentifiableString: Identifiable {
    let id: String
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}
