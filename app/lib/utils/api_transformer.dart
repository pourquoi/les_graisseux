import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

/// Extends the default dio transformer to handle application/ld+json mime type.
class ApiTransformer extends Transformer {
  ApiTransformer();

  @override
  Future<String> transformRequest(RequestOptions options) async {
    var data = options.data ?? '';
    if (data is! String) {
      if (_isJsonMime(options.contentType)) {
        return json.encode(options.data);
      } else if (data is Map) {
        return Transformer.urlEncodeMap(data);
      }
    }
    return data.toString();
  }

  /// As an agreement, you must return the [response]
  /// when the Options.responseType is [ResponseType.stream].
  @override
  Future transformResponse(
      RequestOptions options, ResponseBody response) async {
    if (options.responseType == ResponseType.stream) {
      return response;
    }
    var length = 0;
    var received = 0;
    var showDownloadProgress = options.onReceiveProgress != null;
    if (showDownloadProgress) {
      length = int.parse(
          response.headers[Headers.contentLengthHeader]?.first ?? '-1');
    }
    var completer = Completer();
    var stream =
        response.stream.transform<Uint8List>(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(data);
        if (showDownloadProgress) {
          received += data.length;
          options.onReceiveProgress(received, length);
        }
      },
    ));
    // let's keep references to the data chunks and concatenate them later
    final chunks = <Uint8List>[];
    var finalSize = 0;
    StreamSubscription subscription = stream.listen(
      (chunk) {
        finalSize += chunk.length;
        chunks.add(chunk);
      },
      onError: (e) {
        completer.completeError(e);
      },
      onDone: () {
        completer.complete();
      },
      cancelOnError: true,
    );
    // ignore: unawaited_futures
    options.cancelToken?.whenCancel?.then((_) {
      return subscription.cancel();
    });
    if (options.receiveTimeout > 0) {
      try {
        await completer.future
            .timeout(Duration(milliseconds: options.receiveTimeout));
      } on TimeoutException {
        await subscription.cancel();
        throw DioError(
          request: options,
          error: 'Receiving data timeout[${options.receiveTimeout}ms]',
          type: DioErrorType.RECEIVE_TIMEOUT,
        );
      }
    } else {
      await completer.future;
    }
    // we create a final Uint8List and copy all chunks into it
    final responseBytes = Uint8List(finalSize);
    var chunkOffset = 0;
    for (var chunk in chunks) {
      responseBytes.setAll(chunkOffset, chunk);
      chunkOffset += chunk.length;
    }

    if (options.responseType == ResponseType.bytes) return responseBytes;

    String responseBody;
    if (options.responseDecoder != null) {
      responseBody = options.responseDecoder(
          responseBytes, options, response..stream = null);
    } else {
      responseBody = utf8.decode(responseBytes, allowMalformed: true);
    }
    if (responseBody != null &&
        responseBody.isNotEmpty &&
        options.responseType == ResponseType.json &&
        _isJsonMime(response.headers[Headers.contentTypeHeader]?.first)) {
      return json.decode(responseBody);
    }
    return responseBody;
  }

  bool _isJsonMime(String contentType) {
    if (contentType == null) return false;
    return MediaType.parse(contentType).mimeType.toLowerCase() ==
            Headers.jsonMimeType.mimeType ||
        MediaType.parse(contentType).mimeType.toLowerCase() ==
            'application/ld+json';
  }
}
