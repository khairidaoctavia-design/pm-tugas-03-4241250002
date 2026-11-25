import 'dart:io';

// ==========================================
// 1. MODEL DATA MATA KULIAH
// ==========================================

class MataKuliah {
  final String nama;
  final int sks;
  final String nilai;
  final double bobot;

  MataKuliah({
    required this.nama,
    required this.sks,
    required this.nilai,
    required this.bobot,
  });
}

// ==========================================
// 2. FUNGSI INPUT
// ==========================================

String bacaInput(String pesan) {
  stdout.write('$pesan: ');
  return stdin.readLineSync()?.trim() ?? '';
}

// ==========================================
// 3. FUNGSI KONVERSI NILAI
// ==========================================

double bobot(String huruf) {
  switch (huruf.toUpperCase()) {
    case 'A':
      return 4.0;
    case 'B':
      return 3.0;
    case 'C':
      return 2.0;
    case 'D':
      return 1.0;
    case 'E':
      return 0.0;
    default:
      throw FormatException('Nilai harus A, B, C, D, atau E.');
  }
}

// ==========================================
// 4. FUNGSI VALIDASI SKS
// ==========================================

int validasiSKS(String input) {
  final int? jumlah = int.tryParse(input);

  if (jumlah == null || jumlah < 1 || jumlah > 6) {
    throw FormatException('SKS harus berupa angka 1-6, bukan "$input".');
  }

  return jumlah;
}

// ==========================================
// 5. FUNGSI VALIDASI NILAI
// ==========================================

String validasiNilai(String input) {
  final huruf = input.toUpperCase();

  // Memastikan nilai huruf valid.
  bobot(huruf);

  return huruf;
}

// ==========================================
// 6. FUNGSI MENGHITUNG IP MENGGUNAKAN FOLD
// ==========================================

double hitungIp(List<MataKuliah> data) {
  final hasil = data.fold<({int totalSks, double totalMutu})>(
    (totalSks: 0, totalMutu: 0.0),
    (akumulasi, mk) => (
      totalSks: akumulasi.totalSks + mk.sks,
      totalMutu: akumulasi.totalMutu + (mk.sks * mk.bobot),
    ),
  );

  if (hasil.totalSks == 0) {
    return 0.0;
  }

  return hasil.totalMutu / hasil.totalSks;
}

// ==========================================
// 7. FUNGSI MENENTUKAN PREDIKAT
// ==========================================

String predikat(double ip) {
  if (ip >= 3.50) {
    return 'Sangat Memuaskan';
  } else if (ip >= 3.00) {
    return 'Memuaskan';
  } else if (ip >= 2.00) {
    return 'Cukup';
  } else {
    return 'Kurang';
  }
}

// ==========================================
// 8. FUNGSI CETAK KARTU HASIL STUDI
// ==========================================

void cetakKhs(List<MataKuliah> data, {bool urutkan = false}) {
  print('\n${'=' * 65}');
  print('                    KARTU HASIL STUDI');
  print('=' * 65);

  if (data.isEmpty) {
    print('Belum ada mata kuliah yang dimasukkan.');
    print('=' * 65);
    return;
  }

  // Membuat salinan agar urutan data asli tidak berubah.
  final List<MataKuliah> daftarTampil = [...data];

  // Mengurutkan nilai tertinggi menggunakan sort.
  if (urutkan) {
    daftarTampil.sort((a, b) => b.bobot.compareTo(a.bobot));
  }

  print(
    '${'NO'.padRight(5)}'
    '${'MATA KULIAH'.padRight(30)}'
    '${'SKS'.padLeft(6)}'
    '${'NILAI'.padLeft(9)}'
    '${'BOBOT'.padLeft(10)}',
  );

  print('-' * 65);

  // Closure untuk membuat nomor urut.
  final nomorBerikutnya = buatPenghitung();

  for (final mk in daftarTampil) {
    print(
      '${nomorBerikutnya().toString().padRight(5)}'
      '${mk.nama.padRight(30)}'
      '${mk.sks.toString().padLeft(6)}'
      '${mk.nilai.padLeft(9)}'
      '${mk.bobot.toStringAsFixed(1).padLeft(10)}',
    );
  }

  print('-' * 65);

  // Menghitung total SKS menggunakan fold.
  final totalSks = data.fold<int>(0, (total, mk) => total + mk.sks);

  final double ip = hitungIp(data);

  print('Total SKS : $totalSks');
  print('IP        : ${ip.toStringAsFixed(2)}');
  print('Predikat  : ${predikat(ip)}');

  // Mencari mata kuliah dengan bobot di bawah 2.
  final perluDiperbaiki = data.where((mk) => mk.bobot < 2.0).toList();

  print('\nMata Kuliah yang Perlu Diperbaiki:');

  if (perluDiperbaiki.isEmpty) {
    print('Tidak ada. Semua nilai sudah memenuhi batas.');
  } else {
    for (final mk in perluDiperbaiki) {
      print('- ${mk.nama} (Nilai ${mk.nilai})');
    }
  }

  print('=' * 65);
}

// ==========================================
// 9. CLOSURE: MEMBUAT PENGHITUNG NOMOR URUT
// ==========================================

int Function() buatPenghitung() {
  int hitungan = 0;

  return () {
    hitungan++;
    return hitungan;
  };
}

// ==========================================
// 10. PROGRAM UTAMA
// ==========================================

void main() {
  final List<MataKuliah> daftarMK = [];

  print('=' * 65);
  print('                  KALKULATOR IP SEMESTER');
  print('=' * 65);

  print('Masukkan data mata kuliah.');
  print('Kosongkan nama mata kuliah untuk selesai.');

  // Closure untuk menghitung data yang berhasil dimasukkan.
  final nomorInput = buatPenghitung();

  while (true) {
    print('\n----------------------------------------');

    final nama = bacaInput('Nama MK');

    // Menghentikan input jika nama kosong.
    if (nama.isEmpty) {
      break;
    }

    try {
      final inputSks = bacaInput('SKS');
      final inputNilai = bacaInput('Nilai');

      // Validasi data.
      final int jumlahSks = validasiSKS(inputSks);
      final String nilaiHuruf = validasiNilai(inputNilai);
      final double nilaiBobot = bobot(nilaiHuruf);

      // Membuat objek mata kuliah.
      final mk = MataKuliah(
        nama: nama,
        sks: jumlahSks,
        nilai: nilaiHuruf,
        bobot: nilaiBobot,
      );

      daftarMK.add(mk);

      print('Data ke-${nomorInput()} berhasil ditambahkan.');
    } on FormatException catch (e) {
      // Menangani input yang tidak valid.
      print('Data diabaikan: ${e.message}');
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  // Menampilkan KHS dengan urutan nilai tertinggi.
  cetakKhs(daftarMK, urutkan: true);

  print('\nProgram selesai. Terima kasih!');
}
