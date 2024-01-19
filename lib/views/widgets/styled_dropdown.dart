import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.035,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Colors.grey, // You can customize the border color
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: widget.selectedItem,
            onChanged: (String? newValue) {
              widget.onChanged(newValue);
            },
            icon: Icon(Icons.arrow_drop_down,
                color: Colors.grey), // Customize the dropdown icon

            style: TextStyle(
              color: Colors.black,
            ),
            underline: Container(),
            items: widget.items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(value),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
