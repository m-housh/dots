import ArgumentParser
import Dependencies
import FileClient
import Foundation
import ShellClient

extension Builder {
  struct Bottle: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
      commandName: "bottle",
      abstract: "Bottles the `dots` application."
    )
    
    @Flag
    var dryRun: Bool = false
    
    func run() async throws {
      try await BottleRunner(dryRun: dryRun).run()
    }
  }
}

fileprivate struct BottleRunner {
  @Dependency(\.fileClient) var fileClient: FileClient
  @Dependency(\.logger) var logger: Logger
  @Dependency(\.shellClient) var shellClient: ShellClient
  
  let dryRun: Bool
  
  private var branch: String { "dots-\(version)" }
  private var brew: String { "brew" }
  private var formula: String { "dots" }
  private var fullFormula: String { "\(tap)/\(formula)" }
  private var rootUrl: String { "https://github.com/m-housh/dots/releases/download/\(version)" }
  private var tap: String { "m-housh/formula" }
  private var version: String { VERSION }
  private var commitable: Bool {
    !dryRun && !(version.contains("main"))
  }
  
  func run() async throws {

    logger.info("Starting bottle process.")
    logger.info("""
      DryRun: \(dryRun)
      Version: \(version)
      Commitable: \(commitable)
    """)
    
    // Uninstall first, if we've already installed dots on this machine.
    uninstallFormula()
   
    logger.info("Tapping: \(tap)")
    
    // tap
    try shellClient.foreground(
      [brew, "tap", "\(tap)"]
    )
    
    // Update the formula for bottling.
    try await updateFormulaBeforeBottling()
    
    // install and prepair to bottle.
    logger.info("Installing: \(fullFormula)")
    try shellClient.foreground(
      [brew, "install", "--build-bottle", fullFormula]
    )
    
    // bottle
    let bottleOutput = try bottle()
    
    // Fix the bottle tarball name.
    logger.info("Fixing bottle tarball name.")
    let bottlePath = try updateBottleFilePath(fileName: bottleOutput.fileName)
    
    // Upload bottle to github release.
    try uploadBottleToRelease(fileName: bottlePath)
    defer { try? FileManager.default.trashItem(at: URL(fileURLWithPath: bottlePath), resultingItemURL: nil) }
    
    // Update the formula with the new bottle block.
    logger.info("Updating formula.")
    
    // Some bottles are generated in the ci/cd workflow and so those portions of
    // of the bottle do block needs to remain.
    try await updateFormulaAfterBottling(bottleBlock: bottleOutput.bottleBlock)
    
    // Check the formula does not contain formula syntax errors.
    try checkFormula()
    
    // Commit the updated formula.
    try commitFormulaRepository()
    
    // Create a branch with the new formula before creating a pull request.
    try createBranch()
    
    // Create a pull request for the formula repository.
    try createPullRequest()
    
  }
  
  // MARK: - Helpers
  
  private func uninstallFormula() {
    _ = try? shellClient.background(
      [brew, "uninstall", fullFormula],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
  }
  
  private func createBranch() throws {
    if commitable {
      logger.info("Creating new branch before bottling.")
      try shellClient.runInFormulaRepository(
        "git", "checkout", "-b", branch
      )
    }
  }
  
  private func updateFormulaBeforeBottling() async throws {
    let temporaryFormulaFileContents = fileTemplateWithoutBottleBlock(version: version)
    if dryRun {
      logger.info("Dry run called.")
      logger.info("\(temporaryFormulaFileContents)")
    } else {
      logger.info("Updating dots formula before bottling.")
      let dotsFormulaUrl = try shellClient.dotsFormulaUrl()
      try await fileClient.writeFile(
        string: temporaryFormulaFileContents,
        to: dotsFormulaUrl
      )
    }
  }
  
  private func bottle() throws -> ParsedOutput {
    let bottleContext = try shellClient.background(
      [brew, "bottle", "--root-url", rootUrl, fullFormula],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
    // print the bottling output to act like a foreground shell.
    logger.info("\(bottleContext)")
    
    return parseBottleOutput(from: bottleContext)
  }
 
  private func updateBottleFilePath(fileName: String) throws -> String {
    let sanitizedName = fileName.replacingOccurrences(of: "--", with: "-")
    try FileManager.default.moveItem(atPath: fileName, toPath: sanitizedName)
    return sanitizedName
  }
  
  private func uploadBottleToRelease(fileName: String) throws {
    if commitable {
      logger.info("Uploading bottle as a release asset.")
      try shellClient.foreground(
        ["gh", "release", "upload", version, fileName]
      )
    }
  }
  
  private func updateFormulaAfterBottling(bottleBlock: String) async throws {
    let updatedFileContents = fileTemplateWithBottleBlock(block: bottleBlock, version: version)
    if dryRun {
      logger.info("Dry run called, not writing new formula.")
      logger.info("\(updatedFileContents)")
    } else {
      logger.info("Updating formula after bottling.")
      let dotsFormulaUrl = try shellClient.dotsFormulaUrl()
      try await fileClient.writeFile(string: updatedFileContents, to: dotsFormulaUrl)
    }
  }
  
  private func checkFormula() throws {
    if commitable {
      logger.info("Checking new formula for syntax errors.")
      _ = try shellClient.background(
        [brew, "audit", "--strict", "--new-formula", "--online", fullFormula]
      )
      logger.info("Passed.")
    }
  }
  
  private func commitFormulaRepository() throws {
    if commitable {
      logger.info("Committing formula repository.")
      try shellClient.runInFormulaRepository(
        "git", "commit", "--all", "--message", "Dots v\(version)"
      )
    }
  }
  
  private func createPullRequest() throws {
    if commitable {
      logger.info("Creating pull request for the formula repository.")
      try shellClient.runInFormulaRepository(
        "gh", "pr", "create", "--fill", "--base", "main", "--repo", "m-housh/homebrew-formula"
      )
    }
  }
}

fileprivate struct ParsedOutput {
  let fileName: String
  let bottleBlock: String
}

fileprivate func parseBottleOutput(from string: String) -> ParsedOutput {
  let lines = string.split(separator: "\n")
  let fileName = lines[2].replacingOccurrences(of: "./", with: "")
  var output = [String.SubSequence]()
  if let startIndex = lines.firstIndex(where: { $0.contains("bottle do") }),
     let endIndex = lines.firstIndex(where: { $0.contains("end") })
  {
    output = Array(lines[startIndex...endIndex])
  }
  
  return .init(
    fileName: fileName,
    bottleBlock: output.joined(separator: "\n")
  )
}


fileprivate extension FileClient {
  
  func writeFile(string: String, to url: URL) async throws {
    try await self.write(data: Data(string.utf8), to: url)
  }
}

fileprivate extension ShellClient {
  func formulaRepositoryPath() throws -> String {
    try self.background(
      ["brew", "--repository", "m-housh/formula"],
      trimmingCharactersIn: .whitespacesAndNewlines
    )
  }
  
  func dotsFormulaUrl() throws -> URL {
    let path = try formulaRepositoryPath()
    return URL(fileURLWithPath: path)
      .appendingPathComponent("Formula")
      .appendingPathComponent("dots.rb")
  }
  
  func runInFormulaRepository(_ arguments: String...) throws {
    let repo = try formulaRepositoryPath()
    FileManager.default.changeCurrentDirectoryPath(repo)
    try self.foreground(.init(arguments))
  }
}

fileprivate let fileTemplate = """
class Dots < Formula
  desc "Command-line tool for managing my dotfiles"
  homepage "https://github.com/m-housh/dots"
  url "https://github.com/m-housh/dots.git", branch: "main"
  version "{{ VERSION }}"
  license "MIT"
{{ BOTTLEBLOCK }}
  depends_on xcode: ["14.2", :build]

  def install
    system "make", "install", "PREFIX=#{prefix}"
    generate_completions_from_executable(bin/"dots", "--generate-completion-script")
  end

  test do
    system "#{bin}/dots" "--version"
  end
end

"""

func fileTemplateWithoutBottleBlock(version: String) -> String {
  fileTemplate.replacingOccurrences(
    of: "{{ VERSION }}",
    with: "\(version)"
  )
  .replacingOccurrences(of: "{{ BOTTLEBLOCK }}", with: "")
}

func fileTemplateWithBottleBlock(block: String, version: String) -> String {
  fileTemplate
    .replacingOccurrences(of: "{{ VERSION }}", with: version)
    .replacingOccurrences(of: "{{ BOTTLEBLOCK }}", with: "\n\(block)\n")
}
