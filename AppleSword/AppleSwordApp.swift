import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(_ notification: Notification) {
        print("[App] Application will terminate, stopping engine...")
        EngineManager.shared.stop()
    }
}

@main
struct AppleSwordApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var taskStore = TaskStore()
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(taskStore)
                .environmentObject(settingsStore)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
                .onWindow { window in
                    guard let window = window else { return }
                    window.titlebarAppearsTransparent = true
                    window.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)
                    window.isOpaque = false
                    window.backgroundColor = .clear
                    // Ensure the toolbar/titlebar buttons are still usable but blend in
                }
        }
        .windowToolbarStyle(.unified)
        .commands {
            SidebarCommands()
        }

        Settings {
            SettingsView()
                .environmentObject(settingsStore)
        }

        AppleSwordMenuBar(taskStore: taskStore)
    }

    private func handleIncomingURL(_ url: URL) {
        let urlString = url.absoluteString
        var downloadURL: String = ""

        if url.isFileURL && url.pathExtension.lowercased() == "torrent" {
            taskStore.addTorrent(at: url.path)
            return
        }

        if urlString.hasPrefix("applesword://") {
            downloadURL = urlString.replacingOccurrences(of: "applesword://", with: "")
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                let queryItem = components.queryItems?.first(where: { $0.name == "url" })
            {
                downloadURL = queryItem.value ?? downloadURL
            }
        } else if urlString.hasPrefix("magnet:") || urlString.hasPrefix("thunder:") {
            downloadURL = urlString
        }

        if !downloadURL.isEmpty {
            taskStore.addUri([downloadURL])
        }
    }
}

struct WindowAccessor: NSViewRepresentable {
    let callback: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func onWindow(callback: @escaping (NSWindow?) -> Void) -> some View {
        background(WindowAccessor(callback: callback))
    }
}
