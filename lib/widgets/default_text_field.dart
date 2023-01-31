import 'package:flutter/material.dart';
import 'package:tripo/repo/repository.dart';
import 'package:tripo/utils/input_decoration.dart';
import 'package:tripo/utils/size_config.dart';
import 'package:gap/gap.dart';

class DefaultTextField extends StatelessWidget {
  const DefaultTextField(
      {Key? key,
      this.focusNode,
      required this.controller,
      required this.title,
      this.mandatory = true,
      this.obscure,
      this.validator,
      this.prefixIcon,
      this.suffixIcon,
      this.keyboardType,
      this.onFieldSubmitted,
      this.textInputAction,
      this.enabled,
      this.label})
      : super(key: key);

  final FocusNode? focusNode;
  final TextEditingController? controller;
  final String title;
  final String? label;
  final bool mandatory;
  final bool? obscure;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final bool? enabled;
  String get _title => title;
  //String? get _label => _label;
  Widget? get _suffixIcon => suffixIcon;
  IconData? get _prefixIcon => prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: TextStyle(
              color: Repository.textColor(context),
              fontWeight: FontWeight.w500,
              fontSize: 15),
        ),
        Gap(getProportionateScreenHeight(5)),
        TextFormField(
          scrollPadding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 15 * 4),
          obscureText: obscure ?? false,
          enabled: enabled,
          focusNode: focusNode,
          keyboardType: keyboardType,
          cursorColor: Repository.textColor(context),
          textInputAction: textInputAction ?? TextInputAction.next,
          onFieldSubmitted: onFieldSubmitted,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Value cannot be empty';
            }

            return validator?.call(value);
          },
          controller: controller,
          decoration: inputDecoration(
              text: label ?? _title,
              prefixIcon: _prefixIcon,
              suffixIcon: _suffixIcon,
              context: context),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: Repository.textColor(context)),
        ),
        Gap(getProportionateScreenHeight(10)),
      ],
    );
  }
}
