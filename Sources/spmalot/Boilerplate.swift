//  Copyright © 2021 Erica Sadun. All rights reserved.

import Foundation
import GeneralUtility
import MacUtility

struct Boilerplate {
    static func year() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "Y"
        return formatter.string(from: Date())
    }

    static func username() throws -> String {
        try Utility.execute("/usr/bin/git config user.name")
    }

    static func dumpREADME(name: String, style: ProjectStyle, sap: Bool, gen: Bool, mac: Bool) throws {
        var boilerplate = "# \(name)\n\n"
        boilerplate += (style == .exe) ? "An executable project.\n" : "A library.\n"
        boilerplate += """

            ## Overview

            An overview of this project

            ## Known Issues

            None.

            """

        if (sap || gen || mac) {
            boilerplate += "## Dependencies\n\n"

            if sap {
                boilerplate += "* [Swift Argument Parser](https://github.com/apple/swift-argument-parser)\n"
            }

            if gen || mac {
                boilerplate += "* [Swift General Utility](https://github.com/erica/Swift-General-Utility)\n"
            }

            if mac {
                boilerplate += "* [Swift Mac Utility](https://github.com/erica/Swift-Mac-Utility)\n"
            }

            boilerplate += "\n"
        }

        if style == .exe {
            boilerplate += """

                ## Installation

                * Install [homebrew](https://brew.sh).
                * Install [mint](https://github.com/yonaskolb/Mint) with homebrew (`brew install mint`).
                * From command line: `mint install erica/\(name)`

                """
        }

        boilerplate += """

            ## Thanks and Acknowledgements

            Thanks to everyone who pitched in and helped with this.
            """

        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("README.md")
        try boilerplate.write(to: url, atomically: true, encoding: .utf8)
    }

    static func dumpCHANGELOG() throws {
        let boilerplate = """
            # CHANGELOG

            ## 0.0.0
            Initial Commit
            """

        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("CHANGELOG.md")
        try boilerplate.write(to: url, atomically: true, encoding: .utf8)
    }

    static func dumpLICENSE() throws {
        let uname = try username()
        let boilerplate = """
            MIT License

            Copyright (c) \(year()) \(uname)

            Permission is hereby granted, free of charge, to any person obtaining a copy
            of this software and associated documentation files (the "Software"), to deal
            in the Software without restriction, including without limitation the rights
            to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            copies of the Software, and to permit persons to whom the Software is
            furnished to do so, subject to the following conditions:

            The above copyright notice and this permission notice shall be included in all
            copies or substantial portions of the Software.

            THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
            SOFTWARE.

            """

        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("LICENSE.txt")
        try boilerplate.write(to: url, atomically: true, encoding: .utf8)
    }

    static func buildMain(name: String, url: URL, sap: Bool) throws {
        let uname = try username()

        var boilerplate = """
            /// Copyright (c) \(year()) \(uname). All Rights Reserved.

            import Foundation\n
            """

        switch sap {
        case false:
            boilerplate += #"\#nprint("Hello world!")\#n\#n"#

        case true:
            boilerplate += """
                import ArgumentParser

                struct \(name.capitalized): ParsableCommand {
                    static var configuration = CommandConfiguration(
                        abstract: "Execute the \(name) command",
                        shouldDisplay: true)

                    @Argument(help: "A name") var name = "World"

                    func run() throws {
                        print("Hello, \\(name)!")
                    }

                }

                \(name.capitalized).main()

                """
        }

        try boilerplate.write(to: url, atomically: true, encoding: .utf8)
    }

    static func buildPackage(name: String, url: URL, exe: Bool, sap: Bool, gen: Bool, mac: Bool) throws {
        var boilerplate = """
            // swift-tools-version:5.3
            // Version 5.3 required for Swift Argument Parser. Supports Catalina+

            import PackageDescription

            let package = Package(
                // This name is normally synonymous with a hosted git repo
                name: "\(name)",

                platforms: [.macOS(.v10_12)],

                // The executables or libraries produced by this project
                products: [

            """

        if exe  {
            boilerplate += """
                    // This is the call name of the executable that is produced
                    .executable(name: "\(name)",

                        // The targets named here are the modules listed in the targets section
                        targets: ["\(name)"]),
                ],

                dependencies: [

            """
        } else {
            boilerplate += """
                    // This is the call name of the library that is produced.
                    // You don't import that name. You import the names of the
                    // module targets included within the library.
                    .library(name: "\(name)",

                        // The targets named here are the modules listed in the targets section
                        targets: ["\(name)"]),
                ],

                dependencies: [

            """
        }

        if exe && sap {
            // This is exact because of the changes in SAP
            boilerplate += """
                        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.4.3")),

                """
        }

        if exe && (mac || gen) {
            // General and Mac are fairly stable. It is safe to use "from"
            boilerplate += """
                        .package(url: "https://github.com/erica/Swift-General-Utility", from: "0.0.6"),

                """
        }

        if exe && mac {
            boilerplate += """
                        .package(url: "https://github.com/erica/Swift-Mac-Utility", from:"0.0.2"),

                """
        }

        boilerplate += """
                ],

                targets: [
                    // Create module targets

                    .target(
                        // This is the module name. It is used by the product section targets
                        // and by any test target
                        name: "\(name)",
                        dependencies: [

            """

        if exe && sap {
            boilerplate += #"                .product(name: "ArgumentParser", package: "swift-argument-parser"), \#n"#
        }

        if exe && (gen || mac) {
            boilerplate += #"                .product(name: "GeneralUtility", package: "Swift-General-Utility"), \#n"#
        }

        if exe && mac {
            boilerplate += #"                .product(name: "MacUtility", package: "Swift-Mac-Utility"), \#n"#
        }

        boilerplate += """
                        ],
                        path: "Sources/" // Omit or override if needed
                    ),

                    // Test target omitted here
                    //.testTarget(name: "\(name)Tests", dependencies: ["\(name)"]),
                ],

                swiftLanguageVersions: [ .v5 ]
            )
            """

        try boilerplate.write(to: url, atomically: true, encoding: .utf8)
    }
}
