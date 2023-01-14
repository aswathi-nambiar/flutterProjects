import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  TextEditingController searchController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(10.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          prefixIcon: const Icon(UniconsLine.search),
          suffixIcon: IconButton(
            icon: const Icon(UniconsLine.multiply),
            onPressed: () {
              searchController.clear();
            },
          ),
          hintText: 'Search...',
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(width: 1.0, color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              width: 1.0,
              color: Color(0xff1651DA),
            ),
          ),
        ),
      ),
    );
  }
}
