//
//  GasKurirApp.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import SwiftUI
import SwiftData

@main
struct GasKurirApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Warung.self, Transaksi.self, PembelianAgen.self, Konfigurasi.self])
        
    }
}
