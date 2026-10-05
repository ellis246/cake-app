//
//  CakeRowsView.swift
//  CakeApp
//
//  Created by Adam Ellis on 29/09/2026.
//

import SwiftUI

struct CakeRowsView: View {
    
    let cakes: [Cake]
    let onTap: (Cake) -> Void
    
    var body: some View {
        ForEach(cakes.enumerated(), id: \.element.title) { (index, cake) in
            Button {
                onTap(cake)
            } label: {
                VStack(alignment: .leading) {
                    Text("\(cake.title)")
                        .font(.title)
                    //TODO: Introduce adaptive grid layout for landscape and iPad
                    Color.secondary.opacity(0.1)
                        .aspectRatio(16/9, contentMode: .fit)
                        .frame(maxWidth: 400)
                        .overlay {
                            AsyncImage(url: URL(string: cake.image)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "photo.badge.exclamationmark")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
            }
            .buttonStyle(.plain)
            if index < cakes.count-1 {
                Divider()
            }
        }
    }
}

#Preview {
    CakeRowsView(cakes: [Cake(title: "Sample cake", desc: "Sample desc", image: "")]){ _ in }
}
