//
//  Warung.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//


import Foundation
import SwiftData

@Model
final class Warung {
    @Attribute(.unique) var id: UUID
    var nama: String
    var alamat: String?
    var kontak: String?
    var hargaKhusus: Decimal?
    var catatan: String?
    var createdAt: Date

    // .deny: warung yang masih punya transaksi tidak bisa dihapus begitu saja,
    // supaya riwayat dan perhitungan stok tidak hilang diam-diam.
    @Relationship(deleteRule: .deny, inverse: \Transaksi.warung)
    var transaksi: [Transaksi] = []

    init(
        nama: String,
        alamat: String? = nil,
        kontak: String? = nil,
        hargaKhusus: Decimal? = nil,
        catatan: String? = nil
    ) {
        self.id = UUID()
        self.nama = nama
        self.alamat = alamat
        self.kontak = kontak
        self.hargaKhusus = hargaKhusus
        self.catatan = catatan
        self.createdAt = .now
    }
}

extension Warung {
    /// Tabung yang masih tertinggal di warung ini (isi diberikan dikurangi kosong diterima).
    var outstandingTabung: Int {
        transaksi.reduce(0) { $0 + $1.selisihTabung }
    }

    /// Total utang uang dari seluruh transaksi warung ini.
    var totalUtang: Decimal {
        transaksi.reduce(Decimal(0)) { $0 + $1.sisaTagihan }
    }
}
