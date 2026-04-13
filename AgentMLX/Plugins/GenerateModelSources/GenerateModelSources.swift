import PackagePlugin
import Foundation

@main
struct GenerateModelSources: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else { return [] }

        let sourceDir = sourceTarget.sourceFiles.first?.url.deletingLastPathComponent()
            ?? context.package.directoryURL.appending(components: "Sources", target.name)

        let modelsDir = sourceDir.appending(component: "Models")
        let outputFile = context.pluginWorkDirectoryURL.appending(component: "ModelSource+Generated.swift")

        return [
            .buildCommand(
                displayName: "Generating ModelSource enum",
                executable: try context.tool(named: "GenerateModelSourcesTool").url,
                arguments: [modelsDir.path(percentEncoded: false), outputFile.path(percentEncoded: false)],
                outputFiles: [outputFile]
            )
        ]
    }
}
