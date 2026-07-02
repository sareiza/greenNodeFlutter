// Stubs de dart:html usados solo en el panel admin.
// En móvil/desktop estos métodos no hacen nada útil —
// el admin siempre opera desde la web.

class File {
  final String name;
  final int size;
  File(this.name, [this.size = 0]);
}

class FileUploadInputElement {
  String accept = '';
  List<File>? files;
  void setAttribute(String name, String value) {}
  void click() {}
  Stream<dynamic> get onChange => const Stream.empty();
}

class FileReader {
  dynamic result;
  void readAsArrayBuffer(File file) {}
  Stream<dynamic> get onLoad => const Stream.empty();
  Stream<dynamic> get onError => const Stream.empty();
}
