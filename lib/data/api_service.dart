import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  static const _base = 'http://52.15.104.117/api';
  static String? _token;

  static String? get token => _token;
  static void clearToken() => _token = null;

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  dynamic _parseResponse(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      // body no es JSON (HTML de error, texto plano, etc.)
    }
    if (response.statusCode >= 400) {
      final msg = body?['message']?.toString() ??
          body?['error']?.toString() ??
          'Error ${response.statusCode}';
      throw Exception(msg);
    }
    if (body == null) throw Exception('Respuesta inesperada del servidor');
    return body['data'] ?? body;
  }

  // ── AUTH ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_base/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _parseResponse(resp) as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> datos) async {
    final resp = await http.post(
      Uri.parse('$_base/auth/register'),
      headers: _headers,
      body: jsonEncode(datos),
    );
    final data = _parseResponse(resp) as Map<String, dynamic>;
    _token = data['token'] as String?;
    return data;
  }

  // ── COTIZACIONES ──────────────────────────────────────────────────────────

  Future<List<dynamic>> getCotizaciones() async {
    final resp = await http.get(Uri.parse('$_base/quotes'), headers: _authHeaders);
    return _parseResponse(resp) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getCotizacionById(String id) async {
    final resp = await http.get(Uri.parse('$_base/quotes/$id'), headers: _authHeaders);
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> crearCotizacion(Map<String, dynamic> datos) async {
    final resp = await http.post(
      Uri.parse('$_base/quotes'),
      headers: _authHeaders,
      body: jsonEncode(datos),
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> aprobarCotizacion(String id) async {
    final resp = await http.put(
      Uri.parse('$_base/quotes/$id/approve'),
      headers: _authHeaders,
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rechazarCotizacion(String id, {String reason = 'Rechazada por el administrador'}) async {
    final resp = await http.put(
      Uri.parse('$_base/quotes/$id/reject'),
      headers: _authHeaders,
      body: jsonEncode({'reason': reason}),
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  // ── PROYECTOS ─────────────────────────────────────────────────────────────

  Future<List<dynamic>> getProyectos() async {
    final resp = await http.get(Uri.parse('$_base/projects'), headers: _authHeaders);
    return _parseResponse(resp) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getProyectoById(String id) async {
    final resp = await http.get(Uri.parse('$_base/projects/$id'), headers: _authHeaders);
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> actualizarProgreso(String id, int validatedTreeCount) async {
    final resp = await http.put(
      Uri.parse('$_base/projects/$id/progress'),
      headers: _authHeaders,
      body: jsonEncode({'validatedTreeCount': validatedTreeCount}),
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> subirEvidencia(
      String projectId, List<int> bytes, String fileName) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_base/projects/$projectId/evidences'));
    if (_token != null) request.headers['Authorization'] = 'Bearer $_token';
    final ext = fileName.split('.').last.toLowerCase();
    final mime = switch (ext) {
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      'png'           => MediaType('image', 'png'),
      'gif'           => MediaType('image', 'gif'),
      'webp'          => MediaType('image', 'webp'),
      _               => MediaType('image', 'jpeg'),
    };
    request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName, contentType: mime));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _parseResponse(response) as Map<String, dynamic>;
  }

  // ── EVIDENCIAS ────────────────────────────────────────────────────────────

  Future<List<dynamic>> getEvidencias(String projectId) async {
    final resp = await http.get(
      Uri.parse('$_base/projects/$projectId/evidences'),
      headers: _authHeaders,
    );
    return _parseResponse(resp) as List<dynamic>;
  }

  // ── EMPRESAS ──────────────────────────────────────────────────────────────

  Future<List<dynamic>> getEmpresas() async {
    final resp = await http.get(Uri.parse('$_base/companies'), headers: _authHeaders);
    return _parseResponse(resp) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getEmpresaById(String id) async {
    final resp = await http.get(Uri.parse('$_base/companies/$id'), headers: _authHeaders);
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  // ── TERRITORIOS ───────────────────────────────────────────────────────────

  Future<List<dynamic>> getTerritorios() async {
    final resp = await http.get(Uri.parse('$_base/territories'), headers: _headers);
    return _parseResponse(resp) as List<dynamic>;
  }

  // ── DASHBOARD ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final resp = await http.get(
      Uri.parse('$_base/dashboard'),
      headers: _authHeaders,
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  // ── CERTIFICADOS ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCertificado(String projectId) async {
    final resp = await http.get(
      Uri.parse('$_base/certificates/$projectId'),
      headers: _authHeaders,
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }

  // ── ASESOR IA ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> preguntarAsesor(String mensaje) async {
    final resp = await http.post(
      Uri.parse('$_base/advisor'),
      headers: _authHeaders,
      body: jsonEncode({'question': mensaje}),
    );
    return _parseResponse(resp) as Map<String, dynamic>;
  }
}

final apiService = ApiService();
