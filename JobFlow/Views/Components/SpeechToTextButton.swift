//
//  SpeechToTextButton.swift
//  JobFlow
//
//  Speech-to-text button component for Notes fields
//

import SwiftUI

struct SpeechToTextButton: View {
    @Binding var text: String
    let placeholder: String
    @StateObject private var speechService = SpeechToTextService.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Button {
            handleSpeechToText()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: speechService.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.title3)
                    .foregroundColor(speechService.isRecording ? .red : .blue)
                
                if speechService.isRecording {
                    Text("Recording...")
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text("Voice")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(speechService.isRecording ? Color.red.opacity(0.1) : Color.blue.opacity(0.1))
            .cornerRadius(6)
        }
        .disabled(!speechService.isAuthorized)
        .alert("Permissions Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable microphone and speech recognition permissions in Settings to use voice input.")
        }
        .alert("Speech Recognition Error", isPresented: .constant(speechService.errorMessage != nil)) {
            Button("OK") {
                speechService.errorMessage = nil
            }
        } message: {
            if let errorMessage = speechService.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func handleSpeechToText() {
        if speechService.isRecording {
            speechService.stopRecording()
        } else {
            Task {
                let hasPermissions = await speechService.checkPermissions()
                
                await MainActor.run {
                    if hasPermissions {
                        speechService.startRecording { transcribedText in
                            // Append to existing text or replace if empty
                            if text.isEmpty {
                                text = transcribedText
                            } else {
                                text += " " + transcribedText
                            }
                        }
                    } else {
                        showingPermissionAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    @State var sampleText = ""
    
    return VStack {
        TextEditor(text: $sampleText)
            .frame(height: 100)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        
        HStack {
            Spacer()
            SpeechToTextButton(text: $sampleText, placeholder: "Add notes...")
        }
    }
    .padding()
}