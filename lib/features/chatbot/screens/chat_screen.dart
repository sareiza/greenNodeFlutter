import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/api_service.dart';

// ─── Colores puntuales ────────────────────────────────────────────────────────
const _userBubbleBg   = AppColors.primary;
const _userBubbleText = Colors.white;
const _botBubbleBg    = Colors.white;
const _botBubbleBorder = Color(0xFFE4EFE8);
const _botTextColor   = AppColors.ink;
const _chipBg         = Color(0xFFF1F7F3);
const _chipBorder     = Color(0xFFDDEAE1);
const _chipText       = AppColors.primary;
const _headerBg       = Colors.white;
const _headerBorder   = Color(0xFFE4EFE8);
const _inputBg        = Colors.white;
const _inputBorder    = Color(0xFFE4EFE8);
const _avatarBg       = AppColors.primary;
const _onlineDot      = Color(0xFF1B9E54);
// ─────────────────────────────────────────────────────────────────────────────

// ─── Quick replies ────────────────────────────────────────────────────────────
const _quickReplies = [
  '¿Qué es GreenNode?',
  '¿Cómo funciona el monitoreo?',
  '¿Cuántos árboles necesito?',
  '¿Cómo se calcula el CO₂?',
  '¿Qué especies siembran?',
];

// ─── Mensaje de bienvenida estático ──────────────────────────────────────────
const _welcomeText =
    '¡Hola! Soy Aura, tu asesor de reforestación 🌿\n\n'
    'Puedo ayudarte con información sobre tu proyecto, '
    'especies de árboles, cálculo de huella de CO₂ y mucho más.\n\n'
    '¿En qué puedo ayudarte hoy?';

// ─── Modelo ───────────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isTyping;
  final bool isError;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isTyping = false,
    this.isError  = false,
  });
}

// ─── Pantalla ─────────────────────────────────────────────────────────────────

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller    = TextEditingController();
  final _scrollCtrl    = ScrollController();
  bool  _waiting       = false;

  final List<_ChatMessage> _messages = [
    const _ChatMessage(text: _welcomeText, isUser: false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Envío ──────────────────────────────────────────────────────────────────

  Future<void> _send(String text) async {
    final msg = text.trim();
    if (msg.isEmpty || _waiting) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: msg, isUser: true));
      _messages.add(const _ChatMessage(text: '', isUser: false, isTyping: true));
      _waiting = true;
    });
    _scrollToBottom();

    try {
      final raw      = await apiService.preguntarAsesor(msg);
      final response = raw['response']?.toString()   ??
                       raw['content']?.toString()    ??
                       raw['reply']?.toString()      ??
                       raw['answer']?.toString()     ??
                       raw['text']?.toString()       ??
                       raw['aiResponse']?.toString() ??
                       raw['message']?.toString()    ?? '';

      _replaceTyping(_ChatMessage(
        text: response.isEmpty ? 'Sin respuesta del servidor.' : response,
        isUser: false,
      ));
    } catch (e) {
      _replaceTyping(_ChatMessage(
        text:    e.toString().replaceFirst('Exception: ', ''),
        isUser:  false,
        isError: true,
      ));
    }
  }

  void _replaceTyping(_ChatMessage botMsg) {
    setState(() {
      _messages.removeWhere((m) => m.isTyping);
      _messages.add(botMsg);
      _waiting = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          const _ChatHeader(),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _MessageBubble(msg: _messages[i]),
            ),
          ),
          _QuickReplies(
            enabled: !_waiting,
            onTap: _send,
          ),
          _InputBar(
            controller: _controller,
            enabled:    !_waiting,
            onSend:     () => _send(_controller.text),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
      decoration: const BoxDecoration(
        color: _headerBg,
        border: Border(bottom: BorderSide(color: _headerBorder, width: 1)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 42, height: 42,
            decoration: const BoxDecoration(color: _avatarBg, shape: BoxShape.circle),
            child: const Icon(Icons.eco_outlined, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aura',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7, height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: _onlineDot, shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Asesor IA · En línea',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 12, color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Burbujas ─────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage msg;
  const _MessageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (msg.isTyping) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BotAvatar(),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: _botBubbleBg,
                border: Border.all(color: _botBubbleBorder),
                borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(18),
                  topRight:    Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x08102A1C), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: const _TypingDots(),
            ),
          ],
        ),
      );
    }

    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: _userBubbleBg,
                  borderRadius: BorderRadius.only(
                    topLeft:     Radius.circular(18),
                    topRight:    Radius.circular(18),
                    bottomLeft:  Radius.circular(18),
                  ),
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 14, color: _userBubbleText, height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Bot bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isError ? const Color(0xFFFBEAE6) : _botBubbleBg,
                border: Border.all(
                  color: msg.isError
                      ? const Color(0xFFEDC5BD)
                      : _botBubbleBorder,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft:     Radius.circular(18),
                  topRight:    Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x08102A1C), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14,
                  color: msg.isError ? const Color(0xFFB3402A) : _botTextColor,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 30,
      decoration: const BoxDecoration(color: _avatarBg, shape: BoxShape.circle),
      child: const Icon(Icons.eco_outlined, size: 16, color: Colors.white),
    );
  }
}

// ─── Indicador de escritura ───────────────────────────────────────────────────

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _ctrl.addListener(() {
      final next = (_ctrl.value * 3).floor().clamp(0, 2);
      if (next != _active) setState(() => _active = next);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 5 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: i == _active ? AppColors.primary : AppColors.line,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Quick replies ────────────────────────────────────────────────────────────

class _QuickReplies extends StatelessWidget {
  final bool enabled;
  final void Function(String) onTap;
  const _QuickReplies({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _quickReplies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final text = _quickReplies[i];
          return GestureDetector(
            onTap: enabled ? () => onTap(text) : null,
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0.45,
              duration: const Duration(milliseconds: 200),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _chipBg,
                  border: Border.all(color: _chipBorder),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: enabled ? _chipText : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Barra de entrada ─────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: _inputBg,
        border: Border(top: BorderSide(color: _inputBorder, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                border: Border.all(color: AppColors.inputBorder),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: enabled ? (_) => onSend() : null,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 14, color: AppColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe tu pregunta…',
                  hintStyle: GoogleFonts.hankenGrotesk(
                    fontSize: 14, color: AppColors.placeholder,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 11,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón enviar
          AnimatedOpacity(
            opacity: enabled ? 1 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: enabled ? onSend : null,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.primary : AppColors.line,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
