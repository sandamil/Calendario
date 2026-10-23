import 'package:flutter_test/flutter_test.dart';
import 'package:calendario2/config/util/hexColor.dart';

void main() {
  test('HexColor adds full opacity to six-digit hex colors', () {
    expect(HexColor('#FF0000').value, 0xFFFF0000);
  });

  test('HexColor accepts eight-digit ARGB colors', () {
    expect(HexColor('#8000FF00').value, 0x8000FF00);
  });
}
