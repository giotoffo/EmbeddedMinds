import 'package:flutter/material.dart';

//PLUG IN
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VoucherProvider with ChangeNotifier {
  List<String> _earnedVouchers = [];
  List<String> get earnedVouchers => _earnedVouchers;

  VoucherProvider() {
    _loadVouchers();
  }

  // Download vouchers from SharedPreferences
  Future<void> _loadVouchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vouchersJson = prefs.getString('earned_vouchers');
      if (vouchersJson != null) {
        final List<dynamic> vouchersList = json.decode(vouchersJson);
        _earnedVouchers = vouchersList.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading vouchers: $e');
    }
  }

  // Save voucher in SharedPreferences
  Future<void> _saveVouchers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final vouchersJson = json.encode(_earnedVouchers);
      await prefs.setString('earned_vouchers', vouchersJson);
    } catch (e) {
      print('Error saving vouchers: $e');
    }
  }

  // Add a voucher (if not already present)
  Future<void> addVoucher(String voucher) async {
    if (!_earnedVouchers.contains(voucher)) {
      _earnedVouchers.add(voucher);
      await _saveVouchers();
      notifyListeners();
    }
  }

  // Delate un voucher (if necessary)
  Future<void> removeVoucher(String voucher) async {
    _earnedVouchers.remove(voucher);
    await _saveVouchers();
    notifyListeners();
  }

  // Clean all voucher
  Future<void> clearVouchers() async {
    _earnedVouchers.clear();
    await _saveVouchers();
    notifyListeners();
  }

  // Set all voucher
  Future<void> setVouchers(List<String> vouchers) async {
    _earnedVouchers = vouchers;
    await _saveVouchers();
    notifyListeners();
  }
}
