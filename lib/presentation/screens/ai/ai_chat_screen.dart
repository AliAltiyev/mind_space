import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/user_level_service.dart';

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
    _messages.add(ChatMessage(
      text: "Привет! Я ваш ИИ-помощник для отслеживания настроения. Как дела? Могу помочь с анализом ваших эмоций, дать советы по улучшению настроения или просто поговорить! 😊",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            const Text('AI Помощник'),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearChat,
            tooltip: 'Очистить чат',
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Быстрые вопросы',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickActionChip(
                text: 'Как дела?',
                onTap: () => _sendMessage('Как дела?'),
              ),
              _QuickActionChip(
                text: 'Анализ настроения',
                onTap: () => _sendMessage('Проанализируй мое настроение'),
              ),
              _QuickActionChip(
                text: 'Советы',
                onTap: () => _sendMessage('Дай советы для улучшения настроения'),
              ),
              _QuickActionChip(
                text: 'Медитация',
                onTap: () => _sendMessage('Рекомендуй медитацию'),
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
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Помощник готов помочь!',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Задайте любой вопрос о настроении или попросите совета',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Область ввода
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Введите сообщение...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textHint,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
              onPressed: _isLoading ? null : _sendCurrentMessage(),
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
  VoidCallback _sendCurrentMessage() {
    return () {
      final text = _messageController.text.trim();
      if (text.isNotEmpty && !_isLoading) {
        _sendMessage(text);
        _messageController.clear();
      }
    };
  }

  /// Отправка сообщения
  Future<void> _sendMessage(String text) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    // Начисляем опыт за использование AI чата
    await _levelService.addExperienceForAIChat();

    _scrollToBottom();

    // Имитация ответа AI (в реальном приложении здесь будет вызов AI сервиса)
    await Future.delayed(const Duration(seconds: 1));

    final aiResponse = await _generateAiResponse(text);

    setState(() {
      _messages.add(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isLoading = false;
    });

    _scrollToBottom();
  }

  /// Генерация ответа AI (заглушка)
  Future<String> _generateAiResponse(String userMessage) async {
    // Простая логика ответов (в реальном приложении здесь будет AI сервис)
    final message = userMessage.toLowerCase();
    
    if (message.contains('как дела') || message.contains('привет')) {
      return "Привет! У меня все отлично, спасибо! 😊 А как дела у вас? Как настроение сегодня?";
    }
    
    if (message.contains('настроение') || message.contains('анализ')) {
      return "Я могу проанализировать ваше настроение на основе ваших записей! 📊 Расскажите, как вы себя чувствуете сегодня? Или добавьте запись настроения, и я дам подробный анализ ваших эмоциональных паттернов.";
    }
    
    if (message.contains('совет') || message.contains('помощь')) {
      return "Конечно помогу! 💡 Вот несколько советов для улучшения настроения:\n\n• Сделайте глубокий вдох и выдох\n• Прогуляйтесь на свежем воздухе\n• Послушайте любимую музыку\n• Запишите 3 вещи, за которые вы благодарны\n• Сделайте что-то приятное для себя\n\nЧто из этого вам больше подходит?";
    }
    
    if (message.contains('медитац') || message.contains('расслабить')) {
      return "Медитация - отличный способ улучшить настроение! 🧘‍♀️\n\nПопробуйте:\n• 5-минутную медитацию осознанности\n• Дыхательные упражнения\n• Прогрессивную мышечную релаксацию\n• Медитацию благодарности\n\nХотите, чтобы я рассказал подробнее о каком-то из этих методов?";
    }
    
    if (message.contains('плохо') || message.contains('грустно')) {
      return "Понимаю, что вам сейчас непросто. 💙 Помните, что плохие дни - это нормально, и они проходят. Попробуйте:\n\n• Поговорить с близким человеком\n• Сделать что-то приятное для себя\n• Записать свои чувства\n• Обратиться за профессиональной помощью, если нужно\n\nВы не одни в этом. Хотите поговорить об этом подробнее?";
    }
    
    // Общий ответ
    return "Интересный вопрос! 🤔 Я здесь, чтобы помочь вам с вопросами о настроении, эмоциях и психическом благополучии. Могу проанализировать ваши записи настроения, дать советы или просто поддержать в разговоре. О чем бы вы хотели поговорить?";
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
        title: const Text('Очистить чат'),
        content: const Text('Вы уверены, что хотите очистить всю историю чата?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
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
            child: const Text('Очистить'),
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
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: message.isUser 
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTypography.caption.copyWith(
                      color: message.isUser 
                          ? Colors.white70
                          : AppColors.textHint,
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

  const _QuickActionChip({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
