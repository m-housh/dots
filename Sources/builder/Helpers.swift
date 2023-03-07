import Dependencies
import Foundation
import ShellClient

extension ShellClient {
  func currentVersion() throws -> String {
    do {
      let tag = try self.backgroundShell("git", "describe", "--tags", "--exact-match")
      return tag
    } catch {
      let branch = try self.backgroundShell("git", "symbolic-ref", "-q", "--short", "HEAD")
      let commit = try self.backgroundShell("git", "rev-parse", "--short", "HEAD")
      return "\(branch) (\(commit))"
    }
  }
}
