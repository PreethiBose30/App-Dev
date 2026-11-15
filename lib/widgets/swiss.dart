import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Building blocks for the Swiss / editorial look used across the app:
/// hairline rules, bold small labels, underlined fields, square buttons and
/// one accent colour. Everything reads colours from [AppColors] so it
/// follows light / dark.

/// Flat app bar with a heavy rule underneath, like the Home masthead.
PreferredSizeWidget swissAppBar(BuildContext context, String title, {List<Widget>? actions, bool back = true}) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: back,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleSpacing: back ? 0 : 20,
    title: Text(
      title,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2),
    ),
    actions: actions,
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.5),
      child: Container(height: 1.5, color: AppColors.rule),
    ),
  );
}

/// Small bold section label with a thin rule underneath ("Recent", "Details").
class SwissLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const SwissLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.rule, width: 0.8))),
      child: Row(
        children: [
          Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A list row separated by a hairline. Optional leading index ("01"),
/// title + subtitle, and a trailing widget.
class SwissRow extends StatelessWidget {
  final String? index;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool soft;
  final double trailingTop;
  const SwissRow({
    super.key,
    required this.title,
    this.index,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.soft = false,
    this.trailingTop = 5,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: soft ? AppColors.ruleSoft : AppColors.rule, width: 0.8)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index != null)
              SizedBox(
                width: 36,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(index!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -0.3),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              Padding(padding: EdgeInsets.only(top: trailingTop), child: trailing),
            ],
          ],
        ),
      ),
    );
  }
}

/// Square full-width button. Filled with the accent for the main action,
/// outlined in ink for secondary ones.
class SwissButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final IconData? icon;
  const SwissButton(this.label, {super.key, this.onPressed, this.loading = false, this.outlined = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final fg = outlined ? AppColors.textPrimary : AppColors.onAccent;
    final child = loading
        ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
            ],
          );
    final shape = const RoundedRectangleBorder(borderRadius: BorderRadius.zero);
    final size = const Size.fromHeight(52);
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: enabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                minimumSize: size,
                shape: shape,
                side: BorderSide(color: AppColors.textPrimary, width: 1.2),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: enabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: fg,
                disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                disabledForegroundColor: fg,
                minimumSize: size,
                shape: shape,
                elevation: 0,
              ),
              child: child,
            ),
    );
  }
}

/// Underlined text field decoration with a small sentence-case label.
InputDecoration swissInput(String label, {String? hint, Widget? suffix, String? prefixText}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    suffixIcon: suffix,
    labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    floatingLabelStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textPrimary, width: 0.8)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent, width: 2)),
    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accent, width: 2)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14),
  );
}

/// Centered-left empty / error message block.
class SwissMessage extends StatelessWidget {
  final String title;
  final String? body;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SwissMessage(this.title, {super.key, this.body, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
          if (body != null) ...[
            const SizedBox(height: 4),
            Text(body!, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(actionLabel!, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 15, color: AppColors.accent),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows [text] only once [active] has been true for [after]. Used for the
/// "server is waking up" hint, so normal quick loads show nothing extra.
class SlowHint extends StatefulWidget {
  final bool active;
  final String text;
  final Duration after;
  const SlowHint({
    super.key,
    required this.active,
    this.text = 'Waking up the server. The first load can take up to a minute.',
    this.after = const Duration(seconds: 5),
  });

  @override
  State<SlowHint> createState() => _SlowHintState();
}

class _SlowHintState extends State<SlowHint> {
  Timer? _timer;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(SlowHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _show = false;
    if (!widget.active) return;
    _timer = Timer(widget.after, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(widget.text, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
    );
  }
}
