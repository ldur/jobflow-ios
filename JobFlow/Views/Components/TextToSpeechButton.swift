//
//  TextToSpeechButton.swift
//  JobFlow
//
//  Reusable text-to-speech button component
//

import SwiftUI

struct TextToSpeechButton: View {
    let text: String
    let style: ButtonStyle
    @StateObject private var ttsService = TextToSpeechService.shared
    
    enum ButtonStyle {
        case compact
        case full
        case icon
    }
    
    var body: some View {
        Button {
            if ttsService.isSpeakingText(text) {
                ttsService.stopSpeaking()
            } else {
                ttsService.speak(text: text)
            }
        } label: {
            switch style {
            case .compact:
                compactButton
            case .full:
                fullButton
            case .icon:
                iconButton
            }
        }
        .disabled(text.isEmpty)
    }
    
    private var compactButton: some View {
        HStack(spacing: 6) {
            Image(systemName: ttsService.isSpeakingText(text) ? "stop.circle.fill" : "speaker.wave.2.fill")
                .font(.caption)
            Text(ttsService.isSpeakingText(text) ? "Stop" : "Listen")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(.blue)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var fullButton: some View {
        HStack(spacing: 8) {
            Image(systemName: ttsService.isSpeakingText(text) ? "stop.circle.fill" : "speaker.wave.2.fill")
                .font(.subheadline)
            Text(ttsService.isSpeakingText(text) ? "Stop Reading" : "Read Aloud")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(ttsService.isSpeakingText(text) ? Color.red : Color.blue)
        .cornerRadius(8)
    }
    
    private var iconButton: some View {
        Image(systemName: ttsService.isSpeakingText(text) ? "stop.circle.fill" : "speaker.wave.2.fill")
            .font(.title3)
            .foregroundColor(ttsService.isSpeakingText(text) ? .red : .blue)
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: 20) {
        TextToSpeechButton(text: "This is a sample text for testing", style: .compact)
        TextToSpeechButton(text: "This is a sample text for testing", style: .full)
        TextToSpeechButton(text: "This is a sample text for testing", style: .icon)
    }
    .padding()
}