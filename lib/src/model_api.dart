import 'package:flutter/material.dart';

typedef ModelAPICompletion<T> = Function(T api);

typedef ModelAPIStateChange<T> = Function(ModelAPIState state, T api);

enum ModelAPIState {
  ready,
  loading,
  loadBlocked,
  complete,
}

/// Modeling of network requests,  which manages input parameters and output parameters, which follows the "In-Out" naming convention.
///
/// Naming rules:
/// The prefix of the input parameter: in
/// (inUsername, inPassword)
///
/// The prefix of the return value: out
/// (outLoginUser)
abstract class ModelAPI<T> {
  dynamic apiUserInfo;

  ModelAPIStateChange<T>? onAPIStateChanged;

  ModelAPIState get apiState => _apiState;

  /// Start request.
  /// 
  /// Two solutions are provided below:
  /// api = await api.launch();
  /// ===>
  /// api.onComplete( (api) {
  ///   ...
  /// })
  Future<T> launch({
    dynamic userinfo,
    throwError = false,
  }) async {
    if (_apiState != ModelAPIState.ready) {
      _apiState = ModelAPIState.ready;
      onAPIStateChanged?.call(apiState, api);
    }
    if (permission(apiUserInfo = userinfo)) {
      if (hasError) {
        clearError();
      }
      _apiState = ModelAPIState.loading;
      onAPIStateChanged?.call(apiState, api);
      await loading();
      if (throwError && hasError) {
        // Throw latest one exception if needed
        throw outError!;
      }
      if (apiState != ModelAPIState.complete) {
        throw "Method 'complete()' should be called";
      }
    } else {
      _apiState = ModelAPIState.loadBlocked;
      onAPIStateChanged?.call(apiState, api);
    }
    return Future.value(api);
  }

  /// After the task is completed, the follow-up processing
  @mustCallSuper
  ModelAPI<T> onComplete(ModelAPICompletion<T>? completion) {
    _userCompletion = completion;
    return this;
  }

  ///
  ModelAPI<T> onStateChange(ModelAPIStateChange<T> callback) {
    onAPIStateChanged = callback;
    return this;
  }

  /// Complete all time-consuming tasks here;
  /// call complete() when the API is complete, and you may call it multiple times
  /// Any exception and error thrown can be recorded to outError,
  /// outError is a List type
  @protected
  dynamic loading();

  /// Can be overridden using a mixin
  @protected
  bool permission(dynamic userInfo) {
    return true;
  }

  /// Call this when request completed.
  @mustCallSuper
  @protected
  void complete() {
    _apiState = ModelAPIState.complete;
    onAPIStateChanged?.call(apiState, api);
    _userCompletion?.call(api);
  }

  /// Can be overridden using a mixin
  T get api {
    if (this is T == false) {
      throw TypeError();
    }
    return this as T;
  }

  ModelAPICompletion<T>? _userCompletion;

  ModelAPIState _apiState = ModelAPIState.ready;

  bool get hasError => outErrors.isNotEmpty;

  final List outErrors = [];

  dynamic get outError => outErrors.isNotEmpty ? outErrors.last : null;

  /// Assigning null is invalid
  @protected
  set outError(dynamic error) {
    if (error != null) {
      outErrors.add(error);
    }
  }

  @protected
  clearError() => outErrors.clear();
}
