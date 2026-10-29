import 'package:flutter/material.dart';
import 'package:planck/generated/l10n.dart';
import 'package:planck/src/screens/main/tab1_controller.dart';

class FilterInput extends StatefulWidget {
  const FilterInput({super.key, required this.tab1Controller});
  final Tab1Controller tab1Controller;
  @override
  State<FilterInput> createState() => _FilterInputState();
}

class _FilterInputState extends State<FilterInput> {
  late final TextEditingController _text = TextEditingController(
    text: widget.tab1Controller.query,
  );
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.tab1Controller.query;
    if (_text.text.trim() != query) {
      _text.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }
    return TextField(
      key: const ValueKey('catalog-search'),
      controller: _text,
      maxLength: 120,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        counterText: '',
        hintText: S.of(context).catalogSearchHint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: S.of(context).clearSearch,
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _text.clear();
                  widget.tab1Controller.filterCompanies('');
                },
              ),
      ),
      onChanged: widget.tab1Controller.filterCompanies,
      onSubmitted: (value) =>
          widget.tab1Controller.loadCompanies(filter: value),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
