import 'package:flutter/material.dart';

//PLUG IN
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _surname = '';
  String _age = '';
  String _gender = '';
  bool _isPregnant = false;

  // Getters
  String get name => _name;
  String get surname => _surname;
  String get age => _age;
  String get gender => _gender;
  bool get isPregnant => _isPregnant;

  // Setters
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setSurname(String value) {
    _surname = value;
    notifyListeners();
  }

  void setAge(String value) {
    _age = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    if (_gender == 'F') _isPregnant = false;
    notifyListeners();
  }

  void setPregnant(bool value) {
    if (_gender == 'F') {
      _isPregnant = value;
      _isPregnant = value;
      notifyListeners();
    }
  }

  void clearProfile() {
    _name = '';
    _surname = '';
    _age = '';
    _gender = '';
    _isPregnant = false;
    notifyListeners();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _surname = prefs.getString('surname') ?? '';
    _age = prefs.getString('age') ?? '';
    _gender = prefs.getString('gender') ?? '';
    _isPregnant = prefs.getBool('pregnant') ?? false;
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('surname', _surname);
    await prefs.setString('age', _age);
    await prefs.setString('gender', _gender);
    await prefs.setBool('pregnant', _isPregnant);
  }
}
