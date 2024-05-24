part of '../filters_setup_flow.dart';


extension on List<InlineButton> {
  List<InlineButton> withBackButton(String stepUri) {
    return [
      ...this,
      InlineButton(
        title: 'Back',
        nextStepUri: stepUri,
      ),
    ];
  }
}
