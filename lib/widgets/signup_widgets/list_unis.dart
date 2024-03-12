import 'package:flutter/material.dart';

final List<String> _universitiesList = [
  'University of Oxford',
  'University of Cambridge',
  'Imperial College London',
  // Add more universities here
];

class UniversityAutocomplete extends StatelessWidget {
  final TextEditingController controller;

  const UniversityAutocomplete({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _universitiesList.where((String option) {
          return option
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController fieldTextEditingController,
          FocusNode fieldFocusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          decoration: InputDecoration(
            labelText: 'Enter your university',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}
