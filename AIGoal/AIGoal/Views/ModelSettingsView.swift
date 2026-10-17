//
//  ModelSettingsView.swift
//  AIGoal
//
//  Created by Hitesh Chotaliya on 17/10/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ModelSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showImporter = false
    @State private var filename = ""
    @State private var errorMessage: String?
    @State private var isImporting = false

    private var currentModelName: String {
        ModelStore.currentModelURL?.lastPathComponent ?? "No model selected"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Local AI model") {
                    Label {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(currentModelName)
                                .font(.headline)

                            Text(
                                ModelStore.currentModelURL == nil
                                ? "Import a GGUF file to start generating goals."
                                : "Stored in this app's local Documents folder."
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "cpu")
                            .foregroundStyle(Color.goalPurple)
                    }

                    Button {
                        showImporter = true
                    } label: {
                        HStack {
                            Spacer()
                            if isImporting {
                                ProgressView()
                            } else {
                                Image(systemName: "folder")
                            }
                            Text("Import GGUF model")
                            Spacer()
                        }
                    }
                    .disabled(isImporting)
                }

                Section("Privacy") {
                    Label(
                        "Inference runs locally on your device",
                        systemImage: "lock.shield"
                    )

                    Text(
                        "Importing a model requires access to the selected file. "
                        + "GoalCraft does not need a cloud AI API."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Section("Import error") {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("AI Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [
                    UTType(filenameExtension: "gguf") ?? .data
                ],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }

                    isImporting = true
                    errorMessage = nil

                    do {
                        _ = try ModelStore.importModel(from: url)
                        filename = url.lastPathComponent
                    } catch {
                        errorMessage = error.localizedDescription
                    }

                    isImporting = false

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
