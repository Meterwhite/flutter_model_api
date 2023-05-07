import 'package:flutter/material.dart';

typedef ModelAPICompletion<T> = Function(T api);

typedef ModelAPIStateChange<T> = Function(ModelAPIState state, T api);

enum ModelAPIState {
  ready,
  loading,
  loadBlocked,
  complete,
}

/// 模型API，面向对象的处理耗时任务
/// 命名规则：
/// 入参前缀in
/// 返回参数前缀out
abstract class ModelAPI<T> {
  dynamic apiUserInfo;

  ModelAPIStateChange<T>? onAPIStateChanged;

  ModelAPIState get apiState => _apiState;

  /// 启动API
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
        // 如果需要则抛出最新的一个异常
        throw outError!;
      }
      if (apiState != ModelAPIState.complete) {
        throw "Method 'complete' is not called";
      }
    } else {
      _apiState = ModelAPIState.loadBlocked;
      onAPIStateChanged?.call(apiState, api);
    }
    // _apiState = ModelAPIState.complete;
    // onAPIStateChanged?.call(apiState, api);
    return Future.value(api);
  }

  /// 任务完成后续的处理
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

  /// 在这里完成所有耗时任务；API完成时调用complete()，你可能会调用多次
  /// 完成后调用requestDone()
  /// 任何异常和错误的抛出都可以记录到outError，outError是一个List类型
  @protected
  dynamic loading();

  /// 可以使用mixin覆写
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

  /// 可以使用mixin覆写
  T get api {
    if (this is T == false) {
      throw Exception('检查你的类型定义，或者在子类重写该方法');
    }
    return this as T;
  }

  ModelAPICompletion<T>? _userCompletion;

  ModelAPIState _apiState = ModelAPIState.ready;

  bool get hasError => outErrors.isNotEmpty;

  final List outErrors = [];

  dynamic get outError => outErrors.isNotEmpty ? outErrors.last : null;

  /// null无效
  @protected
  set outError(dynamic error) {
    if (error != null) {
      outErrors.add(error);
    }
  }

  @protected
  clearError() => outErrors.clear();
}
