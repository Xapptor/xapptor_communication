import 'package:flutter/material.dart';

class CustomDropdownButton extends StatefulWidget {
  CustomDropdownButton({
    required this.on_changed,
    required this.value,
    required this.items,
    required this.title,
  });

  final Function(String?) on_changed;
  final String value;
  final List<String> items;
  final String title;

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
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
              color: Colors.black,
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
          onChanged: widget.on_changed,
          items: widget.items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
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
