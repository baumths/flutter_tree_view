import 'package:flutter/material.dart';

export 'samples/lazy_loading.dart';
export 'samples/navigation.dart';
export 'samples/reordering.dart';

mixin PageInfo on Widget {
  String get title;
  String? get description => null;
}

class ExamplePages extends StatefulWidget {
  const ExamplePages({super.key, required this.pages});

  final List<PageInfo> pages;

  @override
  State<ExamplePages> createState() => _ExamplePagesState();
}

class _ExamplePagesState extends State<ExamplePages> {
  late final PageController pageController;

  int get lastPage => widget.pages.length - 1;

  int currentPage = 0;

  void jumpToPage(int page) {
    setState(() {
      currentPage = page;
      pageController.jumpToPage(currentPage);
    });
  }

  void previousTree() {
    jumpToPage(currentPage == 0 ? lastPage : currentPage - 1);
  }

  void nextTree() {
    jumpToPage(currentPage == lastPage ? 0 : currentPage + 1);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.pages.length;
    final PageInfo selectedTree = widget.pages[currentPage];

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentPage + 1} of ${lastPage + 1}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.navigate_before),
          onPressed: previousTree,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: nextTree,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (selectedTree.description == null)
            ListTile(title: Text(selectedTree.title))
          else
            ExpansionTile(
              title: Text(selectedTree.title),
              subtitle: const Text(
                'Tap to show/hide description',
                style: TextStyle(fontSize: 12),
              ),
              expandedAlignment: Alignment.centerLeft,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              children: [
                Text(
                  selectedTree.description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
              ],
            ),
          Expanded(
            child: PageView.builder(
              itemCount: itemCount,
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, int index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: widget.pages[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
