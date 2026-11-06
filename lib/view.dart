import 'package:flutter/material.dart';
import 'model.dart';
import 'view_model.dart';

final names = ['🛒 購入', '📦 発送', '🏠 到着'];
final labels = ['購入', '発送', '到着'];
final colors = [
  Colors.blue.shade50,
  Colors.orange.shade50,
  Colors.green.shade50,
];

class KanbanView extends StatefulWidget {
  final KanbanViewModel vm;
  const KanbanView(this.vm, {super.key});

  @override
  State<KanbanView> createState() => _KanbanViewState();
}

class _KanbanViewState extends State<KanbanView> {
  final input = TextEditingController();

  void add() {
    widget.vm.add(input.text);
    input.clear();
  }

  Future<void> edit(Task task) async {
    var text = task.title;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('タスクを編集'),
        content: TextFormField(
          initialValue: text,
          autofocus: true,
          onChanged: (value) => text = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) widget.vm.rename(task, result);
  }

  Widget taskCard(Task t) {
    final status = t.status;
    final buttons = Wrap(
      spacing: 4,
      children: [
        if (status > 0)
          TextButton(
            onPressed: () => widget.vm.move(t, status - 1),
            child: Text('← ${labels[status - 1]}へ'),
          ),
        if (status < 2)
          FilledButton(
            onPressed: () => widget.vm.move(t, status + 1),
            child: Text('${labels[status + 1]}へ →'),
          ),
      ],
    );

    return Card(
      child: ListTile(
        title: Text(t.title),
        subtitle: buttons,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: '編集',
              icon: const Icon(Icons.edit),
              onPressed: () => edit(t),
            ),
            IconButton(
              tooltip: '削除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => widget.vm.remove(t),
            ),
          ],
        ),
      ),
    );
  }

  Widget lane(int s) {
    final cards = [
      for (final t in widget.vm.tasks)
        if (t.status == s) taskCard(t),
    ];
    return SizedBox(
      width: 300,
      child: Card(
        color: colors[s],
        child: Column(
          children: [
            ListTile(title: Text(names[s]), trailing: Text('${cards.length}件')),
            Expanded(child: ListView(children: cards)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: input,
      decoration: InputDecoration(
        labelText: '購入する物品',
        hintText: '例：ノート',
        border: OutlineInputBorder(),
      ),
    );
    final button = ValueListenableBuilder(
      valueListenable: input,
      builder: (context, value, child) => FilledButton.icon(
        onPressed: value.text.isEmpty ? null : add,
        icon: Icon(Icons.add),
        label: Text('購入に追加'),
      ),
    );
    final entry = Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            field,
            Align(alignment: Alignment.centerRight, child: button),
          ],
        ),
      ),
    );
    final board = ListenableBuilder(
      listenable: widget.vm,
      builder: (context, child) => ListView(
        scrollDirection: Axis.horizontal,
        children: [for (int s = 0; s < 3; s++) lane(s)],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('🛒 物品購入フロー')),
      body: Column(
        children: [
          entry,
          Expanded(child: board),
        ],
      ),
    );
  }
}
