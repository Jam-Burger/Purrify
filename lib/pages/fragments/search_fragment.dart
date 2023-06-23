import 'package:flutter/material.dart';

class SearchFragment extends StatefulWidget {
  const SearchFragment({super.key});

  @override
  State<SearchFragment> createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              contentPadding: const EdgeInsets.all(15),
              labelText: 'Search',
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search_outlined),
            ),
            onChanged: (value) {
              _onChanged(value);
            },
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
              _onSubmit();
            },
          ),
        ),
      ],
    );
  }

  void _onChanged(String value) {}

  void _onSubmit() {}
}
