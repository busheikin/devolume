import Cocoa
import DiskArbitration

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var volumesController: VolumesViewController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the main window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "Volume Process Manager"
        
        // Create and set the volumes view controller
        volumesController = VolumesViewController()
        window.contentViewController = volumesController
        
        window.makeKeyAndOrderFront(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

class VolumesViewController: NSViewController {
    private var volumesTableView: NSTableView!
    private var volumes: [Volume] = []
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 300))
        setupUI()
        loadVolumes()
    }
    
    private func setupUI() {
        // Title label
        let titleLabel = NSTextField(labelWithString: "Select a Volume")
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Create scroll view and table view
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        view.addSubview(scrollView)
        
        volumesTableView = NSTableView()
        volumesTableView.delegate = self
        volumesTableView.dataSource = self
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("VolumeColumn"))
        column.title = "Mounted Volumes"
        column.width = 350
        volumesTableView.addTableColumn(column)
        
        scrollView.documentView = volumesTableView
        
        // Set constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadVolumes() {
        volumes = []
        
        let session = DASessionCreate(kCFAllocatorDefault)
        
        if let mountedVolumeURLs = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil, options: []) {
            for url in mountedVolumeURLs {
                if let volumeName = url.lastPathComponent as String?, volumeName != "/" {
                    let volume = Volume(name: volumeName, path: url.path)
                    volumes.append(volume)
                }
            }
        }
        
        volumesTableView.reloadData()
    }
}

extension VolumesViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return volumes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let volume = volumes[row]
        
        let cellIdentifier = NSUserInterfaceItemIdentifier("VolumeCell")
        var cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
        
        if cellView == nil {
            cellView = NSTableCellView()
            cellView?.identifier = cellIdentifier
            
            let textField = NSTextField(labelWithString: "")
            textField.translatesAutoresizingMaskIntoConstraints = false
            cellView?.addSubview(textField)
            cellView?.textField = textField
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cellView!.leadingAnchor, constant: 4),
                textField.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor),
                textField.trailingAnchor.constraint(equalTo: cellView!.trailingAnchor, constant: -4)
            ])
        }
        
        cellView?.textField?.stringValue = volume.name
        
        return cellView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = volumesTableView.selectedRow
        if selectedRow >= 0 {
            let selectedVolume = volumes[selectedRow]
            let processesVC = ProcessesViewController(volume: selectedVolume)
            self.presentAsSheet(processesVC)
        }
    }
}

class ProcessesViewController: NSViewController {
    private var volume: Volume
    private var processes: [ProcessInfo] = []
    private var tableView: NSTableView!
    private var checkboxes: [NSButton] = []
    
    init(volume: Volume) {
        self.volume = volume
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
        setupUI()
        loadProcesses()
    }
    
    private func setupUI() {
        // Title label
        let titleLabel = NSTextField(labelWithString: "Processes using \(volume.name)")
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Create scroll view and table view
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder
        view.addSubview(scrollView)
        
        tableView = NSTableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let checkColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("CheckColumn"))
        checkColumn.title = ""
        checkColumn.width = 30
        tableView.addTableColumn(checkColumn)
        
        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("NameColumn"))
        nameColumn.title = "Process Name"
        nameColumn.width = 200
        tableView.addTableColumn(nameColumn)
        
        let pidColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("PIDColumn"))
        pidColumn.title = "PID"
        pidColumn.width = 80
        tableView.addTableColumn(pidColumn)
        
        scrollView.documentView = tableView
        
        // Buttons
        let backButton = NSButton(title: "Back", target: self, action: #selector(backButtonClicked))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.bezelStyle = .rounded
        view.addSubview(backButton)
        
        let endProcessesButton = NSButton(title: "End Processes", target: self, action: #selector(endProcessesButtonClicked))
        endProcessesButton.translatesAutoresizingMaskIntoConstraints = false
        endProcessesButton.bezelStyle = .rounded
        endProcessesButton.contentTintColor = NSColor.systemRed
        view.addSubview(endProcessesButton)
        
        // Set constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            
            endProcessesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            endProcessesButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadProcesses() {
        processes = []
        
        // Run lsof command to find processes using the volume
        let task = Process()
        task.launchPath = "/usr/sbin/lsof"
        task.arguments = [volume.path]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: "\n")
                
                // Skip the header line
                for i in 1..<lines.count {
                    let line = lines[i]
                    let components = line.components(separatedBy: " ").filter { !$0.isEmpty }
                    
                    if components.count >= 2 {
                        let processName = components[0]
                        if let pid = Int(components[1]) {
                            // Check if we already have this process
                            if !processes.contains(where: { $0.pid == pid }) {
                                processes.append(ProcessInfo(name: processName, pid: pid, selected: true))
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error running lsof: \(error)")
        }
        
        tableView.reloadData()
    }
    
    @objc private func backButtonClicked() {
        dismiss(nil)
    }
    
    @objc private func endProcessesButtonClicked() {
        var successCount = 0
        var failCount = 0
        
        for (index, process) in processes.enumerated() {
            if process.selected {
                let task = Process()
                task.launchPath = "/bin/kill"
                task.arguments = ["-9", String(process.pid)]
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    
                    if task.terminationStatus == 0 {
                        successCount += 1
                    } else {
                        failCount += 1
                    }
                } catch {
                    failCount += 1
                }
            }
        }
        
        // Show results alert
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Process Termination Results"
        
        if failCount == 0 {
            alert.informativeText = "Successfully terminated \(successCount) processes."
        } else {
            alert.informativeText = "Successfully terminated \(successCount) processes.\nFailed to terminate \(failCount) processes."
        }
        
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!) { _ in
            self.loadProcesses()  // Refresh the process list
        }
    }
}

extension ProcessesViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return processes.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn = tableColumn else { return nil }
        let process = processes[row]
        
        if tableColumn.identifier.rawValue == "CheckColumn" {
            let cellIdentifier = NSUserInterfaceItemIdentifier("CheckboxCell")
            var cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            
            if cellView == nil {
                cellView = NSTableCellView()
                cellView?.identifier = cellIdentifier
                
                let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkboxClicked(_:)))
                checkbox.translatesAutoresizingMaskIntoConstraints = false
                cellView?.addSubview(checkbox)
                
                NSLayoutConstraint.activate([
                    checkbox.centerXAnchor.constraint(equalTo: cellView!.centerXAnchor),
                    checkbox.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor)
                ])
                
                // Store the checkbox for later access
                if checkboxes.count <= row {
                    checkboxes.append(checkbox)
                } else {
                    checkboxes[row] = checkbox
                }
            }
            
            let checkbox = cellView?.subviews.first as? NSButton
            checkbox?.state = process.selected ? .on : .off
            checkbox?.tag = row
            
            return cellView
        } else if tableColumn.identifier.rawValue == "NameColumn" {
            let cellIdentifier = NSUserInterfaceItemIdentifier("NameCell")
            var cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            
            if cellView == nil {
                cellView = NSTableCellView()
                cellView?.identifier = cellIdentifier
                
                let textField = NSTextField(labelWithString: "")
                textField.translatesAutoresizingMaskIntoConstraints = false
                cellView?.addSubview(textField)
                cellView?.textField = textField
                
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cellView!.leadingAnchor, constant: 4),
                    textField.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor),
                    textField.trailingAnchor.constraint(equalTo: cellView!.trailingAnchor, constant: -4)
                ])
            }
            
            cellView?.textField?.stringValue = process.name
            
            return cellView
        } else if tableColumn.identifier.rawValue == "PIDColumn" {
            let cellIdentifier = NSUserInterfaceItemIdentifier("PIDCell")
            var cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView
            
            if cellView == nil {
                cellView = NSTableCellView()
                cellView?.identifier = cellIdentifier
                
                let textField = NSTextField(labelWithString: "")
                textField.translatesAutoresizingMaskIntoConstraints = false
                cellView?.addSubview(textField)
                cellView?.textField = textField
                
                NSLayoutConstraint.activate([
                    textField.leadingAnchor.constraint(equalTo: cellView!.leadingAnchor, constant: 4),
                    textField.centerYAnchor.constraint(equalTo: cellView!.centerYAnchor),
                    textField.trailingAnchor.constraint(equalTo: cellView!.trailingAnchor, constant: -4)
                ])
            }
            
            cellView?.textField?.stringValue = String(process.pid)
            
            return cellView
        }
        
        return nil
    }
    
    @objc private func checkboxClicked(_ sender: NSButton) {
        let row = sender.tag
        processes[row].selected = (sender.state == .on)
    }
}

// Data models
struct Volume {
    let name: String
    let path: String
}

struct ProcessInfo {
    let name: String
    let pid: Int
    var selected: Bool
}

// Main entry point
@main
struct VolumeProcessManagerApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.run()
    }
}
