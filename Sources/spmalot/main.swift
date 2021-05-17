//  Copyright © 2021 Erica Sadun. All rights reserved.

import Foundation
import ArgumentParser
import GeneralUtility
import MacUtility

enum ProjectStyle: EnumerableFlag { case exe, lib }

// A command-line utility to create initial SPM project files
// and set up preliminary repository tasks
struct Spmalot: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: """

              Create and initialize an SPM project folder including
              README/CHANGELOG/License boilerplate and then commit/tag.

              * Use -sap|-gen|-mac to add support for the argument parser (apple),
                for general utilities and mac utilities (see github.com/erica).
              * Use -repo to automatically create a GitHub repo using the `gh`
                command-line utility.
            """,
        shouldDisplay: true)

    @Argument(help: "The product (library or executable) name") var name: String
    @Flag(help: "The project style.") var style: ProjectStyle = .exe
    @Flag(help: "Build and link a remote GitHub repo.") var repo = false

    @Flag(help: .hidden) var sap = false
    @Flag(help: .hidden) var gen = false
    @Flag(help: .hidden) var mac = false

    func run() throws {
        // Create new project folder with the given name and then enter it to work.
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(name)
            .versioned()
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        FileManager.default.changeCurrentDirectoryPath(url.path)

        // Create Docs
        try Boilerplate.dumpREADME(name: name, style: style, sap: sap, gen: gen, mac: mac)
        try Boilerplate.dumpCHANGELOG()
        try Boilerplate.dumpLICENSE()

        // Create Sources folder
        let sourcesURL = url
            .appendingPathComponent("Sources")
            .appendingPathComponent(name)
        try FileManager.default.createDirectory(at: sourcesURL, withIntermediateDirectories: true, attributes: nil)

        // TODO: Add Tests folders for library work.
        // TODO: Add Tests for exe work as well

        // FIXME: This should be .exe only. Add support for lib
        // Create main.swift
        let mainURL = sourcesURL.appendingPathComponent("main.swift")
        try Boilerplate.buildMain(name: name, url: mainURL, sap: sap)

        // Create Package.swift
        let packageURL = url.appendingPathComponent("Package.swift")
        try Boilerplate.buildPackage(name: name, url: packageURL, exe: style == .exe, sap: sap, gen: gen, mac: mac)

        // Initialize as git repo
        // FIXME: This creates a `main` branch, which is incompatible with mint
        _ = try Utility.execute("/usr/bin/git init")
        _ = try Utility.execute("/usr/bin/git add .")
        _ = try Utility.execute("/usr/bin/git commit -m Initial_Commit")
        if style != .exe { _ = try Utility.execute("/usr/bin/git branch -M main") }
        _ = try Utility.execute("/usr/bin/git tag 0.0.1")

        // Use `gh` to create a remote repository, then push. Print output.
        if repo {
            print(try Utility.execute("/usr/local/bin/gh repo create \(name) --confirm --public"))
            print(try Utility.execute("/usr/bin/git push -u origin main"))
            print(try Utility.execute("/usr/bin/git push --tags"))
        }
    }
}

Spmalot.main()
