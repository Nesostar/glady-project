import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _controller = TextEditingController();
  String _selectedType = 'Sermon';
  File? _pickedFile;

  final List<String> _types = [
    'Sermon',
    'Announcement',
    'Event',
    'Bible',
    'More',
  ];

  void _addItem() {
    final content = _controller.text.trim();
    if (content.isEmpty && _pickedFile == null) return;

    setState(() {
      _items.add(
          {'type': _selectedType, 'content': content, 'file': _pickedFile});
      _controller.clear();
      _pickedFile = null;
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['pdf', 'doc', 'docx'],
      type: FileType.custom,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Widget _buildFileRow(File? file) {
    if (file == null) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              file.path.split('/').last,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Tasks"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Type selector
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: "Select Task Type"),
              items: _types.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
            const SizedBox(height: 10),

            // Text input
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Content (optional if uploading doc)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),

            // Upload button
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload File"),
                ),
                const SizedBox(width: 10),
                if (_pickedFile != null)
                  Expanded(child: _buildFileRow(_pickedFile)),
              ],
            ),

            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.save),
              label: const Text("Add"),
            ),

            const Divider(height: 30),

            // Display saved items
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text("No tasks added."))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          child: ListTile(
                            title: Text(item['content'] ?? '[No content]'),
                            subtitle: Text(item['type']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteItem(index),
                            ),
                            isThreeLine: true,
                            onTap: item['file'] != null
                                ? () async {
                                    final result =
                                        await OpenFilex.open(item['file'].path);
                                    if (result.type != ResultType.done) {
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "Failed to open file: ${result.message}")),
                                      );
                                    }
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
