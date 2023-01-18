//
//  MovieCombineView.swift
//  MovieCombine
//
//  Created by 藤治仁 on 2023/01/18.
//

import SwiftUI

struct MovieCombineView: View {
    @StateObject var viewModel = MovieCombineViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                Text("SourceMovie")
                List(viewModel.importFileList, id: \.self) { fileName in
                    Button {
                        viewModel.combineFileList.append(fileName)
                    } label: {
                        Text("\(fileName.lastPathComponent)")
                    }
                }
                .refreshable {
                    viewModel.createImportFileList()
                }
                
                Divider()
                Text("Combine Movie")
                List {
                    ForEach(viewModel.combineFileList, id: \.self) { fileName in
                        Text("\(fileName.lastPathComponent)")
                    }
                    .onDelete { offsets in
                        viewModel.combineFileList.remove(atOffsets: offsets)
                    }
                }
                
                Button {
                    viewModel.executeCombine()
                } label: {
                    Text("Combine Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                
            }
            if viewModel.isProgress {
                Color.gray
                    .ignoresSafeArea()
                ProgressView()
            }
        }
        .onAppear {
            viewModel.createImportFileList()
        }
    }
}

struct MovieCombineView_Previews: PreviewProvider {
    static var previews: some View {
        MovieCombineView()
    }
}
