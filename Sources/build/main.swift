import Dependencies
import Foundation
import ShellClient

try run()

func run() throws {
  @Dependency(\.shellClient) var shellClient
  
  try withVersion(in: "Sources/dots/Version.swift", as: currentVersion()) {
    try shellClient.foregroundShell(
      "swift", "build",
      "--disable-sandbox",
      "--configuration", "release",
      "-Xswiftc", "-cross-module-optimization"
    )
  }
  
  func withVersion(in file: String, as version: String, _ closure: () throws -> ()) throws {
    let fileURL = URL(fileURLWithPath: file)
    let originalFileContents = try String(contentsOf: fileURL, encoding: .utf8)
    // set version
    try originalFileContents
      .replacingOccurrences(of: "nil", with: "\"\(version)\"")
      .write(to: fileURL, atomically: true, encoding: .utf8)
    defer {
      // undo set version
      try! originalFileContents
        .write(to: fileURL, atomically: true, encoding: .utf8)
    }
    // run closure
    try closure()
  }

  func currentVersion() throws -> String {
    do {
      let tag = try shellClient.backgroundShell("git", "describe", "--tags", "--exact-match")
      return tag
    } catch {
      let branch = try shellClient.backgroundShell("git", "symbolic-ref", "-q", "--short", "HEAD")
      let commit = try shellClient.backgroundShell("git", "rev-parse", "--short", "HEAD")
      return "\(branch) (\(commit))"
    }
  }
}
