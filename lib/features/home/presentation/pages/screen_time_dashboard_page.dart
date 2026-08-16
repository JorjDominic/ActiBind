import 'package:actibind/core/constants/app_constants.dart';
import 'package:actibind/core/theme/app_colors.dart';
import 'package:actibind/features/insights/services/insight_service.dart';
import 'package:actibind/shared/widgets/app_page_header.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class ScreenTimeDashboardPage extends StatelessWidget {
  const ScreenTimeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppPageHeader(
            title: 'Insights',
            subtitle:
                'Long-term patterns and recommendations from your activity',
          ),
          const SizedBox(height: 14),
          const _InsightsRangeSelector(),
          const SizedBox(height: 18),
          const _AiDailyInsight(),
          const SizedBox(height: 20),
          const AppSectionHeader(
            title: 'Progress',
            subtitle: 'How your current habits compare with your goals',
          ),
          const SizedBox(height: 11),
          const _MetricCard(
            label: 'Usage Today',
            value: '4h 12m',
            subtitle: 'of 6h',
            showCircle: true,
            accent: AppColors.indigo,
          ),
          const SizedBox(height: 16),
          const _MetricCard(
            label: 'Weekly Average',
            value: 'T: 4h',
            subtitle: 'Goal progress and trends',
            showBars: true,
            accent: AppColors.teal,
          ),
          const SizedBox(height: 16),
          const _MetricCard(
            label: 'Goal Progress',
            value: '80%',
            subtitle: 'Screen Detox',
            showProgress: true,
            accent: AppColors.amber,
          ),
          const SizedBox(height: 16),
          const AppSectionHeader(
            title: 'Patterns',
            subtitle: 'When your focus tends to be strongest',
          ),
          const SizedBox(height: 11),
          shad.Card(
            filled: true,
            fillColor: AppColors.amber.withValues(alpha: .07),
            borderColor: AppColors.amber.withValues(alpha: .2),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productive peak hours',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your strongest focus window is 9:00 AM–11:30 AM.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 112,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _DayBar(index: .45),
                        _DayBar(index: .7),
                        _DayBar(index: .9),
                        _DayBar(index: 1),
                        _DayBar(index: .75),
                        _DayBar(index: .5),
                        _DayBar(index: .4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          shad.Card(
            filled: true,
            fillColor: AppColors.indigo.withValues(alpha: .07),
            borderColor: AppColors.indigo.withValues(alpha: .2),
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.indigo,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ask ActiBind',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Turn your activity patterns into practical next steps.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Open insights assistant',
                    onPressed: () => _showInsightsChat(context),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsightsChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const FractionallySizedBox(
        heightFactor: .82,
        child: _InsightsChatSheet(),
      ),
    );
  }
}

class _AiDailyInsight extends StatefulWidget {
  const _AiDailyInsight();

  @override
  State<_AiDailyInsight> createState() => _AiDailyInsightState();
}

class _AiDailyInsightState extends State<_AiDailyInsight> {
  String? _insight;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final insight = await InsightService.generateDailyInsight();
      if (mounted) setState(() => _insight = insight);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => shad.Card(
    filled: true,
    fillColor: AppColors.teal.withValues(alpha: .09),
    borderColor: AppColors.teal.withValues(alpha: .2),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daily Insight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ),
              if (_failed || _insight != null)
                IconButton(
                  tooltip: _failed ? 'Retry insight' : 'Refresh insight',
                  onPressed: _loading ? null : _load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading && _insight == null)
            const LinearProgressIndicator()
          else
            Text(
              _failed && _insight == null
                  ? 'Daily insight is unavailable. Check your connection and try again.'
                  : _insight!,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
        ],
      ),
    ),
  );
}

class _InsightsRangeSelector extends StatefulWidget {
  const _InsightsRangeSelector();

  @override
  State<_InsightsRangeSelector> createState() => _InsightsRangeSelectorState();
}

class _InsightsRangeSelectorState extends State<_InsightsRangeSelector> {
  String range = 'Week';

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: 'Week', label: Text('This Week')),
          ButtonSegment(value: 'Month', label: Text('This Month')),
        ],
        selected: {range},
        onSelectionChanged: (value) => setState(() => range = value.first),
      ),
    );
  }
}

class _InsightsChatSheet extends StatefulWidget {
  const _InsightsChatSheet();

  @override
  State<_InsightsChatSheet> createState() => _InsightsChatSheetState();
}

class _InsightsChatSheetState extends State<_InsightsChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_InsightMessage>[
    const _InsightMessage(
      text:
          'I can help you understand your focus patterns, screen time, and daily goals. What would you like to explore?',
      isUser: false,
    ),
  ];
  bool _sending = false;

  static const _suggestions = [
    'When do I focus best?',
    'How can I reduce screen time?',
    'Summarize my week',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggestion]) async {
    final text = (suggestion ?? _controller.text).trim();
    if (text.isEmpty || _sending) return;
    final history = _messages
        .skip(1)
        .map(
          (message) => InsightChatMessage(
            role: message.isUser ? 'user' : 'assistant',
            content: message.text,
          ),
        )
        .toList(growable: false);
    _controller.clear();
    setState(() {
      _messages.add(_InsightMessage(text: text, isUser: true));
      _sending = true;
    });
    _scrollToBottom();
    try {
      final reply = await InsightService.ask(question: text, history: history);
      if (mounted) {
        setState(
          () => _messages.add(_InsightMessage(text: reply, isUser: false)),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _messages.add(
            const _InsightMessage(
              text:
                  'I could not generate an insight right now. Check your connection and try again.',
              isUser: false,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.indigo.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: AppColors.indigo,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insights Assistant',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text(
                      'Uses your ActiBind activity data',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _ChatBubble(message: _messages[index]),
                ),
              ),
              if (_sending)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),
        ),
        if (_messages.length == 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: [
                for (final suggestion in _suggestions) ...[
                  ActionChip(
                    label: Text(suggestion),
                    avatar: const Icon(Icons.arrow_outward_rounded, size: 16),
                    onPressed: _sending ? null : () => _send(suggestion),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              10 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ask about your activity...',
                prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Send',
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send_rounded),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InsightMessage {
  const _InsightMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _InsightMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: message.isUser
              ? colors.primary
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(17),
            topRight: const Radius.circular(17),
            bottomLeft: Radius.circular(message.isUser ? 17 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 17),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? colors.onPrimary : colors.onSurface,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    this.showCircle = false,
    this.showBars = false,
    this.showProgress = false,
    required this.accent,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool showCircle;
  final bool showBars;
  final bool showProgress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return shad.Card(
      borderColor: accent.withValues(alpha: .22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            if (showCircle)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: 0.7,
                        strokeWidth: 12,
                        color: accent,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(subtitle),
                      ],
                    ),
                  ],
                ),
              )
            else if (showBars)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (index) =>
                          _DayBar(index: index == 3 ? 1.0 : 0.6, color: accent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(subtitle),
                ],
              )
            else if (showProgress)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: 0.8, color: accent),
                  const SizedBox(height: 8),
                  Text(subtitle),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(subtitle),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({required this.index, this.color});

  final double index;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 100 * index,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
