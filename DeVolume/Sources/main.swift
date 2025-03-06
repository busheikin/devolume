import Cocoa

// Initialize the application
NSApplication.shared.setActivationPolicy(.regular)

// Create and set up the delegate
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate

// Start the application
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv) 