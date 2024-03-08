import 'package:fhir_questionnaire/src/localization/questionnaire_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:fhir_questionnaire/src/utils/num_utils.dart';
import 'package:fhir_questionnaire/src/utils/text_utils.dart';
import 'package:adeptutils/adeptutils.dart' hide TextUtils;

class ValidationUtils {
  static ValidationController get requiredFieldValidation =>
      EnhancedEmptyValidationController(
          message: QuestionnaireLocalization
              .instance.localization.exceptionNoEmptyField);

  static ValidationController get positiveIntegerNumberValidation =>
      PositiveIntegerValidationController(
          message: QuestionnaireLocalization.instance.localization
              .exceptionValueMustBeAPositiveIntegerNumber);

  static ValidationController positiveNumberValidation({
    String? message,
    bool required = false,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization
                  .instance.localization.exceptionValueMustBeAPositiveNumber,
          isValid: ({controller}) {
            String? textValue = controller?.rawValue?.toString();
            if (!required && textValue.isEmpty) return true;
            num? value = NumUtils.tryParse(textValue!);
            return (value ?? -1) >= 0;
          });

  static ValidationController integerRangeValidationController(
          {required int minValue, required int maxValue}) =>
      IntegerRangeValidationController(
        message: QuestionnaireLocalization.instance.localization
            .exceptionValueOutOfRange(minValue, maxValue),
        minValue: minValue,
        maxValue: maxValue,
      );

  static List<ValidationController>
      get requiredPositiveIntegerNumberValidations => [
            requiredFieldValidation,
            positiveIntegerNumberValidation,
          ];

  static List<ValidationController> get requiredPositiveNumberValidations => [
        requiredFieldValidation,
        positiveNumberValidation(),
      ];

  static ValidationController lengthValidation({
    int minLength = 0,
    int? maxLength,
    String? message,
    bool required = false,
    bool considerHtmlTags = false,
    bool considerExtendedCharacters = true,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization.instance.localization
                  .exceptionTextLength(minLength, maxLength ?? (minLength * 2)),
          isValid: ({controller}) {
            String textValue = controller?.rawValue?.toString().trim() ?? '';
            if (considerHtmlTags) textValue = textValue.removeHtmlTags;
            int length = considerExtendedCharacters
                ? textValue.characters.length
                : textValue.length;
            if (!required && length == 0) return true;
            return length >= minLength &&
                (maxLength == null || length <= maxLength);
          });

  static ValidationController maxLengthValidation({
    required int maxLength,
    String? message,
    bool required = false,
    bool considerHtmlTags = false,
    bool considerExtendedCharacters = true,
  }) =>
      ValidationController(
          message: message ??
              QuestionnaireLocalization.instance.localization
                  .exceptionTextMaxLength(maxLength),
          isValid: ({controller}) {
            String textValue = controller?.rawValue?.toString().trim() ?? '';
            if (considerHtmlTags) textValue = textValue.removeHtmlTags;
            int length = considerExtendedCharacters
                ? textValue.characters.length
                : textValue.length;
            if (!required && length == 0) return true;
            return length <= maxLength;
          });

  static bool isPhoneNumberValid({String? number, Country? country}) {
    return number != null &&
        country != null &&
        number.length >= country.minLength &&
        number.length <= country.maxLength;
  }
}

class EnhancedEmptyValidationController extends ValidationController {
  EnhancedEmptyValidationController({String? message})
      : super(
          message: message ??
              QuestionnaireLocalization
                  .instance.localization.exceptionNoEmptyField,
          isValid: ({controller}) =>
              TextUtils.isNotEmpty(controller?.rawValue?.toString().trim()),
        );
}
