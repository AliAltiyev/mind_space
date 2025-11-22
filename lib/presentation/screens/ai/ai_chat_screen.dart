import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/user_level_service.dart';
import '../../../core/api/groq_client.dart';

/// Экран чата с AI - Профессиональный дизайн в стиле отслеживания сна
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final UserLevelService _levelService = UserLevelService();
  final GroqClient _aiClient = GroqClient();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Анимации для экрана
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Современный AppBar
            _buildModernAppBar(isDark),

            // Список сообщений
            Expanded(
              child: _messages.isEmpty
                  ? _buildEmptyState(isDark)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return _AnimatedChatBubble(
                              message: _messages[index],
                              index: index,
                            );
                          },
                        ),
                      ),
                    ),
            ),

            // Поле ввода
            _buildInputArea(isDark),
          ],
        ),
      ),
    );
  }

  /// Современный AppBar в стиле sleep tracking
  Widget _buildModernAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: AppColors.textOnPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ai.chat.title'.tr(),
                  style: AppTypography.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ai.chat.subtitle'.tr(),
                  style: AppTypography.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _clearChat,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CupertinoIcons.arrow_clockwise,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Пустое состояние с анимацией
  Widget _buildEmptyState(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная иконка
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.sparkles,
                          color: AppColors.textOnPrimary,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'ai.chat.ready_to_help'.tr(),
                  style: AppTypography.h3.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'ai.chat.ask_any_question'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Быстрые действия
                _buildQuickActions(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Быстрые действия в стиле sleep tracking
  Widget _buildQuickActions(bool isDark) {
    final actions = [
      {
        'text': 'ai.chat.how_are_you'.tr(),
        'icon': CupertinoIcons.smiley,
        'onTap': () => _sendMessage('ai.chat.how_are_you'.tr()),
      },
      {
        'text': 'ai.chat.mood_analysis'.tr(),
        'icon': CupertinoIcons.chart_bar,
        'onTap': () => _sendMessage('ai.chat.analyze_my_mood'.tr()),
      },
      {
        'text': 'ai.chat.tips'.tr(),
        'icon': CupertinoIcons.lightbulb,
        'onTap': () => _sendMessage('ai.chat.give_tips_for_mood'.tr()),
      },
      {
        'text': 'ai.meditation.title'.tr(),
        'icon': CupertinoIcons.star,
        'onTap': () => _sendMessage('ai.chat.recommend_meditation'.tr()),
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _QuickActionCard(
            text: action['text'] as String,
            icon: action['icon'] as IconData,
            onTap: action['onTap'] as VoidCallback,
            isDark: isDark,
          ),
        );
      }).toList(),
    );
  }

  /// Область ввода в современном стиле
  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'ai.chat.placeholder'.tr(),
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) {
                  final text = _messageController.text.trim();
                  if (text.isNotEmpty && !_isLoading) {
                    _sendMessage(text);
                    _messageController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty && !_isLoading) {
                      _sendMessage(text);
                      _messageController.clear();
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: _isLoading
                    ? (isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant)
                    : null,
                borderRadius: BorderRadius.circular(26),
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    )
                  : const Icon(
                      CupertinoIcons.paperplane_fill,
                      color: AppColors.textOnPrimary,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
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

      _scrollToBottom();
    } catch (e) {
      print('❌ Ошибка генерации AI ответа: $e');

      setState(() {
        _isLoading = false;

        // Используем метод для получения понятного сообщения об ошибке
        final errorMessage = _getUserFriendlyErrorMessage(e);

        // Добавляем сообщение об ошибке в чат
        _messages.add(
          ChatMessage(
            text: errorMessage,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();
    }
  }

  /// Генерация ответа AI через Groq API
  Future<String> _generateAiResponse(String userMessage) async {
    try {
      // Получаем текущий язык приложения из локализации
      final currentLocale =
          EasyLocalization.of(context)?.locale ?? const Locale('en');
      final languageCode = currentLocale.languageCode;

      // Маппинг языков для AI промпта
      final languageMap = {'en': 'English', 'ru': 'Russian'};

      final targetLanguage = languageMap[languageCode] ?? 'English';

      // Формируем системный промпт для AI
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

      // Отправляем запрос к Groq API
      final response = await _aiClient.generateContentWithRetry(
        model: GroqApiConstants.defaultModel,
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      if (response.content.isNotEmpty) {
        return response.content;
      } else {
        // Fallback на простые ответы
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('❌ Ошибка генерации AI ответа: $e');
      rethrow;
    }
  }

  /// Получить понятное сообщение об ошибке для пользователя
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString();

    if (errorString.contains('API ключ Groq не настроен') ||
        errorString.contains('api key') ||
        errorString.contains('API key')) {
      return '⚠️ API ключ Groq не настроен.\n\n'
          'Для использования AI чата необходимо:\n'
          '1. Получить бесплатный ключ на https://console.groq.com/keys\n'
          '2. Добавить его в lib/core/api/groq_client.dart\n\n'
          'После настройки перезапустите приложение.';
    }

    if (errorString.contains('400') ||
        errorString.contains('Неверный формат запроса')) {
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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('ai.chat.clear_chat'.tr()),
        content: Text('ai.chat.clear_chat_confirm'.tr()),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
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

/// Анимированный пузырек сообщения
class _AnimatedChatBubble extends StatefulWidget {
  final ChatMessage message;
  final int index;

  const _AnimatedChatBubble({required this.message, required this.index});

  @override
  State<_AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<_AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.message.isUser ? 0.2 : -0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _ChatBubble(message: widget.message),
        ),
      ),
    );
  }
}

/// Пузырек сообщения в современном стиле
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: message.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!message.isUser) ...[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: AppColors.textOnPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: message.isUser
                  ? const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: message.isUser
                  ? null
                  : (isDark ? AppColors.darkSurface : Colors.white),
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: message.isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(6),
                bottomRight: message.isUser
                    ? const Radius.circular(6)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: message.isUser
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
              border: !message.isUser && isDark
                  ? Border.all(color: AppColors.darkBorder, width: 1)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: message.isUser
                        ? AppColors.textOnPrimary
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: message.isUser
                        ? AppColors.textOnPrimary.withOpacity(0.7)
                        : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (message.isUser) ...[
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              CupertinoIcons.person_fill,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

/// Карточка быстрого действия в стиле sleep tracking
class _QuickActionCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _QuickActionCard({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkSurface, AppColors.darkSurfaceVariant]
                : [Colors.white, AppColors.surfaceVariant],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
