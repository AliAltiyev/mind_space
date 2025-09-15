import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../domain/entities/mood_entry.dart';
import '../bloc/mood_tracking_bloc.dart';
import '../bloc/mood_tracking_event.dart';

class AddMoodPage extends StatefulWidget {
  final MoodLevel? initialMood;

  const AddMoodPage({super.key, this.initialMood});

  @override
  State<AddMoodPage> createState() => _AddMoodPageState();
}

class _AddMoodPageState extends State<AddMoodPage> {
  final TextEditingController _noteController = TextEditingController();
  MoodLevel _selectedMood = MoodLevel.neutral;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMood != null) {
      _selectedMood = widget.initialMood!;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Записать настроение',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodSelector(),
            const SizedBox(height: 32),
            _buildNoteSection(),
            const SizedBox(height: 32),
            _buildVoiceNoteSection(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Как вы себя чувствуете?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.map((mood) {
              final isSelected = _selectedMood == mood;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getMoodColor(mood)
                        : _getMoodColor(mood).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getMoodColor(mood)
                          : _getMoodColor(mood).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        mood.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : _getMoodColor(mood),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Расскажите подробнее (необязательно)',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Что повлияло на ваше настроение?',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF999999)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF007AFF)),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Голосовая запись',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isListening ? null : _startListening,
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.white,
                  ),
                  label: Text(
                    _isListening ? 'Слушаю...' : 'Начать запись',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF007AFF),
                    foregroundColor: _isListening ? Colors.red : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (_isListening) ...[
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _stopListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.stop),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveMoodEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Сохранить',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Color _getMoodColor(MoodLevel mood) {
    switch (mood) {
      case MoodLevel.verySad:
        return const Color(0xFF6B46C1);
      case MoodLevel.sad:
        return const Color(0xFF3B82F6);
      case MoodLevel.neutral:
        return const Color(0xFF6B7280);
      case MoodLevel.happy:
        return const Color(0xFF10B981);
      case MoodLevel.veryHappy:
        return const Color(0xFFF59E0B);
    }
  }

  Future<void> _startListening() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showSnackBar('Разрешение на использование микрофона не предоставлено');
      return;
    }

    setState(() => _isListening = true);

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _noteController.text = result.recognizedWords;
        });
      },
      localeId: 'ru_RU',
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _saveMoodEntry() {
    // _selectedMood уже инициализирован, проверка не нужна

    setState(() => _isLoading = true);

    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mood: _selectedMood,
      note: _noteController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<MoodTrackingBloc>().add(AddMoodEntry(entry));

    // Имитируем задержку для UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context);
        _showSnackBar('Настроение записано!');
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF007AFF),
      ),
    );
  }
}
