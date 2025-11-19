import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/user_level_service.dart';
import '../../../core/api/groq_client.dart';

/// Экран чата с AI - простой и понятный дизайн
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final UserLevelService _levelService = UserLevelService();
  final GroqClient _aiClient = GroqClient();

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Добавить приветственное сообщение
  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        text: "ai.chat.welcome_message".tr(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text('ai.chat.title'.tr()),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: 'ai.chat.clear_chat'.tr(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Быстрые действия
          _buildQuickActions(),

          // Список сообщений
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _ChatBubble(message: _messages[index]);
                    },
                  ),
          ),

          // Поле ввода
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Быстрые действия
  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ai.chat.quick_questions'.tr(),
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                text: 'ai.chat.how_are_you'.tr(),
                onTap: () => _sendMessage('ai.chat.how_are_you'.tr()),
              ),
              _QuickActionChip(
                text: 'ai.chat.mood_analysis'.tr(),
                onTap: () => _sendMessage('ai.chat.analyze_my_mood'.tr()),
              ),
              _QuickActionChip(
                text: 'ai.chat.tips'.tr(),
                onTap: () => _sendMessage('ai.chat.give_tips_for_mood'.tr()),
              ),
              _QuickActionChip(
                text: 'ai.meditation.title'.tr(),
                onTap: () => _sendMessage('ai.chat.recommend_meditation'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Пустое состояние
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              return Column(
                children: [
                  Text(
                    'ai.chat.ready_to_help'.tr(),
                    style: AppTypography.h3.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ai.chat.ask_any_question'.tr(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Область ввода
  Widget _buildInputArea() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withOpacity(0.1) : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'ai.chat.placeholder'.tr(),
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: isDark ? Colors.white70 : AppColors.textHint,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : AppColors.border,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCurrentMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendCurrentMessage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Отправка текущего сообщения
  void _sendCurrentMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && !_isLoading) {
      _sendMessage(text);
      _messageController.clear();
    }
  }

  /// Отправка сообщения
  Future<void> _sendMessage(String text) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });

    // Начисляем опыт за использование AI чата
    await _levelService.addExperienceForAIChat();

    _scrollToBottom();

    try {
      // Генерация ответа AI через Groq API
      final aiResponse = await _generateAiResponse(text);

      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      // В случае ошибки показываем понятное сообщение пользователю
      String errorMessage = _getUserFriendlyErrorMessage(e);

      setState(() {
        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  /// Генерация ответа AI через Groq API
  Future<String> _generateAiResponse(String userMessage) async {
    try {
      // Получаем текущий язык приложения из локализации
      final currentLocale =
          EasyLocalization.of(context)?.locale ?? const Locale('en');
      final languageCode = currentLocale.languageCode;

      // Маппинг языков для AI промпта (названия языков на английском для лучшего понимания AI)
      final languageMap = {
        'en': 'English',
        'ru': 'Russian',
        'es': 'Spanish',
        'fr': 'French',
        'hi': 'Hindi',
        'tk': 'Turkmen',
        'tr': 'Turkish',
        'zh': 'Chinese',
      };

      final targetLanguage = languageMap[languageCode] ?? 'English';

      // Формируем системный промпт для AI с явным указанием языка
      // Используем английский для промпта, чтобы AI лучше понимал инструкции
      final systemPrompt =
          '''You are a friendly AI assistant for the Mind Space mood tracking app.
Your task is to help users with questions about mood, emotions, and mental well-being.
Answer briefly, friendly, and supportively. Use emojis for expressiveness.

CRITICAL LANGUAGE REQUIREMENT:
- You MUST respond ONLY in $targetLanguage language.
- Always use $targetLanguage, regardless of the language the user writes in.
- If the user writes in a different language, still respond in $targetLanguage.
- Never switch to another language, even if the user asks you to.
- Your responses must be 100% in $targetLanguage.''';

      // Формируем историю сообщений
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ];

      // Отправляем запрос к Groq API (бесплатный и быстрый)
      final response = await _aiClient.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      if (response.content.isNotEmpty) {
        return response.content;
      } else {
        // Fallback на простые ответы, если API не вернул контент
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('❌ Ошибка генерации AI ответа: $e');
      // Пробрасываем ошибку выше для обработки
      rethrow;
    }
  }

  /// Получить понятное сообщение об ошибке для пользователя
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('400') ||
        errorString.contains('Неверный формат запроса') ||
        errorString.contains('API ключ Groq не настроен')) {
      return '${'ai.chat.error_invalid_key'.tr()}\n\n${'ai.chat.get_groq_key'.tr()}';
    }

    if (errorString.contains('402') ||
        errorString.contains('Недостаточно средств')) {
      return 'ai.chat.error_payment_required'.tr();
    }

    if (errorString.contains('401') ||
        errorString.contains('Неверный API ключ') ||
        errorString.contains('Groq')) {
      return '${'ai.chat.error_invalid_key'.tr()}\n\n${'ai.chat.get_groq_key'.tr()}';
    }

    if (errorString.contains('403') ||
        errorString.contains('Доступ запрещен')) {
      return 'ai.chat.error_access_denied'.tr();
    }

    if (errorString.contains('429') || errorString.contains('лимит')) {
      return 'ai.chat.error_rate_limit'.tr();
    }

    if (errorString.contains('время ожидания') ||
        errorString.contains('timeout')) {
      return 'ai.chat.error_timeout'.tr();
    }

    if (errorString.contains('сервер') || errorString.contains('server')) {
      return 'ai.chat.error_server'.tr();
    }

    // Общая ошибка
    return 'ai.chat.error_general'.tr();
  }

  /// Fallback ответы при ошибке API
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('как дела') ||
        message.contains('привет') ||
        message.contains('hello') ||
        message.contains('hi')) {
      return 'ai.chat.response_greeting'.tr();
    }

    if (message.contains('настроение') ||
        message.contains('анализ') ||
        message.contains('mood') ||
        message.contains('analysis')) {
      return 'ai.chat.response_mood_analysis'.tr();
    }

    if (message.contains('совет') ||
        message.contains('помощь') ||
        message.contains('advice') ||
        message.contains('help')) {
      return 'ai.chat.response_tips'.tr();
    }

    if (message.contains('медитац') ||
        message.contains('расслабить') ||
        message.contains('meditation') ||
        message.contains('relax')) {
      return 'ai.chat.response_meditation'.tr();
    }

    if (message.contains('плохо') ||
        message.contains('грустно') ||
        message.contains('bad') ||
        message.contains('sad')) {
      return 'ai.chat.response_sad'.tr();
    }

    // Общий ответ
    return 'ai.chat.response_general'.tr();
  }

  /// Прокрутка вниз
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Очистка чата
  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ai.chat.clear_chat'.tr()),
        content: Text('ai.chat.clear_chat_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text('common.clear'.tr()),
          ),
        ],
      ),
    );
  }
}

/// Сообщение чата
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Пузырек сообщения
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primary
                    : (isDark
                          ? Colors.white.withOpacity(0.05)
                          : AppColors.surface),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: isDark ? null : AppColors.cardShadow,
                border: isDark && !message.isUser
                    ? Border.all(color: Colors.white.withOpacity(0.1))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: message.isUser
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.caption.copyWith(
                      color: message.isUser
                          ? Colors.white70
                          : (isDark ? Colors.white70 : AppColors.textHint),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Чип быстрого действия
class _QuickActionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _QuickActionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
