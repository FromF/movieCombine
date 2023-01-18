//
//  MovieCombineViewModel.swift
//  MovieCombine
//
//  Created by 藤治仁 on 2023/01/18.
//

import SwiftUI

class MovieCombineViewModel: NSObject, ObservableObject {
    @Published var importFileList: [URL] = []
    @Published var combineFileList: [URL] = []
    @Published var isProgress = false
    private let fileModel = FileModel()
    private let combineMovieModel = CombineMovieModel()
    
    func createImportFileList() {
        if let importFileList = fileModel.createImportFileList() {
            self.importFileList = importFileList
            combineFileList = []
        }
    }
    
    @MainActor func executeCombine() {
        Task {
            isProgress = true
            do {
                try await combineMovieModel.combine(importMovies: combineFileList)
            } catch {
                print("\(#fileID) \(#function) \(#line) failed \(error.localizedDescription)")
            }
            isProgress = false
        }
    }
}
