import SwiftUI
#if canImport(AVFoundation)
import AVFoundation
#endif

/// Vista per il player audio integrato
struct AudioPlayerView: View {
    let audioURL: String
    let titolo: String
    let fratello: String
    
    @StateObject private var player = AudioPlayerViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text(titolo)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                    .multilineTextAlignment(.center)
                
                Text("Fr. \(fratello)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.top, 32)
            
            Spacer()
            
            // Audio icon
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(AppTheme.masonicBlue)
                .symbolEffect(.pulse, isActive: player.isPlaying)
            
            Spacer()
            
            // Progress slider
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { player.currentTime },
                        set: { player.seek(to: $0) }
                    ),
                    in: 0...max(player.duration, 1)
                )
                .tint(AppTheme.masonicBlue)
                
                HStack {
                    Text(formatTime(player.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formatTime(player.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Controls
            HStack(spacing: 40) {
                Button(action: { player.rewind() }) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                        .foregroundColor(AppTheme.masonicBlue)
                }
                
                Button(action: { player.togglePlayPause() }) {
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppTheme.masonicBlue)
                }
                
                Button(action: { player.forward() }) {
                    Image(systemName: "goforward.15")
                        .font(.title)
                        .foregroundColor(AppTheme.masonicBlue)
                }
            }
            .padding(.bottom, 32)
        }
        .padding()
        .onAppear {
            player.loadAudio(from: audioURL)
        }
        .onDisappear {
            Task { @MainActor in
                player.stop()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Chiudi") {
                    dismiss()
                }
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

/// ViewModel per gestire la riproduzione audio
@MainActor
class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    #if canImport(AVFoundation)
    private var player: AVPlayer?
    private var timeObserver: Any?
    #endif
    
    func loadAudio(from urlString: String) {
        #if canImport(AVFoundation)
        guard let url = URL(string: urlString) else {
            print("URL audio non valido: \(urlString)")
            return
        }
        
        player = AVPlayer(url: url)
        
        // Observer per il tempo corrente
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            
            if let duration = self.player?.currentItem?.duration.seconds, duration.isFinite {
                self.duration = duration
            }
            
            // Check se il player è arrivato alla fine
            if let duration = self.player?.currentItem?.duration.seconds,
               duration.isFinite,
               time.seconds >= duration {
                self.isPlaying = false
            }
        }
        #endif
    }
    
    func togglePlayPause() {
        #if canImport(AVFoundation)
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
        #endif
    }
    
    func seek(to time: Double) {
        #if canImport(AVFoundation)
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
        #endif
    }
    
    func rewind() {
        #if canImport(AVFoundation)
        let newTime = max(currentTime - 15, 0)
        seek(to: newTime)
        #endif
    }
    
    func forward() {
        #if canImport(AVFoundation)
        let newTime = min(currentTime + 15, duration)
        seek(to: newTime)
        #endif
    }
    
    func stop() {
        #if canImport(AVFoundation)
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        #endif
        isPlaying = false
    }
    
    deinit {
        // Cleanup sincrono senza modificare proprietà @Published
        #if canImport(AVFoundation)
        player?.pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        #endif
    }
}

#Preview {
    AudioPlayerView(
        audioURL: "https://example.com/audio.mp3",
        titolo: "Il Simbolismo della Squadra e del Compasso",
        fratello: "Marco Rossi"
    )
}
