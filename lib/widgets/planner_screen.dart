import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/planner_data.dart';
import '../providers/planner_provider.dart';
import '../providers/settings_provider.dart';
import '../theme.dart';
import 'animated_fab_icons.dart';
import 'settings_modal.dart';

String koreanWeekday(DateTime date) {
  const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  return weekdays[date.weekday - 1];
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 780;
        final planner = context.watch<PlannerProvider>();
        final topInset = MediaQuery.paddingOf(context).top;
        final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 14 : 20,
                      isCompact ? topInset + (isKeyboardOpen ? 20 : 104) : 40,
                      isCompact ? 14 : 20,
                      isKeyboardOpen ? 24 : 158,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isCompact) ...[
                              const _DesktopDateHeader(),
                              const SizedBox(height: 30),
                            ],
                            if (planner.isLoading)
                              const _LoadingPanel()
                            else
                              _PlannerGrid(isCompact: isCompact),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (isCompact)
                Positioned(
                  top: topInset + 12,
                  left: 12,
                  child: IgnorePointer(
                    ignoring: isKeyboardOpen,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: isKeyboardOpen ? 0 : 1,
                      child: const _MobileDateDock(),
                    ),
                  ),
                ),
              Positioned(
                top: isCompact ? topInset + 12 : 20,
                right: isCompact ? 18 : 24,
                child: IgnorePointer(
                  ignoring: isKeyboardOpen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isKeyboardOpen ? 0 : 1,
                    child: _FloatingControls(isCompact: isCompact),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 16,
                child: IgnorePointer(
                  ignoring: isKeyboardOpen,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: isKeyboardOpen ? 0 : 1,
                    child: const _ActionBar(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlannerGrid extends StatelessWidget {
  const _PlannerGrid({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrioritiesCard(),
          SizedBox(height: 18),
          TimeBlockCard(),
          SizedBox(height: 18),
          PomodoroCard(),
          SizedBox(height: 18),
          FeedbackCard(),
        ],
      );
    }

    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [PrioritiesCard(), SizedBox(height: 30), TimeBlockCard()],
          ),
        ),
        SizedBox(width: 30),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [PomodoroCard(), SizedBox(height: 30), FeedbackCard()],
          ),
        ),
      ],
    );
  }
}

class _DesktopDateHeader extends StatelessWidget {
  const _DesktopDateHeader();

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final date = planner.currentDate;
    final dateText = plannerDateKey(date);
    final weekday = koreanWeekday(date);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _DateArrowButton(
              icon: Icons.chevron_left,
              tooltip: '이전 날짜',
              onPressed: () => unawaited(planner.changeDate(-1)),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _pickDate(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: GradientText(
                  dateText,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            _DateArrowButton(
              icon: Icons.chevron_right,
              tooltip: '다음 날짜',
              onPressed: () => unawaited(planner.changeDate(1)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '$dateText ($weekday) - 당신의 빛나는 계획',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MobileDateDock extends StatelessWidget {
  const _MobileDateDock();

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final date = planner.currentDate;
    final weekday = koreanWeekday(date);
    final displayDate =
        '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

    return DecoratedBox(
      decoration: _floatingDecoration(context, borderRadius: 999),
      child: SizedBox(
        width: 168,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              _MiniCircleButton(
                icon: Icons.chevron_left,
                tooltip: '이전 날짜',
                onPressed: () => unawaited(planner.changeDate(-1)),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _pickDate(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          weekday,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: context.mutedText,
                              ),
                        ),
                        GradientText(
                          displayDate,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            height: 1.08,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _MiniCircleButton(
                icon: Icons.chevron_right,
                tooltip: '다음 날짜',
                onPressed: () => unawaited(planner.changeDate(1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClampedCurve extends Curve {
  const _ClampedCurve(this.curve);
  final Curve curve;

  @override
  double transform(double t) {
    return curve.transform(t).clamp(0.0, 1.0);
  }
}

class _FloatingControls extends StatelessWidget {
  const _FloatingControls({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FloatingIconButton(
          glyph: AnimatedThemeIcon(isDark: isDark),
          tooltip: '테마 변경',
          compact: isCompact,
          breatheDelay: const Duration(milliseconds: 800),
          onPressed: () {
            final next = isDark ? ThemeMode.light : ThemeMode.dark;
            unawaited(settings.setThemeMode(next));
          },
        ),
        SizedBox(width: isCompact ? 10 : 14),
        _FloatingIconButton(
          glyph: AnimatedSoundIcon(isSoundEnabled: settings.isSoundEnabled),
          tooltip: '터치음 켜기/끄기',
          compact: isCompact,
          breatheDelay: const Duration(milliseconds: 1500),
          onPressed: () =>
              unawaited(settings.setSoundEnabled(!settings.isSoundEnabled)),
        ),
        SizedBox(width: isCompact ? 10 : 14),
        _FloatingIconButton(
          glyph: const AnimatedSettingsIcon(),
          tooltip: '환경 설정',
          compact: isCompact,
          breatheDelay: Duration.zero,
          onPressed: () => showSettingsModal(context),
        ),
      ],
    );
  }
}

class PrioritiesCard extends StatelessWidget {
  const PrioritiesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final isCompact = MediaQuery.sizeOf(context).width < 620;
    final isTodoPanel = planner.activePanel == PlannerPanel.todos;
    final title = isTodoPanel
        ? '할 일 목록'
        : '나의 핵심 목표 (Top ${planner.data.priorities.length})';
    final subtitle = isTodoPanel
        ? '굵게 강조, 여러 날짜 복사까지 한 번에 관리하세요.'
        : '오늘 반드시 해결할 핵심 목표를 먼저 정리해보세요.';

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isCompact)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Column(
                key: ValueKey(
                  isTodoPanel ? 'compact-todo' : 'compact-priority',
                ),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(
                    emoji: isTodoPanel ? null : '🔥',
                    icon: isTodoPanel ? Icons.checklist_rounded : null,
                    title: title,
                  ),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 28),
                  _ModeToggleButton(isTodoPanel: isTodoPanel, fullWidth: true),
                ],
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Column(
                      key: ValueKey(
                        isTodoPanel ? 'desktop-todo' : 'desktop-priority',
                      ),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          emoji: isTodoPanel ? null : '🔥',
                          icon: isTodoPanel ? Icons.checklist_rounded : null,
                          title: title,
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _ModeToggleButton(isTodoPanel: isTodoPanel),
              ],
            ),
          SizedBox(height: isCompact ? 34 : 22),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: isTodoPanel ? const TodoPanel() : const PriorityPanel(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({required this.isTodoPanel, this.fullWidth = false});

  final bool isTodoPanel;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tertiary = Theme.of(context).colorScheme.tertiary;
    final color = isTodoPanel ? tertiary : primary;
    final button = Material(
      key: ValueKey('mode-toggle-${isTodoPanel ? 'todo' : 'priority'}'),
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          context.read<PlannerProvider>().togglePriorityTodoPanel();
        },
        borderRadius: BorderRadius.circular(999),
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: color.withValues(alpha: 0.11),
            shape: StadiumBorder(
              side: BorderSide(color: color.withValues(alpha: 0.22)),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: fullWidth ? 18 : 16,
              vertical: fullWidth ? 17 : 13,
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTodoPanel ? '핵심 목표로 돌아가기' : '할 일 목록 열기',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isTodoPanel
                      ? Icons.keyboard_return_rounded
                      : Icons.open_in_new_rounded,
                  color: color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class PriorityPanel extends StatelessWidget {
  const PriorityPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final priorities = planner.data.priorities;

    return Column(
      key: const ValueKey('priorities'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          proxyDecorator: _proxyDecorator,
          itemCount: priorities.length,
          onReorder: planner.reorderPriorities,
          itemBuilder: (context, index) {
            final entry = priorities[index];
            return PriorityRow(
              key: ValueKey(entry.id),
              index: index,
              entry: entry,
            );
          },
        ),
        const SizedBox(height: 2),
        _FullWidthButton(
          icon: Icons.add_rounded,
          label: '새로운 핵심 목표 추가',
          onPressed: planner.addPriority,
        ),
      ],
    );
  }
}

/// 레거시 웹앱의 springPop / popOut 커브 상수
const _springPopCurve = Cubic(0.175, 0.885, 0.32, 1.275);
const _springPopDuration = Duration(milliseconds: 400);
const _popOutDuration = Duration(milliseconds: 350);

class PriorityRow extends StatefulWidget {
  const PriorityRow({super.key, required this.index, required this.entry});

  final int index;
  final PriorityEntry entry;

  @override
  State<PriorityRow> createState() => _PriorityRowState();
}

class _PriorityRowState extends State<PriorityRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _springPopDuration,
    );
    _scaleAnim = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateOut(VoidCallback onComplete) {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _controller.duration = _popOutDuration;
    _controller.reverse().then((_) {
      if (mounted) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlannerProvider>();
    final isCompact = MediaQuery.sizeOf(context).width < 620;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: ScaleTransition(scale: _scaleAnim, child: child),
          ),
        );
      },
      child: isCompact
          ? Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _PriorityMobileCard(
                index: widget.index,
                value: widget.entry.text,
                onChanged: (next) =>
                    provider.updatePriority(widget.index, next),
                onDelete: () =>
                    _animateOut(() => provider.removePriority(widget.index)),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _InputPill(
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: context.mutedText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 32,
                      child: GradientText(
                        '${widget.index + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.entry.text,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: '반드시 해결해야 할 최우선 과제 (Top 3)',
                        ),
                        onChanged: (next) =>
                            provider.updatePriority(widget.index, next),
                      ),
                    ),
                    _InlineDeleteButton(
                      onPressed: () => _animateOut(
                        () => provider.removePriority(widget.index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PriorityMobileCard extends StatelessWidget {
  const _PriorityMobileCard({
    required this.index,
    required this.value,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 176),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: context.mutedText,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: 48,
                    child: GradientText(
                      '${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _InlineDeleteButton(onPressed: onDelete),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 96,
                child: TextFormField(
                  initialValue: value,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                  decoration: const InputDecoration(
                    hintText: '반드시 해결해야 할 최우선 과제',
                  ),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodoPanel extends StatelessWidget {
  const TodoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final todos = planner.data.todos;

    return Column(
      key: const ValueKey('todos'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _ToolbarButton(
              icon: Icons.add_rounded,
              label: '새 할 일',
              onPressed: planner.addTodo,
            ),
            _ToolbarButton(
              icon: Icons.format_bold_rounded,
              label: '굵게',
              onPressed: () => _showSnack(
                context,
                'Flutter 버전에서는 텍스트 편집 도구를 순차적으로 붙이는 중입니다.',
              ),
            ),
            _ToolbarButton(
              icon: Icons.image_rounded,
              label: '이미지 업로드',
              onPressed: () => _showSnack(
                context,
                '이미지 업로드는 다음 단계에서 네이티브 파일 선택으로 연결할 예정입니다.',
              ),
            ),
            _SelectionBadge(count: planner.selectedTodoCount),
            _ToolbarButton(
              icon: Icons.copy_rounded,
              label: '다른 일정으로 복사',
              accent: true,
              onPressed: () =>
                  _showSnack(context, '날짜 복사 UI는 화면 이식 후 데이터 호환 단계에서 이어 붙일게요.'),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (todos.isEmpty)
          _EmptyHint(
            icon: Icons.playlist_add_check_rounded,
            text: '아직 할 일이 없습니다. 새 할 일을 추가해보세요.',
          )
        else
          ...List.generate(
            todos.length,
            (index) => TodoRow(
              key: ValueKey('todo-${todos[index].id}'),
              index: index,
              todo: todos[index],
            ),
          ),
        const SizedBox(height: 2),
        _FullWidthButton(
          icon: Icons.add_rounded,
          label: '새로운 할 일 추가',
          onPressed: planner.addTodo,
        ),
      ],
    );
  }
}

class TodoRow extends StatefulWidget {
  const TodoRow({super.key, required this.index, required this.todo});

  final int index;
  final TodoEntry todo;

  @override
  State<TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<TodoRow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _springPopDuration,
    );
    _scaleAnim = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateOut(VoidCallback onComplete) {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _controller.duration = _popOutDuration;
    _controller.reverse().then((_) {
      if (mounted) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlannerProvider>();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: ScaleTransition(scale: _scaleAnim, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.todo.selected,
                      shape: const CircleBorder(),
                      onChanged: (value) => provider.toggleTodoSelection(
                        widget.index,
                        value ?? false,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.todo.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: const InputDecoration(hintText: '할 일 제목'),
                        onChanged: (value) =>
                            provider.updateTodo(widget.index, title: value),
                      ),
                    ),
                    _InlineDeleteButton(
                      onPressed: () =>
                          _animateOut(() => provider.removeTodo(widget.index)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.softInput,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: TextFormField(
                      initialValue: widget.todo.note,
                      minLines: 3,
                      maxLines: 8,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: const InputDecoration(
                        hintText: '세부 내용을 적어두세요.',
                      ),
                      onChanged: (value) =>
                          provider.updateTodo(widget.index, note: value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeBlockCard extends StatelessWidget {
  const TimeBlockCard({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final blocks = planner.data.timeBlocks;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            icon: Icons.schedule_rounded,
            title: '타임 블로킹 (Schedule)',
          ),
          Text(
            '* 나만의 시간 덩어리(Block)를 유동적으로 설정해서 분산되는 집중력을 통제하세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: false,
                  proxyDecorator: _proxyDecorator,
                  itemCount: blocks.length,
                  onReorder: planner.reorderTimeBlocks,
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    return TimeBlockRow(
                      key: ValueKey('time-${block.id}'),
                      index: index,
                      block: block,
                    );
                  },
                ),
                const SizedBox(height: 2),
                _FullWidthButton(
                  icon: Icons.add_rounded,
                  label: '새로운 시간 블록 추가',
                  onPressed: planner.addTimeBlock,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeBlockRow extends StatefulWidget {
  const TimeBlockRow({super.key, required this.index, required this.block});

  final int index;
  final TimeBlock block;

  @override
  State<TimeBlockRow> createState() => _TimeBlockRowState();
}

class _TimeBlockRowState extends State<TimeBlockRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _springPopDuration,
    );
    _scaleAnim = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _opacityAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: _springPopCurve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateOut(VoidCallback onComplete) {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    _controller.duration = _popOutDuration;
    _controller.reverse().then((_) {
      if (mounted) onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlannerProvider>();
    final compact = MediaQuery.sizeOf(context).width < 620;

    final timeField = SizedBox(
      width: compact ? null : 164,
      child: TextFormField(
        initialValue: widget.block.time,
        textAlign: compact ? TextAlign.left : TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: FontWeight.w800,
        ),
        decoration: const InputDecoration(hintText: 'e.g. 07:30-08:00'),
        onChanged: (value) =>
            provider.updateTimeBlock(widget.index, time: value),
      ),
    );

    final textField = Expanded(
      child: TextFormField(
        initialValue: widget.block.text,
        minLines: 1,
        maxLines: 4,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        decoration: const InputDecoration(hintText: '해당 시간에 무엇을 할 계획인가요?'),
        onChanged: (value) =>
            provider.updateTimeBlock(widget.index, text: value),
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: ScaleTransition(scale: _scaleAnim, child: child),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: compact
            ? _TimeBlockMobileCard(
                index: widget.index,
                time: widget.block.time,
                text: widget.block.text,
                onTimeChanged: (value) =>
                    provider.updateTimeBlock(widget.index, time: value),
                onTextChanged: (value) =>
                    provider.updateTimeBlock(widget.index, text: value),
                onDelete: () =>
                    _animateOut(() => provider.removeTimeBlock(widget.index)),
              )
            : _InputPill(
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: context.mutedText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    timeField,
                    const SizedBox(width: 18),
                    textField,
                    _InlineDeleteButton(
                      onPressed: () => _animateOut(
                        () => provider.removeTimeBlock(widget.index),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _TimeBlockMobileCard extends StatelessWidget {
  const _TimeBlockMobileCard({
    required this.index,
    required this.time,
    required this.text,
    required this.onTimeChanged,
    required this.onTextChanged,
    required this.onDelete,
  });

  final int index;
  final String time;
  final String text;
  final ValueChanged<String> onTimeChanged;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: context.borderSubtle),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 118),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: context.mutedText,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      initialValue: time,
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w900,
                      ),
                      decoration: const InputDecoration(
                        hintText: '예: 07:30 - 08:00',
                      ),
                      onChanged: onTimeChanged,
                    ),
                  ),
                  _InlineDeleteButton(onPressed: onDelete),
                ],
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.softInput,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: TextFormField(
                    initialValue: text,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.newline,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(
                      hintText: '해당 시간에 무엇을 할 계획인가요?',
                    ),
                    onChanged: onTextChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PomodoroCard extends StatelessWidget {
  const PomodoroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    final tasks = planner.data.pomodoros;

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            icon: Icons.local_pizza_rounded,
            title: '뽀모도로 트래커',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                '[25분 몰입 + 5분 휴식 = 1 뽀모도로]\n목표 과제를 적고 스마트폰은 멀리 두세요. 한 세트를 온전히 집중해서 마쳤을 때만 한 칸을 체크하세요.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(
            tasks.length,
            (index) => PomodoroRow(
              key: ValueKey('pomo-${tasks[index].id}'),
              index: index,
              task: tasks[index],
            ),
          ),
        ],
      ),
    );
  }
}

class PomodoroRow extends StatelessWidget {
  const PomodoroRow({super.key, required this.index, required this.task});

  final int index;
  final PomodoroTask task;

  @override
  Widget build(BuildContext context) {
    final planner = context.read<PlannerProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: task.title,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              hintText: '세부 집중 과제 ${index + 1} (예: 25분간 수학 기출문제 풀이)',
            ),
            onChanged: (value) => planner.updatePomodoroTitle(index, value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              task.checks.length,
              (col) => _PomodoroCheck(
                checked: task.checks[col],
                onTap: () => planner.togglePomodoroCheck(index, col),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({super.key});

  @override
  Widget build(BuildContext context) {
    final planner = context.watch<PlannerProvider>();
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            icon: Icons.edit_note_rounded,
            title: '오늘의 피드백 (Reflection)',
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.softInput,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: TextFormField(
                key: ValueKey(
                  'feedback-${plannerDateKey(planner.currentDate)}',
                ),
                initialValue: planner.data.feedback,
                minLines: 9,
                maxLines: 18,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText:
                      '오늘 하루를 돌아봅니다.\n- 계획을 잘 지켰나요? 가장 몰입했던 순간은 언제인가요?\n- 지켜지지 않은 계획의 원인은 무엇인가요?\n- 내일은 어떻게 개선할 수 있을까요?',
                ),
                onChanged: planner.updateFeedback,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final planner = context.watch<PlannerProvider>();

    final buttons = settings.actionBarOrder
        .where((id) => settings.isButtonVisible(id))
        .map((id) {
          switch (id) {
            case 'btnAIChat':
              return _ActionButton(
                key: const ValueKey('btnAIChat'),
                icon: Icons.smart_toy_rounded,
                label: 'AI 어시스턴트',
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => _showSnack(
                  context,
                  'AI 어시스턴트 화면은 Flutter UI 이식 다음 단계에서 연결됩니다.',
                ),
              );
            case 'btnToggleAI':
              return _ActionButton(
                key: const ValueKey('btnToggleAI'),
                icon: Icons.auto_awesome_rounded,
                label: 'AI가 짠 예시 보기',
                color: Theme.of(context).colorScheme.tertiary,
                onPressed: () {
                  context.read<PlannerProvider>().applyAiExample();
                  _showSnack(context, '예시 계획을 적용했습니다.');
                },
              );
            case 'btnReset':
              return _ActionButton(
                key: const ValueKey('btnReset'),
                icon: Icons.refresh_rounded,
                label: '전체 초기화',
                muted: true,
                onPressed: () => _confirmClear(context),
              );
            case 'btnSave':
              return _ActionButton(
                key: const ValueKey('btnSave'),
                icon: Icons.save_rounded,
                label: planner.isSaving ? '자동 저장 중...' : '자동 저장 완료',
                color: Theme.of(context).colorScheme.primary,
                onPressed: () async {
                  await context.read<PlannerProvider>().saveNow();
                  if (context.mounted) _showSnack(context, '저장했습니다.');
                },
              );
            case 'btnCloudSync':
              return _ActionButton(
                key: const ValueKey('btnCloudSync'),
                icon: Icons.cloud_rounded,
                label: '클라우드',
                color: const Color(0xFF2563EB),
                onPressed: () => _showSnack(
                  context,
                  '클라우드 동기화는 기존 HTML 로직 분석 후 안전하게 옮길 예정입니다.',
                ),
              );
            case 'btnLoginLogout':
              return _ActionButton(
                key: const ValueKey('btnLoginLogout'),
                icon: Icons.key_rounded,
                label: '로그인 / 가입',
                muted: true,
                onPressed: () =>
                    _showSnack(context, '계정 연동 UI는 클라우드 단계에서 함께 연결됩니다.'),
              );
            case 'btnPrint':
              return _ActionButton(
                key: const ValueKey('btnPrint'),
                icon: Icons.print_rounded,
                label: 'PDF 인쇄',
                muted: true,
                onPressed: () =>
                    _showSnack(context, '인쇄 기능은 플랫폼별 출력 방식에 맞춰 다음 단계에서 연결됩니다.'),
              );
            default:
              return const SizedBox.shrink();
          }
        })
        .toList();

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: context.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: settings.actionBarBlur / 3.0,
                  sigmaY: settings.actionBarBlur / 3.0,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: context.glassShadow,
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(30), child: child),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, this.icon, this.emoji, required this.title});

  final IconData? icon;
  final String? emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 26,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 12),
          if (emoji != null)
            Text(emoji!, style: const TextStyle(fontSize: 25, height: 1))
          else if (icon != null)
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.secondary,
        ],
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class _InputPill extends StatelessWidget {
  const _InputPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: child,
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  const _FullWidthButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: StadiumBorder(side: BorderSide(color: context.borderSubtle)),
      elevation: 0,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onPressed,
        enableFeedback: context.watch<SettingsProvider>().isSoundEnabled,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(color: context.borderSubtle),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '선택 $count개',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InlineDeleteButton extends StatelessWidget {
  const _InlineDeleteButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.close_rounded),
      color: context.mutedText,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PomodoroCheck extends StatelessWidget {
  const _PomodoroCheck({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? primary : Colors.transparent,
          border: Border.all(
            color: checked ? primary : context.mutedText,
            width: 2,
          ),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
            : null,
      ),
    );
  }
}

class _FloatingIconButton extends StatefulWidget {
  const _FloatingIconButton({
    required this.glyph,
    required this.tooltip,
    required this.compact,
    required this.onPressed,
    this.breatheDelay = Duration.zero,
  });

  final Widget glyph;
  final String tooltip;
  final bool compact;
  final VoidCallback onPressed;
  final Duration breatheDelay;

  @override
  State<_FloatingIconButton> createState() => _FloatingIconButtonState();
}

class _FloatingIconButtonState extends State<_FloatingIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();

    // Bounce animation on tap: scale 1 -> 0.85 -> 1.15 -> 0.95 -> 1
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bounceAnim =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.15), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 20),
        ]).animate(
          CurvedAnimation(
            parent: _bounceController,
            curve: const _ClampedCurve(Curves.easeInOut),
          ),
        );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward(from: 0);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    if (settings.isSoundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.click));
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Match old web app: 52x52 on desktop, slightly smaller on compact
    final size = widget.compact ? 44.0 : 52.0;

    // Glass background colors matching old CSS variables
    final bgColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.6);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.black.withValues(alpha: 0.05);

    final buttonBody = AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final scale = _bounceAnim.value;

        return Transform.scale(
          scale: scale,
          child: RepaintBoundary(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Center(child: widget.glyph),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return buttonBody;
  }
}

class _MiniCircleButton extends StatelessWidget {
  const _MiniCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F172A).withValues(alpha: 0.52)
              : Colors.white.withValues(alpha: 0.58),
          shape: BoxShape.circle,
        ),
        child: SizedBox(width: 34, height: 34, child: Icon(icon, size: 20)),
      ),
    );
  }
}

class _DateArrowButton extends StatelessWidget {
  const _DateArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 34),
      color: context.mutedText,
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final background = muted
        ? Theme.of(context).colorScheme.surface
        : (color ?? Theme.of(context).colorScheme.primary);
    final foreground = muted
        ? Theme.of(context).colorScheme.onSurface
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          side: muted
              ? BorderSide(color: context.borderSubtle, width: 1.4)
              : BorderSide.none,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const GlassPanel(
      child: SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeOut.transform(animation.value);
      return Transform.scale(
        scale: 1 + t * 0.02,
        child: Material(
          color: Colors.transparent,
          elevation: 8 * t,
          borderRadius: BorderRadius.circular(28),
          child: child,
        ),
      );
    },
    child: child,
  );
}

BoxDecoration _floatingDecoration(
  BuildContext context, {
  required double borderRadius,
}) {
  return BoxDecoration(
    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: context.borderSubtle),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.11),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

Future<void> _pickDate(BuildContext context) async {
  final provider = context.read<PlannerProvider>();
  final picked = await showDatePicker(
    context: context,
    initialDate: provider.currentDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    locale: const Locale('ko', 'KR'),
  );
  if (picked != null && context.mounted) {
    await context.read<PlannerProvider>().setDate(picked);
  }
}

Future<void> _confirmClear(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('전체 초기화'),
      content: const Text('현재 날짜의 계획을 초기 상태로 되돌릴까요?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('초기화'),
        ),
      ],
    ),
  );

  if (confirmed == true && context.mounted) {
    await context.read<PlannerProvider>().clearCurrentDate();
    if (context.mounted) _showSnack(context, '현재 날짜의 계획을 초기화했습니다.');
  }
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        width: math.min(MediaQuery.sizeOf(context).width - 32, 560),
      ),
    );
}
