import 'package:flutter/material.dart';

class CallSettingsDropdownButton extends StatefulWidget {
  final Function(String) on_changed;
  final String value;
  final List<String> items;
  final String title;
  final Color? text_color;

  const CallSettingsDropdownButton({
    super.key,
    required this.on_changed,
    required this.value,
    required this.items,
    required this.title,
    this.text_color = Colors.black,
  });

  @override
  State<CallSettingsDropdownButton> createState() => _CallSettingsDropdownButtonState();
}

class _CallSettingsDropdownButtonState extends State<CallSettingsDropdownButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.text_color,
              fontSize: 18,
            ),
          ),
        ),
        DropdownButton<String>(
          value: widget.value,
          icon: const Icon(Icons.arrow_downward),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          underline: Container(
            height: 2,
            color: Colors.deepPurpleAccent,
          ),
          onChanged: (new_value) => widget.on_changed(new_value!),
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
