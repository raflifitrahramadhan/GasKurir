//
//  Konfigurasi.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//

import Foundation
import SwiftData

// Singleton: hanya ada SATU baris di database. Ambil lewat Konfigurasi.current(in:),
// jangan di-insert manual dari tempat lain.
@Model
final class Konfigurasi {
    var namaAgen: String
    var kontak: String?
    var hargaSatuanDefault: Decimal
    var reminderTabungHari: Int
    var reminderUtangHari: Int

    init(
        namaAgen: String = "",
        kontak: String? = nil,
        hargaSatuanDefault: Decimal = 0,
        reminderTabungHari: Int = 3,
        reminderUtangHari: Int = 1
    ) {
        self.namaAgen = namaAgen
        self.kontak = kontak
        self.hargaSatuanDefault = hargaSatuanDefault
        self.reminderTabungHari = reminderTabungHari
        self.reminderUtangHari = reminderUtangHari
    }
}

extension Konfigurasi {
    // Ambil baris yang ada, atau buat satu kalau belum ada (misal saat pertama kali app dibuka).
    static func current(in context: ModelContext) throws -> Konfigurasi {
        var deskriptor = FetchDescriptor<Konfigurasi>()
        deskriptor.fetchLimit = 1
        if let ada = try context.fetch(deskriptor).first {
            return ada
        }
        let baru = Konfigurasi()
        context.insert(baru)
        return baru
    }
}
