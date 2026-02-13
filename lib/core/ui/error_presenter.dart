import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../errors/app_exception.dart';
import '../errors/exception_mapper.dart';

void showAppErrorSnackBar(BuildContext context, Object error) {
  final message = appErrorMessage(error);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> showAppErrorDialog(BuildContext context, Object error) {
  final message = appErrorMessage(error);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Something went wrong'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

String appErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is DioException) {
    return ExceptionMapper.map(error).message;
  }
  return ExceptionMapper.map(error).message;
}
