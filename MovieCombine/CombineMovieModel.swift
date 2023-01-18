//
//  CombineMovieModel.swift
//  MovieCombine
//
//  Created by 藤治仁 on 2023/01/18.
//

import Foundation
import AVFoundation

class CombineMovieModel: NSObject {
    private var player: AVPlayer?
    
    enum CombineMovieError: Error {
        case exportError
    }

    func combine(importMovies: [URL]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // オーディオトラック有無をチェック
            var enableAudio = true
            for movieFile in importMovies {
                let streamMovie = AVURLAsset(url: movieFile)
                if streamMovie.tracks(withMediaType: .audio).first == nil {
                    enableAudio = false
                }
            }
            
            let movie = AVMutableComposition()
            let videoTrack = movie.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            var audioTrack: AVMutableCompositionTrack?
            if enableAudio {
                print("\(#fileID) \(#function) \(#line) enable Audio Track")
                let audioTrack = movie.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            } else {
                print("\(#fileID) \(#function) \(#line) disable Audio Track")
            }
            
            do {
                for movieFile in importMovies {
                    let currentDuration = movie.duration
                    let streamMovie = AVURLAsset(url: movieFile)
                    print("\(#fileID) \(#function) \(#line) movieFile:\(movieFile) tracks:\(streamMovie.tracks)")
                    let streamRange = CMTimeRangeMake(start: CMTime.zero, duration: streamMovie.duration)
                    if let streamVideoTrack = streamMovie.tracks(withMediaType: .video).first {
                        try videoTrack?.insertTimeRange(streamRange, of: streamVideoTrack, at: currentDuration)
                        videoTrack?.preferredTransform = streamVideoTrack.preferredTransform
                    } else {
                        print("\(#fileID) \(#function) \(#line) notfound Video Track")
                    }
                    
                    if let streamAudioTrack = streamMovie.tracks(withMediaType: .audio).first {
                        try audioTrack?.insertTimeRange(streamRange, of: streamAudioTrack, at: currentDuration)
                    } else {
                        print("\(#fileID) \(#function) \(#line) notfound Audio Track")
                    }
                }
            } catch (let error) {
                print("\(#fileID) \(#function) \(#line) Could not create movie \(error.localizedDescription)")
                continuation.resume(throwing: error)
            }
            
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: movie))
            
            if let assetToExport = self.player?.currentItem?.asset ,
               let outputMovieURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("exported.mp4") {
                //delete any old file
                do {
                    try FileManager.default.removeItem(at: outputMovieURL)
                } catch {
                    print("\(#fileID) \(#function) \(#line) Could not remove file (or file doesn't exist) \(error.localizedDescription)")
                }
                //create exporter
                let exporter = AVAssetExportSession(asset: assetToExport, presetName: AVAssetExportPresetHighestQuality)
                
                //configure exporter
                exporter?.outputURL = outputMovieURL
                exporter?.outputFileType = .mov
                
                //export!
                exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
                    if let error = exporter?.error {
                        print("\(#fileID) \(#function) \(#line) failed \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else {
                        print("\(#fileID) \(#function) \(#line) success")
                        continuation.resume()
                    }
                })
            } else {
                print("\(#fileID) \(#function) \(#line) failed")
                continuation.resume(throwing: CombineMovieError.exportError)
            }
        }
    }
}
