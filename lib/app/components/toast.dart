import 'package:flutter/material.dart';

//Toast Control de posición de pantalla
enum ToastPostion {
  top,
  center,
  bottom,
}

class Toast {
// Toast se agrega a la pantalla  static OverlayEntry _overlayEntry;
  static OverlayEntry? _overlayEntry;
  // toast showing
  static bool _showing = false;
  // Comience uno nuevo toast Hora actual，Se usa para comparar si se ha mostrado suficiente tiempo
  static DateTime? _startedTime;
  static String? _msg;
  static int? _showTime;
  static Color? _bgColor;
  static Color? _textColor;
  static double? _textSize;
  // Mostrar ubicación
  static ToastPostion? _toastPosition;
  // Márgenes izquierdo y derecho
  static double? _pdHorizontal;
  // Márgenes superior e inferior
  static double? _pdVertical;
  static void toast(
    BuildContext context, {
    //Texto visualizado
    String? msg,
    //Tiempo visualizado Unidad de milisegundos
    int showTime = 1000,
    Color bgColor = Colors.black,
    Color textColor = Colors.white,
    double textSize = 14.0,
    //Mostrar ubicación
    ToastPostion position = ToastPostion.center,
    //El relleno horizontal del texto.
    double pdHorizontal = 20.0,
    //El relleno vertical del texto.
    double pdVertical = 10.0,
  }) async {
    assert(msg != null);
    _msg = msg;
    _startedTime = DateTime.now();
    _showTime = showTime;
    _bgColor = bgColor;
    _textColor = textColor;
    _textSize = textSize;
    _toastPosition = position;
    _pdHorizontal = pdHorizontal;
    _pdVertical = pdVertical;
    //Obtener OverlayState
    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      //OverlayEntry es responsable de construir el diseño
      //Inserte el diseño construido en la capa superior del diseño a través de OverlayEntry
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
            //valor superior, puede cambiar este valor para cambiar la posición del toast en la pantalla
            top: buildToastPosition(context),
                child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: AnimatedOpacity(
                        opacity: _showing ? 1.0 : 0.0, //Transparencia objetivo
                        duration: _showing
                            ? const Duration(milliseconds: 100)
                            : const Duration(milliseconds: 400),
                        child: _buildToastWidget(),
                      ),
                    )),
              ));
      //Insertar en la capa superior del diseño
      overlayState.insert(_overlayEntry!);
    } else {
      //Vuelva a dibujar la interfaz de usuario, similar a setState
      _overlayEntry?.markNeedsBuild();
    }
    // tiempo de espera
    await Future.delayed(Duration(milliseconds: _showTime!));
    //Después de 2 segundos Desaparecer al final
    if (DateTime.now().difference(_startedTime!).inMilliseconds >= _showTime!) {
      _showing = false;
      _overlayEntry?.markNeedsBuild();
      await Future.delayed(const Duration(milliseconds: 400));
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  //toast dibujar
  static _buildToastWidget() {
    return Center(
      child: Card(
        color: _bgColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: _pdHorizontal!, vertical: _pdVertical!),
          child: Text(
            _msg!,
            style: TextStyle(
              fontSize: _textSize,
              color: _textColor,
            ),
          ),
        ),
      ),
    );
  }

//  Establecer ubicación de toast
  static buildToastPosition(context) {
    double backResult;
    if (_toastPosition == ToastPostion.top) {
      backResult = MediaQuery.of(context).size.height * 1 / 4;
    } else if (_toastPosition == ToastPostion.center) {
      backResult = MediaQuery.of(context).size.height * 2 / 5;
    } else {
      backResult = MediaQuery.of(context).size.height * 3 / 4;
    }
    return backResult;
  }
}
