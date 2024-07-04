// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "DNSKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "DNSKit",
            targets: ["DNSKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.55.1"),
    ],
    targets: [
        .target(
            name: "DNSKit",
            exclude: [
                "WHOIS/update_whois.py"
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "DNSKitTests",
            dependencies: ["DNSKit"],
            exclude: [
                "Test Server/"
            ]
        )
    ]
)
