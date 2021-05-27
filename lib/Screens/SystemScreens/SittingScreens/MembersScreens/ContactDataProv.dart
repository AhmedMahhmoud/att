import 'package:flutter/cupertino.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class ContactService with ChangeNotifier {
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  void getPhoneNumber(String phoneNumber, String name) async {
    PhoneNumber number2 = await PhoneNumber.getRegionInfoFromPhoneNumber(
        phoneNumber, number.isoCode);
    print(number2);
    notifyListeners();
  }
}
