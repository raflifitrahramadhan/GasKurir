//
//  Transaksi.swift
//  GasKurir
//
//  Created by Rafli Ramadhan on 13/10/26.
//

import Foundation
import SwiftData

enum StatusPembayaran: String, Codable {
    case lunas = "Lunas"
    case sebagian = "Sebagian"
    case utang = "Utang"
}

@Model
final class Transaksi {
    @Attribute(.unique) var id: UUID
    var warung: Warung?
    var tanggal: Date
    var jumlahIsiDiberikan: Int
    var jumlahKosongDiterima: Int

    /// Snapshot harga satuan SAAT transaksi dibuat, supaya perubahan harga
    /// default di kemudian hari tidak mengubah nilai transaksi lama.
    var hargaSatuanSaatItu: Decimal
    var totalHarga: Decimal
    var jumlahDibayar: Decimal
    var catatan: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        warung: Warung,
        tanggal: Date = .now,
        jumlahIsiDiberikan: Int,
        jumlahKosongDiterima: Int,
        hargaSatuanSaatItu: Decimal,
        totalHarga: Decimal? = nil,
        jumlahDibayar: Decimal = 0,
        catatan: String? = nil
    ) {
        self.id = UUID()
        self.warung = warung
        self.tanggal = tanggal
        self.jumlahIsiDiberikan = jumlahIsiDiberikan
        self.jumlahKosongDiterima = jumlahKosongDiterima
        self.hargaSatuanSaatItu = hargaSatuanSaatItu
        // Default = harga satuan x jumlah isi, tapi bisa dioverride (harga khusus/diskon).
        self.totalHarga = totalHarga ?? (hargaSatuanSaatItu * Decimal(jumlahIsiDiberikan))
        self.jumlahDibayar = jumlahDibayar
        self.catatan = catatan
        self.createdAt = .now
        self.updatedAt = .now
    }
}

extension Transaksi {
    /// Selisih isi-diberikan vs kosong-diterima dari transaksi INI saja.
    var selisihTabung: Int {
        jumlahIsiDiberikan - jumlahKosongDiterima
    }

    /// Selalu dihitung dari jumlahDibayar vs totalHarga, tidak pernah disimpan manual.
    var statusPembayaran: StatusPembayaran {
        if jumlahDibayar >= totalHarga {
            return .lunas
        } else if jumlahDibayar > 0 {
            return .sebagian
        } else {
            return .utang
        }
    }

    var sisaTagihan: Decimal {
        max(0, totalHarga - jumlahDibayar)
    }

    /// Untuk pelunasan susulan dari layar Detail Transaksi.
    func catatPembayaran(_ jumlah: Decimal) {
        jumlahDibayar += jumlah
        updatedAt = .now
    }
}
