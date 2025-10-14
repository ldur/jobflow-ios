//
//  InlineMediaView.swift
//  JobFlow
//
//  Inline media viewer component for images, videos, and audio
//

import SwiftUI
import WebKit

struct InlineMediaView: View {
    let media: ActionMedia
    @State private var showFullScreen = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if media.isImage {
                ImageMediaView(media: media, showFullScreen: $showFullScreen)
            } else if media.isVideo {
                VideoMediaView(media: media, showFullScreen: $showFullScreen)
            } else if media.isAudio {
                AudioMediaView(media: media)
            } else {
                DocumentMediaView(media: media)
            }
        }
        .sheet(isPresented: $showFullScreen) {
            FullScreenMediaView(media: media)
        }
    }
}

// MARK: - Image Media View
struct ImageMediaView: View {
    let media: ActionMedia
    @Binding var showFullScreen: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: media.mediaUrl)) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        ProgressView()
                    )
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
                    .onTapGesture {
                        showFullScreen = true
                    }
            case .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title)
                                .foregroundColor(.red)
                            Text("Failed to load image")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    )
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - Video Media View
struct VideoMediaView: View {
    let media: ActionMedia
    @Binding var showFullScreen: Bool
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "play.rectangle")
                    .foregroundColor(.blue)
                Text("Video")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Button(isExpanded ? "Collapse" : "Play Inline") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if isExpanded {
                if isYouTubeURL(media.mediaUrl) {
                    YouTubePlayerView(videoURL: media.mediaUrl)
                        .frame(height: 250)
                        .cornerRadius(12)
                } else {
                    WebVideoPlayerView(videoURL: media.mediaUrl)
                        .frame(height: 250)
                        .cornerRadius(12)
                }
            } else {
                // Thumbnail view
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = true
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("Tap to play")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                }
            }
            
            // Fallback link
            HStack {
                Image(systemName: "link")
                    .font(.caption)
                    .foregroundColor(.blue)
                Link("Open in browser", destination: URL(string: media.mediaUrl)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
    
    private func isYouTubeURL(_ urlString: String) -> Bool {
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
}

// MARK: - Audio Media View
struct AudioMediaView: View {
    let media: ActionMedia
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "music.note")
                    .foregroundColor(.purple)
                Text("Audio")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Spacer()
                Button(isExpanded ? "Collapse" : "Play") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if isExpanded {
                WebAudioPlayerView(audioURL: media.mediaUrl)
                    .frame(height: 100)
                    .cornerRadius(12)
            } else {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = true
                    }
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                        .frame(height: 60)
                        .overlay(
                            HStack {
                                Image(systemName: "play.circle")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                Text("Tap to play audio")
                                    .font(.subheadline)
                                    .foregroundColor(.purple)
                                Spacer()
                            }
                            .padding(.horizontal)
                        )
                }
            }
            
            // Fallback link
            HStack {
                Image(systemName: "link")
                    .font(.caption)
                    .foregroundColor(.blue)
                Link("Open in browser", destination: URL(string: media.mediaUrl)!)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

// MARK: - Document Media View
struct DocumentMediaView: View {
    let media: ActionMedia
    
    var body: some View {
        Link(destination: URL(string: media.mediaUrl)!) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 80)
                .overlay(
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.title2)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Document")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("Tap to open")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                )
        }
    }
}

// MARK: - YouTube Player View
struct YouTubePlayerView: UIViewRepresentable {
    let videoURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: videoURL) else { return }
        
        let embedURL = convertToEmbedURL(url)
        let request = URLRequest(url: embedURL)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    private func convertToEmbedURL(_ url: URL) -> URL {
        let urlString = url.absoluteString
        
        if urlString.contains("youtube.com/watch") {
            // Extract video ID from youtube.com/watch?v=VIDEO_ID
            if let videoID = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "v" })?.value {
                return URL(string: "https://www.youtube.com/embed/\(videoID)")!
            }
        } else if urlString.contains("youtu.be/") {
            // Extract video ID from youtu.be/VIDEO_ID
            let videoID = url.lastPathComponent
            return URL(string: "https://www.youtube.com/embed/\(videoID)")!
        }
        
        return url
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optional: Handle completion
        }
    }
}

// MARK: - Web Video Player View
struct WebVideoPlayerView: UIViewRepresentable {
    let videoURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        
        // Enable media playback
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: videoURL) else { return }
        
        // Create HTML with video element
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { margin: 0; padding: 0; background: black; }
                video { width: 100%; height: 100%; object-fit: contain; }
            </style>
        </head>
        <body>
            <video controls playsinline>
                <source src="\(videoURL)" type="video/mp4">
                Your browser does not support the video tag.
            </video>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optional: Handle completion
        }
    }
}

// MARK: - Web Audio Player View
struct WebAudioPlayerView: UIViewRepresentable {
    let audioURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        
        // Enable media playback
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: audioURL) else { return }
        
        // Create HTML with audio element
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { 
                    margin: 0; 
                    padding: 20px; 
                    background: #f5f5f5; 
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                }
                audio { 
                    width: 100%; 
                    max-width: 400px;
                }
            </style>
        </head>
        <body>
            <audio controls>
                <source src="\(audioURL)" type="audio/mpeg">
                <source src="\(audioURL)" type="audio/wav">
                <source src="\(audioURL)" type="audio/ogg">
                Your browser does not support the audio tag.
            </audio>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Optional: Handle completion
        }
    }
}

// MARK: - Full Screen Media View
struct FullScreenMediaView: View {
    let media: ActionMedia
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if media.isImage {
                    AsyncImage(url: URL(string: media.mediaUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.white)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                                Text("Failed to load image")
                                    .foregroundColor(.white)
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else if media.isVideo {
                    if isYouTubeURL(media.mediaUrl) {
                        YouTubePlayerView(videoURL: media.mediaUrl)
                    } else {
                        WebVideoPlayerView(videoURL: media.mediaUrl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func isYouTubeURL(_ urlString: String) -> Bool {
        return urlString.contains("youtube.com") || urlString.contains("youtu.be")
    }
}

#Preview {
    VStack {
        InlineMediaView(media: ActionMedia(
            id: "1",
            actionId: "action1",
            mediaUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            mediaType: "video/youtube",
            createdAt: nil
        ))
        
        InlineMediaView(media: ActionMedia(
            id: "2",
            actionId: "action2",
            mediaUrl: "https://example.com/image.jpg",
            mediaType: "image/jpeg",
            createdAt: nil
        ))
    }
    .padding()
}