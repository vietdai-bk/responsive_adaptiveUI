import 'package:flutter/material.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Responsive & Adaptive Demo',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF000050), useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class Item {
  const Item(this.title, this.subtitle, this.body, this.icon);
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
}

const inbox = [
  Item('Lịch thuyết trình', 'Chủ đề 3 – tuần 11',
      'Nhóm trình bày Responsive và Adaptive UI trong Flutter, có phần demo trực tiếp trên điện thoại và tablet.',
      Icons.event),
  Item('Tài liệu MediaQuery', 'sizeOf, orientationOf, paddingOf',
      'MediaQuery cung cấp kích thước màn hình, hướng màn hình, textScaler và vùng padding của hệ thống.',
      Icons.straighten),
  Item('Ghi chú LayoutBuilder', 'constraints.maxWidth < 600',
      'LayoutBuilder dựng giao diện theo constraints của widget cha: nhỏ hơn 600dp dùng layout A, ngược lại dùng layout B.',
      Icons.dashboard_customize),
  Item('Breakpoint Material 3', 'Compact · Medium · Expanded',
      'Compact < 600dp, Medium 600–839dp, Expanded ≥ 840dp theo window size classes của Material 3.',
      Icons.devices),
  Item('Checklist nhập liệu', 'Vùng chạm 48dp, hover, focus',
      'Mọi nút cần vùng chạm tối thiểu 48dp, có trạng thái hover cho chuột và viền focus khi dùng phím Tab.',
      Icons.touch_app),
  Item('Kiểm thử đa thiết bị', 'Điện thoại, tablet, desktop',
      'Chạy thử ở chế độ dọc, ngang và kéo giãn cửa sổ desktop để kiểm tra bố cục không bị tràn.',
      Icons.check_circle_outline),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  Item? _selected = inbox.first;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 600;
      void onTab(int i) => setState(() => _tab = i);
      return isCompact
          ? PhoneLayout(tab: _tab, onTab: onTab)
          : TabletLayout(
              tab: _tab,
              onTab: onTab,
              selected: _selected,
              onSelect: (it) => setState(() => _selected = it));
    });
  }
}

PreferredSizeWidget _appBar(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final cls = width < 600 ? 'Compact' : (width < 840 ? 'Medium' : 'Expanded');
  return AppBar(
    title: const Text('Responsive & Adaptive'),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Chip(label: Text('$cls · ${width.round()}dp')),
      ),
    ],
  );
}

class PhoneLayout extends StatelessWidget {
  const PhoneLayout({super.key, required this.tab, required this.onTab});
  final int tab;
  final ValueChanged<int> onTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: ListView.builder(
          itemCount: inbox.length,
          itemBuilder: (context, i) => ListTile(
            minTileHeight: 72,
            leading: CircleAvatar(child: Icon(inbox[i].icon)),
            title: Text(inbox[i].title),
            subtitle: Text(inbox[i].subtitle),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetailPage(item: inbox[i]))),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tab,
        onTap: onTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Hộp thư'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Đã lưu'),
        ],
      ),
    );
  }
}

class TabletLayout extends StatelessWidget {
  const TabletLayout({
    super.key,
    required this.tab,
    required this.onTab,
    required this.selected,
    required this.onSelect,
  });
  final int tab;
  final ValueChanged<int> onTab;
  final Item? selected;
  final ValueChanged<Item> onSelect;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: SafeArea(
        child: Row(children: [
          NavigationRail(
            selectedIndex: tab,
            onDestinationSelected: onTab,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('Hộp thư')),
              NavigationRailDestination(icon: Icon(Icons.star), label: Text('Đã lưu')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: ListView(
              children: [
                for (final it in inbox)
                  ListTile(
                    minTileHeight: 72,
                    selected: it == selected,
                    selectedTileColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    leading: CircleAvatar(child: Icon(it.icon)),
                    title: Text(it.title),
                    subtitle: Text(it.subtitle),
                    onTap: () => onSelect(it),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(flex: 3, child: DetailView(item: selected)),
        ]),
      ),
    );
  }
}

class DetailView extends StatelessWidget {
  const DetailView({super.key, required this.item});
  final Item? item;

  @override
  Widget build(BuildContext context) {
    final it = item;
    if (it == null) return const Center(child: Text('Chọn một mục'));
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(radius: 28, child: Icon(it.icon, size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Text(it.title, style: t.headlineSmall)),
          ]),
          const SizedBox(height: 8),
          Text(it.subtitle, style: t.titleMedium),
          const Divider(height: 32),
          Text(it.body, style: t.bodyLarge),
          const SizedBox(height: 24),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.icon(
                onPressed: () {}, icon: const Icon(Icons.star), label: const Text('Lưu')),
            OutlinedButton.icon(
                onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Chia sẻ')),
          ]),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SafeArea(child: DetailView(item: item)),
    );
  }
}
