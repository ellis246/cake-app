//
//  Cake.swift
//  CakeApp
//
//  Created by Adam Ellis on 29/09/2026.
//
struct Cake: Decodable, Identifiable {
    let title: String
    let desc: String
    let image: String
    
    var id: String {
        title
    }
}
