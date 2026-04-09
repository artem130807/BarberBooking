import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpSixDigitFields extends StatefulWidget {
  const OtpSixDigitFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.enabled,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool enabled;

  @override
  State<OtpSixDigitFields> createState() => _OtpSixDigitFieldsState();
}

class _OtpSixDigitFieldsState extends State<OtpSixDigitFields> {
  bool _suppress = false;

  void _onChanged(int index, String value) {
    if (_suppress) return;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _suppress = true;
      widget.controllers[index].clear();
      _suppress = false;
      if (index > 0) widget.focusNodes[index - 1].requestFocus();
      return;
    }
    if (digits.length > 1) {
      _suppress = true;
      if (index == 0) {
        final slice = digits.length > 6 ? digits.substring(0, 6) : digits;
        for (var i = 0; i < 6; i++) {
          widget.controllers[i].text =
              i < slice.length ? slice.substring(i, i + 1) : '';
        }
        final lastIdx = slice.length >= 6 ? 5 : slice.length - 1;
        widget.focusNodes[lastIdx.clamp(0, 5)].requestFocus();
      } else {
        final room = 6 - index;
        final slice = digits.length > room ? digits.substring(0, room) : digits;
        for (var j = 0; j < slice.length; j++) {
          widget.controllers[index + j].text = slice.substring(j, j + 1);
        }
        final lastIdx = (index + slice.length - 1).clamp(0, 5);
        widget.focusNodes[lastIdx].requestFocus();
      }
      _suppress = false;
      return;
    }
    _suppress = true;
    widget.controllers[index].text = digits;
    widget.controllers[index].selection = TextSelection.collapsed(offset: 1);
    _suppress = false;
    if (index < 5) widget.focusNodes[index + 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          height: 1.1,
        ) ??
        const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.1);

    return Row(
      children: List.generate(6, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: widget.controllers[index],
                focusNode: widget.focusNodes[index],
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.number,
                enabled: widget.enabled,
                style: style,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => _onChanged(index, v),
              ),
            ),
          ),
        );
      }),
    );
  }
}
