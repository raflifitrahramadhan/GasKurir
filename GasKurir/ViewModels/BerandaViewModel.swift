//
//  BerandaViewModel.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 12/10/26.
//

import Foundation
import Combine

struct GreetingManager {
    let currentHour: Int
    
    init(date: Date = Date()) {
        self.currentHour = Calendar.current.component(.hour, from: date)
    }
    
    var sapaan: String {
        switch currentHour {
        case 5..<10:
            return "Selamat Pagi"
        case 10..<14:
            return "Selamat Siang"
        case 14..<18:
            return "Selamat Sore"
        default:
            return "Selamat Malam"
        }
    }
    
    var sapaan1: String {
        switch currentHour {
        case 5..<18:
            return "Mau Ngirim Kemana Hari Ini?"
        default:
            return "Masih Ada Pengantaran Jam Segini?"
        }
    }
}

struct TitikPenjualan: Identifiable {
    let id = UUID()
    let waktu: String
    let penjualan: Double
    let sebelumnya: Double
}

@MainActor
final class BerandaViewModel: ObservableObject {

    
    // Sapaan
    var sapaan: String {
        let manager: GreetingManager = GreetingManager()
        return manager.sapaan
    }
    
    var sapaan1: String {
        let manager: GreetingManager = GreetingManager()
        return manager.sapaan1
    }
    
    
    // Data ringkasan
    @Published var namaKurir = "Rafli"
    @Published var stokTabungIsi = 45
    @Published var stokTabungKosong = 12
    @Published var tabungDiPelanggan = 8
    @Published var tabungTerjualHariIni = 18

    // Data grafik sementara
    @Published var dataPenjualan: [TitikPenjualan] = [
        .init(waktu: "00.00", penjualan: 2, sebelumnya: 4),
        .init(waktu: "04.00", penjualan: 4, sebelumnya: 3),
        .init(waktu: "06.00", penjualan: 3, sebelumnya: 5),
        .init(waktu: "08.00", penjualan: 8, sebelumnya: 6),
        .init(waktu: "10.00", penjualan: 7, sebelumnya: 8),
        .init(waktu: "12.00", penjualan: 14, sebelumnya: 9),
        .init(waktu: "14.00", penjualan: 11, sebelumnya: 8),
        .init(waktu: "16.00", penjualan: 10, sebelumnya: 9),
        .init(waktu: "18.00", penjualan: 9, sebelumnya: 8),
        .init(waktu: "20.00", penjualan: 12, sebelumnya: 11)
    ]

    // Pengingat tabung
    @Published var namaWarungTerlambat = "Warung Teh Ida"
    @Published var hariBelumKembali = 5
    @Published var tabungHilang = 3

    var adaPengingat: Bool {
        hariBelumKembali >= 3
    }
}
