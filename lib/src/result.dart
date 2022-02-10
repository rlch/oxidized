//
// Copyright (c) 2020 Nathan Fiedler
//

import 'dart:async';

import 'package:equatable/equatable.dart';
import './option.dart';

/// Result is a type that represents either success (`Ok`) or failure (`Err`).
///
/// `Result<T, E>` is the type used for returning and propagating errors. It is
/// an object with an `Ok` value, representing success and containing a value,
/// and `Err`, representing error and containing an error value.
abstract class Result<T extends Object, E extends Object> extends Equatable {
  Result();

  /// Create an `Ok` result with the given value.
  factory Result.ok(T s) = Ok;

  /// Create an `Err` result with the given error.
  factory Result.err(E err) = Err;

  /// Call the `catching` function and produce a `Result`.
  ///
  /// If the function throws an error, it will be caught and contained in the
  /// returned result. Otherwise, the result of the function will be contained
  /// as the `Ok` value.
  factory Result.of(T Function() catching) {
    try {
      return Ok(catching());
    } catch (e) {
      return Err(e as E);
    }
  }

  static Future<Result<T, E>> asyncOf<T extends Object, E extends Object>(
    Future<T> Function() catching,
  ) async {
    try {
      return Ok(await catching());
    } catch (e) {
      return Err(e as E);
    }
  }

  /// Returns `true` if the option is a `Ok` value.
  bool isOk();

  /// Returns `true` if the option is a `Err` value.
  bool isErr();

  /// Invokes either the `okop` or the `errop` depending on the result.
  ///
  /// This is an attempt at providing something similar to the Rust `match`
  /// expression, which makes it easy to get at the value or error, depending on
  /// the result.
  ///
  /// See also [when] for another way to achieve the same behavior.
  R match<R>(R Function(T) okop, R Function(E) errop);

  /// Asynchronously invokes either the `okop` or the `errop` depending on the result.
  ///
  /// This is an attempt at providing something similar to the Rust `match`
  /// expression, which makes it easy to get at the value or error, depending on
  /// the result.
  ///
  /// See also [when] for another way to achieve the same behavior.
  Future<R> matchAsync<R>(
    Future<R> Function(T) okop,
    Future<R> Function(E) errop,
  );

  /// Invokes either `ok` or `err` depending on the result.
  ///
  /// Identical to [match] except that the arguments are named.
  R when<R>({required R Function(T) ok, required R Function(E) err});

  /// Asynchronously invokes either `ok` or `err` depending on the result.
  ///
  /// Identical to [match] except that the arguments are named.
  Future<R> whenAsync<R>({
    required Future<R> Function(T) ok,
    required Future<R> Function(E) err,
  });

  /// Invoke either the `ok` or the `err` function based on the result.
  ///
  /// This is a combination of the [map()] and [mapErr()] functions.
  Result<U, F> fold<U extends Object, F extends Object>(
    U Function(T) ok,
    F Function(E) err,
  );

  /// Asynchronously invoke either the `ok` or the `err` function based on the result.
  ///
  /// This is a combination of the [map()] and [mapErr()] functions.
  Future<Result<U, F>> foldAsync<U extends Object, F extends Object>(
    Future<U> Function(T) ok,
    Future<F> Function(E) err,
  );

  /// Converts the `Result` into an `Option` containing the value, if any.
  /// Otherwise returns `None` if the result is an error.
  Option<T> ok();

  /// Converts the `Result` into an `Option` containing the error, if any.
  /// Otherwise returns `None` if the result is a value.
  Option<E> err();

  /// Unwraps a result, yielding the content of an `Ok`.
  ///
  /// Throws an `Exception` if the value is an `Err`, with the passed message.
  T expect(String msg);

  /// Unwraps a result, yielding the content of an `Err`.
  ///
  /// Throws an `Exception` if the value is an `Ok`, with the passed message.
  E expectErr(String msg);

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying a function to a
  /// contained `Ok` value, leaving an `Err` value untouched.
  Result<U, E> map<U extends Object>(U Function(T) op);

  /// Maps a `Result<T, E>` to `Result<U, E>` by applying an asynchronous function to a
  /// contained `Ok` value, leaving an `Err` value untouched.
  Future<Result<U, E>> mapAsync<U extends Object>(Future<U> Function(T) op);

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to
  /// a contained `Err` value, leaving an `Ok` value untouched.
  ///
  /// This function can be used to pass through a successful result while
  /// handling an error.
  Result<T, F> mapErr<F extends Object>(F Function(E) op);

  /// Maps a `Result<T, E>` to `Result<T, F>` by applying a function to
  /// a contained `Err` value, leaving an `Ok` value untouched.
  ///
  /// This function can be used to pass through a successful result while
  /// handling an error.
  Future<Result<T, F>> mapErrAsync<F extends Object>(Future<F> Function(E) op);

  /// Applies a function to the contained value (if any), or returns the
  /// provided default (if not).
  U mapOr<U>(U Function(T) op, U opt);

  /// Applies an asynchronous function to the contained value (if any), or returns the
  /// provided default (if not).
  Future<U> mapOrAsync<U>(Future<U> Function(T) op, U opt);

  /// Maps a `Result<T, E>` to `U` by applying a function to a contained
  /// `Ok` value, or a fallback function to a contained `Err` value.
  U mapOrElse<U>(U Function(T) op, U Function(E) errOp);

  /// Maps a `Result<T, E>` to `U` by applying a function to a contained
  /// `Ok` value, or a fallback function to a contained `Err` value.
  Future<U> mapOrElseAsync<U>(
    Future<U> Function(T) op,
    Future<U> Function(E) errOp,
  );

  /// Returns `res` if the result is `Ok`, otherwise returns `this`.
  Result<U, E> and<U extends Object>(Result<U, E> res);

  /// Calls `op` with the `Ok` value if the result is `Ok`, otherwise returns
  /// `this`.
  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T) op);

  /// Asynchronously calls `op` with the `Ok` value if the result is `Ok`, otherwise returns
  /// `this`.
  Future<Result<U, E>> andThenAsync<U extends Object>(
    Future<Result<U, E>> Function(T) op,
  );

  /// Returns `res` if the result is an `Err`, otherwise returns `this`.
  Result<T, F> or<F extends Object>(Result<T, F> res);

  /// Calls `op` with the `Err` value if the result is `Err`, otherwise returns
  /// `this`.
  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E) op);

  /// Calls `op` with the `Err` value if the result is `Err`, otherwise returns
  /// `this`.
  Future<Result<T, F>> orElseAsync<F extends Object>(
    Future<Result<T, F>> Function(E) op,
  );

  /// Unwraps a result, yielding the content of an `Ok`.
  ///
  /// Throws the contained error if this result is an `Err`.
  T unwrap();

  /// Unwraps a result, yielding the content of an `Err`.
  ///
  /// Throws an exception if the value is an `Ok`, with a custom message
  /// provided by calling `toString()` on the `Ok`'s value.
  E unwrapErr();

  /// Unwraps a result, yielding the content of an `Ok`. Else, it returns `opt`.
  T unwrapOr(T opt);

  /// Unwraps a result, yielding the content of an `Ok`. If the value is an
  /// `Err` then it calls `op` with its value.
  T unwrapOrElse(T Function(E) op);

  /// Unwraps a result, yielding the content of an `Ok`. If the value is an
  /// `Err` then it asynchronously calls `op` with its value.
  Future<T> unwrapOrElseAsync(Future<T> Function(E) op);
}

/// An `Ok<T, E>` is a `Result` that represents the successful value.
///
/// You can create an `Ok` using either the `Ok()` constructor or the
/// `Result.ok()` factory constructor.
class Ok<T extends Object, E extends Object> extends Result<T, E> {
  final T _ok;

  /// Create an `Ok` result with the given value.
  Ok(T s) : _ok = s;

  @override
  List<Object?> get props => [_ok];

  @override
  bool get stringify => true;

  @override
  bool isOk() => true;

  @override
  bool isErr() => false;

  @override
  R match<R>(R Function(T) okop, R Function(E) errop) => okop(_ok);

  @override
  R when<R>({required R Function(T) ok, required R Function(E) err}) => ok(_ok);

  @override
  Result<U, F> fold<U extends Object, F extends Object>(
    U Function(T) ok,
    F Function(E) err,
  ) =>
      Ok(ok(_ok));

  @override
  Option<T> ok() => Option.some(_ok);

  @override
  Option<E> err() => Option.none();

  @override
  T expect(String msg) => _ok;

  @override
  E expectErr(String msg) {
    throw Exception(msg);
  }

  @override
  Result<U, E> map<U extends Object>(U Function(T) op) => Ok(op(_ok));

  @override
  Result<T, F> mapErr<F extends Object>(F Function(E) op) => Ok(_ok);

  @override
  U mapOr<U>(U Function(T) op, U opt) => op(_ok);

  @override
  U mapOrElse<U>(U Function(T) op, U Function(E) errOp) => op(_ok);

  @override
  Result<U, E> and<U extends Object>(Result<U, E> res) => res;

  @override
  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T) op) =>
      op(_ok);

  @override
  Result<T, F> or<F extends Object>(Result<T, F> res) => Ok(_ok);

  @override
  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E) op) => Ok(_ok);

  @override
  T unwrap() => _ok;

  @override
  E unwrapErr() {
    throw Exception(_ok.toString());
  }

  @override
  T unwrapOr(T opt) => _ok;

  @override
  T unwrapOrElse(T Function(E) op) => _ok;

  @override
  Future<Result<U, E>> andThenAsync<U extends Object>(
    Future<Result<U, E>> Function(T) op,
  ) =>
      op(_ok);

  @override
  Future<Result<U, F>> foldAsync<U extends Object, F extends Object>(
    Future<U> Function(T) ok,
    Future<F> Function(E) err,
  ) =>
      ok(_ok).then((v) => Ok(v));

  @override
  Future<Result<U, E>> mapAsync<U extends Object>(
    Future<U> Function(T) op,
  ) =>
      op(_ok).then((v) => Ok(v));

  @override
  Future<Result<T, F>> mapErrAsync<F extends Object>(
    Future<F> Function(E) op,
  ) =>
      Future.value(Ok(_ok));

  @override
  Future<U> mapOrAsync<U>(Future<U> Function(T) op, U opt) => op(_ok);

  @override
  Future<U> mapOrElseAsync<U>(
    Future<U> Function(T) op,
    Future<U> Function(E) errOp,
  ) =>
      op(_ok);

  @override
  Future<R> matchAsync<R>(
    Future<R> Function(T) okop,
    Future<R> Function(E) errop,
  ) =>
      okop(_ok);

  @override
  Future<Result<T, F>> orElseAsync<F extends Object>(
    Future<Result<T, F>> Function(E) op,
  ) =>
      Future.value(Ok(_ok));

  @override
  Future<T> unwrapOrElseAsync(Future<T> Function(E) op) => Future.value(_ok);

  @override
  Future<R> whenAsync<R>({
    required Future<R> Function(T) ok,
    required Future<R> Function(E) err,
  }) =>
      ok(_ok);
}

/// An `Err<T, E>` is a `Result` that represents a failure.
///
/// You can create an `Err` using either the `Err(E)` constructor or the
/// `Result.err(E)` factory constructor.
class Err<T extends Object, E extends Object> extends Result<T, E> {
  final E _err;

  /// Create an `Err` result with the given error.
  Err(E err) : _err = err;

  @override
  List<Object?> get props => [_err];

  @override
  bool get stringify => true;

  @override
  bool isOk() => false;

  @override
  bool isErr() => true;

  @override
  R match<R>(R Function(T) okop, R Function(E) errop) => errop(_err);

  @override
  R when<R>({required R Function(T) ok, required R Function(E) err}) => err(_err);

  @override
  Result<U, F> fold<U extends Object, F extends Object>(
    U Function(T) ok,
    F Function(E) err,
  ) =>
      Err(err(_err));

  @override
  Option<T> ok() => Option.none();

  @override
  Option<E> err() => Option.some(_err);

  @override
  T expect(String msg) {
    throw Exception(msg);
  }

  @override
  E expectErr(String msg) => _err;

  @override
  Result<U, E> map<U extends Object>(U Function(T) op) => Err(_err);

  @override
  Result<T, F> mapErr<F extends Object>(F Function(E) op) => Err(op(_err));

  @override
  U mapOr<U>(U Function(T) op, U opt) => opt;

  @override
  U mapOrElse<U>(U Function(T) op, U Function(E) errOp) => errOp(_err);

  @override
  Result<U, E> and<U extends Object>(Result<U, E> res) => Err(_err);

  @override
  Result<U, E> andThen<U extends Object>(Result<U, E> Function(T) op) =>
      Err(_err);

  @override
  Result<T, F> or<F extends Object>(Result<T, F> res) => res;

  @override
  Result<T, F> orElse<F extends Object>(Result<T, F> Function(E) op) =>
      op(_err);

  @override
  T unwrap() => throw _err;

  @override
  E unwrapErr() => _err;

  @override
  T unwrapOr(T opt) => opt;

  @override
  T unwrapOrElse(T Function(E) op) => op(_err);

  @override
  Future<Result<U, E>> andThenAsync<U extends Object>(
    Future<Result<U, E>> Function(T) op,
  ) =>
      Future.value(Err(_err));

  @override
  Future<Result<U, F>> foldAsync<U extends Object, F extends Object>(
    Future<U> Function(T) ok,
    Future<F> Function(E) err,
  ) =>
      err(_err).then((v) => Err(v));

  @override
  Future<Result<U, E>> mapAsync<U extends Object>(
    Future<U> Function(T) op,
  ) =>
      Future.value(Err(_err));

  @override
  Future<Result<T, F>> mapErrAsync<F extends Object>(
    Future<F> Function(E) op,
  ) =>
      op(_err).then((v) => Err(v));

  @override
  Future<U> mapOrAsync<U>(Future<U> Function(T) op, U opt) => Future.value(opt);

  @override
  Future<U> mapOrElseAsync<U>(
    Future<U> Function(T) op,
    Future<U> Function(E) errOp,
  ) =>
      errOp(_err);

  @override
  Future<R> matchAsync<R>(
    Future<R> Function(T) okop,
    Future<R> Function(E) errop,
  ) =>
      errop(_err);

  @override
  Future<Result<T, F>> orElseAsync<F extends Object>(
    Future<Result<T, F>> Function(E) op,
  ) =>
      op(_err);

  @override
  Future<T> unwrapOrElseAsync(Future<T> Function(E) op) => op(_err);

  @override
  Future<R> whenAsync<R>({
    required Future<R> Function(T) ok,
    required Future<R> Function(E) err,
  }) =>
      err(_err);
}
