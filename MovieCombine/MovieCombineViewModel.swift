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
    
    func executeCombine() {
        isProgress = true
        combineMovieModel.combine(importMovies: combineFileList)
        isProgress = false
    }
}
