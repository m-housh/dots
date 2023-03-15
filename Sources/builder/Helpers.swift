import Dependencies
import Foundation
import ShellClient

#warning("Remove me.")
extension ShellClient {
  func currentVersion() throws -> String {
    do {
      let tag = try self.background(
        ["git", "describe", "--tags", "--exact-match"],
        trimmingCharactersIn: .whitespacesAndNewlines
      )
      return tag
    } catch {
      let branch = try self.background(
        ["git", "symbolic-ref", "-q", "--short", "HEAD"],
        trimmingCharactersIn: .whitespacesAndNewlines
      )
      let commit = try self.background(
        ["git", "rev-parse", "--short", "HEAD"],
        trimmingCharactersIn: .whitespacesAndNewlines
      )
      return "\(branch) (\(commit))"
    }
  }
}
