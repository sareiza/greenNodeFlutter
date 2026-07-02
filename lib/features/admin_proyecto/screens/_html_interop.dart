// Selector de plataforma para dart:html.
// Web  → dart:html real.
// Móvil/Desktop → stubs vacíos (el admin no sube fotos desde móvil).
export 'dart:html' if (dart.library.io) '_html_stub.dart';
