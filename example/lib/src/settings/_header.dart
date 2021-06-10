part of 'settings_view.dart';

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      tween: Tween<double>(begin: 40, end: 8),
      builder: (_, double padding, Widget? child) {
        return AnimatedPadding(
          padding: const EdgeInsets.all(8).copyWith(left: padding),
          duration: kAnimationDuration,
          curve: Curves.fastLinearToSlowEaseIn,
          child: child,
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.blueGrey,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionsHeader extends StatelessWidget {
  const _ActionsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _SettingsHeader(text: 'Actions'),
        const Spacer(),
        const Tooltip(
          message: 'The selection functionality is not part of the\n'
              'TreeView API. It\'s just present to demonstrate\n'
              'how customizable the TreeView is.',
          verticalOffset: 16,
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 1.025,
            height: 1.5,
          ),
          padding: EdgeInsets.all(16),
          child: Icon(Icons.info_outline_rounded, color: Colors.deepOrange),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
