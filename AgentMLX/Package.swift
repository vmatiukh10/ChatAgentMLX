// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AgentMLX",
    platforms: [
        // MLX targets Apple Silicon; macOS 14+ recommended
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "AgentMLX",
            targets: ["AgentMLX"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ml-explore/mlx-swift-lm", .upToNextMinor(from: "2.30.3")),
        .package(
            url: "https://github.com/DePasqualeOrg/swift-tokenizers-mlx",
            branch: "main",
            traits: ["Swift"]
        )
    ],
    targets: [
        .executableTarget(
            name: "GenerateModelSourcesTool"
        ),
        .plugin(
            name: "GenerateModelSources",
            capability: .buildTool(),
            dependencies: ["GenerateModelSourcesTool"]
        ),
        .target(
            name: "AgentMLX",
            dependencies: [
                .product(name: "MLXLLM", package: "mlx-swift-lm"),
                .product(name: "MLXLMTokenizers", package: "swift-tokenizers-mlx")
            ],
            resources: [
                .copy("Models")
            ],
            plugins: [
                .plugin(name: "GenerateModelSources")
            ]),
    ]
)
