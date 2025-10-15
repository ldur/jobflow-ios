//
//  AudioSessionManager.swift
//  JobFlow
//
//  Centralized audio session management for TTS and STT services
//

import Foundation
import AVFoundation

class AudioSessionManager: ObservableObject {
    static let shared = AudioSessionManager()
    
    @Published var currentMode: AudioMode = .inactive
    
    enum AudioMode {
        case inactive
        case playback
        case recording
    }
    
    private init() {}
    
    func configureForPlayback() {
        guard currentMode != .playback else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            currentMode = .playback
            print("🔊 Audio session configured for playback")
        } catch {
            print("❌ Failed to configure audio session for playback: \(error)")
        }
    }
    
    func configureForRecording() {
        guard currentMode != .recording else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
            currentMode = .recording
            print("🎤 Audio session configured for recording")
        } catch {
            print("❌ Failed to configure audio session for recording: \(error)")
        }
    }
    
    func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            currentMode = .inactive
            print("🔇 Audio session deactivated")
        } catch {
            print("❌ Failed to deactivate audio session: \(error)")
        }
    }
    
    func resetToPlayback() {
        // Reset to playback mode after recording
        configureForPlayback()
    }
}