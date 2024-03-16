import 'package:flutter/material.dart';

class TrackSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const TrackSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      width: MediaQuery.of(context).size.width * 0.5,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.transparent),
        ),
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 1,
            ),
            child: IconButton(
              onPressed: () {
                onSearch(_controller.text);
                _controller.clear();
              },
              icon: const Icon(Icons.search, color: Colors.black, size: 20),
            ),
          ),
          hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
          hintText: 'Search for a new song',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              width: 0,
              style: BorderStyle.none,
            ),
          ),
          contentPadding: const EdgeInsets.all(10),
        ),
        onSubmitted: (value) {
          onSearch(value);
          _controller.clear();
        },
      ),
    );
  }
}
