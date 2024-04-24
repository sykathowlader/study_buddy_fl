import 'package:flutter/material.dart';

// list of all university that are displayed as the user types the university name
final List<String> _universitiesList = [
  'University of Oxford',
  'University of Cambridge',
  'Imperial College London',
  'University College London',
  'London School of Economics and Political Science',
  'University of Edinburgh',
  'King’s College London',
  'University of Manchester',
  'University of Bristol',
  'University of Warwick',
  'University of Glasgow',
  'University of Nottingham',
  'University of Leeds',
  'University of Southampton',
  'University of Sheffield',
  'University of Birmingham',
  'University of Liverpool',
  'Durham University',
  'University of Exeter',
  'Lancaster University',
  'University of York',
  'University of Leicester',
  'University of Sussex',
  'Loughborough University',
  'University of Bath',
  'University of Reading',
  'University of Surrey',
  'Queen Mary University of London',
  'Cardiff University',
  'University of Aberdeen',
  'Newcastle University',
  "Queen's University Belfast",
  'Heriot-Watt University',
  'University of St Andrews',
  'Aston University',
  'University of Dundee',
  'University of East Anglia',
  'University of Strathclyde',
  'City, University of London',
  'University of the Arts London',
  'Birkbeck, University of London',
  'Royal Holloway, University of London',
  'Goldsmiths, University of London',
  'Oxford Brookes University',
  'Brunel University London',
  'Plymouth University',
  'University of Kent',
  'University of Essex',
  'University of Huddersfield',
  'University of Portsmouth',
  // more to be added in future
];

class UniversityAutocomplete extends StatelessWidget {
  final TextEditingController controller;

  const UniversityAutocomplete({super.key, required this.controller});

//autocomplete university field
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
