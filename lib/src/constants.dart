// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';
import 'package:yaml/yaml.dart';

class Config {
  static final Config _instance = Config._init();
  YamlMap? _cost;
  YamlMap? _indent;

  factory Config() {
    return _instance;
  }

  int cost(String key) {
    if (_cost != null && _cost!.containsKey(key)) {
      return _cost![key] as int;
    } else {
      throw Exception('$key not found in format config!');
    }
  }

  int indent(String key) {
    if (_indent != null && _indent!.containsKey(key)) {
      return _indent![key] as int;
    } else {
      throw Exception('$key not found in format config!');
    }
  }

  Config._init() {
    var configFile =
        File('${Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']}/dartstyle.yaml').readAsStringSync();
    var content = loadYamlDocument(configFile).contents as YamlMap;
    _cost = content['Cost'] as YamlMap;
    _indent = content['Indent'] as YamlMap;
  }
}

/// Constants for the cost heuristics used to determine which set of splits is
/// most desirable.
final class Cost {
  /// The cost of splitting after the `=>` in a lambda or arrow-bodied member.
  ///
  /// We make this zero because there is already a span around the entire body
  /// and we generally do prefer splitting after the `=>` over other places.
  static final arrow = Config().cost('arrow');

  /// The default cost.
  ///
  /// This isn't zero because we want to ensure all splitting has *some* cost,
  /// otherwise, the formatter won't try to keep things on one line at all.
  /// Most splits and spans use this. Greater costs tend to come from a greater
  /// number of nested spans.
  static final normal = Config().cost('normal');

  /// Splitting after a "=".
  static final assign = Config().cost('assign');

  /// Splitting after a "=" when the right-hand side is a collection or cascade.
  static final assignBlock = Config().cost('assignBlock');

  /// Splitting before the first argument when it happens to be a function
  /// expression with a block body.
  static final firstBlockArgument = Config().cost('firstBlockArgument');

  /// The series of positional arguments.
  static final positionalArguments = Config().cost('positionalArguments');

  /// Splitting inside the brackets of a list with only one element.
  static final singleElementList = Config().cost('singleElementList');

  /// Splitting the internals of block arguments.
  ///
  /// Used to prefer splitting at the argument boundary over splitting the block
  /// contents.
  static final splitBlocks = Config().cost('splitBlocks');

  /// Splitting on the "." in a named constructor.
  static final constructorName = Config().cost('constructorName');

  /// Splitting a `[...]` index operator.
  static final index = Config().cost('index');

  /// Splitting before a type argument or type parameter.
  static final typeArgument = Config().cost('typeArgument');

  /// Split between a formal parameter name and its type.
  static final parameterType = Config().cost('parameterType');
}

/// Constants for the number of spaces for various kinds of indentation.
final class Indent {
  /// Reset back to no indentation.
  static final none = Config().indent('none');

  /// The number of spaces in a block or collection body.
  static final block = Config().indent('block');

  /// How much wrapped cascade sections indent.
  static final cascade = Config().indent('cascade');

  /// The number of spaces in a single level of expression nesting.
  static final expression = Config().indent('expression');

  /// The ":" on a wrapped constructor initialization list.
  static final constructorInitializer =
      Config().indent('constructorInitializer');

  /// A wrapped constructor initializer after the first one when the parameter
  /// list does not have optional or named parameters, like:
  ///
  ///     Constructor(
  ///       parameter,
  ///     ) : first,
  ///         second;
  ///       ^^ This indentation.
  static final initializer = Config().indent('initializer');

  /// A wrapped constructor initializer after the first one when the parameter
  /// list has optional or named parameters, like:
  ///
  ///     Constructor([
  ///       parameter,
  ///     ]) : first,
  ///          second;
  ///       ^^^ This indentation.
  static final initializerWithOptionalParameter =
      Config().indent('initializerWithOptionalParameter');
}
