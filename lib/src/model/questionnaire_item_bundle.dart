import 'package:fhir/r4.dart';
import 'package:fhir_questionnaire/src/logic/utils/text_utils.dart';
import 'package:fhir_questionnaire/src/presentation/widgets/questionnaire_item/base/questionnaire_item_view.dart';

class QuestionnaireItemBundle {
  /// Use it just to group views
  final String? groupId;
  final QuestionnaireItem item;
  final FieldController controller;
  final QuestionnaireItemView view;

  const QuestionnaireItemBundle({
    this.groupId,
    required this.item,
    required this.controller,
    required this.view,
  });

  /// Returns linkId of the questionnaire [item] prefixed by its parent item 
  /// link ids, showing a unique id for this questionnaire [item].
  String get uid => '$groupId/${item.linkId}';
}
