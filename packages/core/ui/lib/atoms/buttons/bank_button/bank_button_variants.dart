part of 'bank_button.dart';

// ── Solid ──────────────────────────────────────────────────────────────────

class _SolidButton extends StatelessWidget {
  const _SolidButton({
    required this.label,
    required this.size,
    required this.onPressed,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: _BankButtonStyles.solidStyle(size),
    child: Text(label),
  );
}

// ── Outlined ───────────────────────────────────────────────────────────────

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.label,
    required this.size,
    required this.onPressed,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    style: _BankButtonStyles.outlinedStyle(size),
    child: Text(label),
  );
}

// ── Subtle ─────────────────────────────────────────────────────────────────

class _SubtleButton extends StatelessWidget {
  const _SubtleButton({
    required this.label,
    required this.size,
    required this.onPressed,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: _BankButtonStyles.subtleStyle(size),
    child: Text(label),
  );
}

// ── Ghost ──────────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.size,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: _BankButtonStyles.ghostStyle(size),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _BankButtonStyles.iconSizeFor(size)),
        const SizedBox(width: BankingSpacing.xs),
        Text(label),
      ],
    ),
  );
}

// ── Icon-only ──────────────────────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.label,
    required this.size,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    child: TextButton(
      onPressed: onPressed,
      style: _BankButtonStyles.iconStyle(size),
      child: Icon(icon, size: _BankButtonStyles.iconSizeFor(size)),
    ),
  );
}

// ── Nested icon ────────────────────────────────────────────────────────────

class _NestedIconButton extends StatelessWidget {
  const _NestedIconButton({
    required this.label,
    required this.size,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final BankButtonSize size;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ElevatedButton(
    onPressed: onPressed,
    style: _BankButtonStyles.nestedIconStyle(size),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _BankButtonStyles.iconSizeFor(size)),
        const SizedBox(width: BankingSpacing.xs),
        Text(label),
      ],
    ),
  );
}

// ── Loading ────────────────────────────────────────────────────────────────

class _LoadingButton extends StatelessWidget {
  const _LoadingButton({required this.type, required this.size});

  final BankButtonType type;
  final BankButtonSize size;

  @override
  Widget build(BuildContext context) {
    final spinnerSize = _BankButtonStyles.iconSizeFor(size);
    return ElevatedButton(
      onPressed: null,
      style: _BankButtonStyles.solidStyle(size).copyWith(
        backgroundColor: const WidgetStatePropertyAll(BankingColors.primary),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
      child: SizedBox(
        height: spinnerSize,
        width: spinnerSize,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
