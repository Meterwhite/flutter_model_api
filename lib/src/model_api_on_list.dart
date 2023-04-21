import 'package:flutter_model_api/flutter_model_api.dart';

extension ModelAPIOnList on List {
  launchAsChain(
      {Function(
              List<ModelAPI> sucs, List<ModelAPI> fals, List<ModelAPI> blocks)?
          onAllComplete,
      breakOnError = true}) async {
    var sucs = <ModelAPI>[];
    var fals = <ModelAPI>[];
    var bloks = <ModelAPI>[];
    for (var modelApi in this) {
      if (modelApi is ModelAPI) {
        ModelAPI api = await modelApi.launch();
        if (api.hasError) {
          fals.add(api);
          if (breakOnError) {
            break;
          }
        } else if (api.apiState == ModelAPIState.loadBlocked) {
          bloks.add(api);
        } else {
          sucs.add(api);
        }
      }
    }
    onAllComplete?.call(sucs, fals, bloks);
  }

  launchAsBatch(
      {Function(
              List<ModelAPI> sucs, List<ModelAPI> fals, List<ModelAPI> blocks)?
          onAllComplete}) async {
    List<Future> launchs = [];
    for (var element in this) {
      if (element is ModelAPI) {
        launchs.add(element.launch());
      }
    }
    await Future.wait(launchs);
    var sucs = <ModelAPI>[];
    var fals = <ModelAPI>[];
    var bloks = <ModelAPI>[];
    for (var api in this) {
      if (api is ModelAPI) {
        if (api.hasError) {
          fals.add(api);
        } else if (api.apiState == ModelAPIState.loadBlocked) {
          bloks.add(api);
        } else {
          sucs.add(api);
        }
      }
    }
    onAllComplete?.call(sucs, fals, bloks);
  }
}
