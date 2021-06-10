part of 'settings_view.dart';

class _SettingsButtonBar extends StatelessWidget {
  const _SettingsButtonBar({
    Key? key,
    required this.children,
    this.singleChildPadding = const EdgeInsets.all(8),
    this.buttonBarPadding = const EdgeInsets.all(0),
    this.label,
  }) : super(key: key);

  final List<Widget> children;
  final String? label;
  final EdgeInsetsGeometry singleChildPadding;
  final EdgeInsetsGeometry buttonBarPadding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x331565c0),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 16),
              child: Text(
                label!,
                style: const TextStyle(
                  color: kDarkBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Divider(height: 1),
            ),
          ],
          if (children.length == 1)
            Padding(
              padding: singleChildPadding,
              child: children[0],
            )
          else
            Padding(
              padding: buttonBarPadding,
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                overflowButtonSpacing: 4,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}
