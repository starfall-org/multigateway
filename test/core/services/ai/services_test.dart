import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ai_gateway/api/ai/openai/openai.dart';
import 'package:ai_gateway/api/ai/anthropic.dart';
import 'package:ai_gateway/api/ai/base.dart';
import 'package:ai_gateway/core/models/ai/ai_model.dart';

Future<HttpServer> _startServer(
  FutureOr<void> Function(HttpRequest req) handler,
) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  // ignore: unawaited_futures
  server.forEach((req) async {
    try {
      await handler(req);
    } catch (e) {
      req.response.headers.contentType = ContentType.json;
      req.response.statusCode = 500;
      req.response.write(jsonEncode({'error': e.toString()}));
      await req.response.close();
    }
  });
  return server;
}

Future<String> _readBody(HttpRequest req) async {
  return await utf8.decoder.bind(req).join();
}

void main() {
  group('OpenAIService', () {
    test('models returns List<AIModel>', () async {
      final server = await _startServer((req) async {
        if (req.method == 'GET' && req.uri.path == '/v1/models') {
          req.response.headers.contentType = ContentType.json;
          req.response.write(
            jsonEncode({
              'data': [
                {'id': 'gpt-4o-mini'},
                {'id': 'text-embedding-3-small'},
              ],
            }),
          );
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = OpenAI(baseUrl: baseUrl, apiKey: 'sk-test');

      final models = await svc.listModels();
      expect(models, isA<List<AIModel>>());
      expect(models.length, 2);
      expect(models.first.name, 'gpt-4o-mini');
    });

    test('chatCompletions non-stream returns full response', () async {
      final server = await _startServer((req) async {
        if (req.method == 'POST' && req.uri.path == '/v1/chat/completions') {
          final body = await _readBody(req);
          final parsed = jsonDecode(body);
          final stream = parsed['stream'] == true;

          if (!stream) {
            req.response.headers.contentType = ContentType.json;
            req.response.write(
              jsonEncode({
                'id': 'cmpl-1',
                'object': 'chat.completion',
                'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                'model': parsed['model'],
                'choices': [
                  {
                    'index': 0,
                    'message': {'role': 'assistant', 'content': 'Hello'},
                    'finish_reason': 'stop',
                  },
                ],
                'usage': {
                  'prompt_tokens': 1,
                  'completion_tokens': 1,
                  'total_tokens': 2,
                },
              }),
            );
            await req.response.close();
            return;
          }

          // If stream was requested but this is the non-stream test, 400
          req.response.statusCode = 400;
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = OpenAI(baseUrl: baseUrl, apiKey: 'sk-test');

      final resp = await svc.generate(
        AIRequest(
          model: 'gpt-4o-mini',
          messages: [
            AIMessage(
              role: 'user',
              content: [AIContent(type: AIContentType.text, text: 'Hi')],
            ),
          ],
          stream: false,
        ),
      );
      expect(resp, isA<AIResponse>());
      expect(resp.text, 'Hello');
    });

    test('chatCompletions stream via SSE aggregates deltas', () async {
      final server = await _startServer((req) async {
        if (req.method == 'POST' && req.uri.path == '/v1/chat/completions') {
          final body = await _readBody(req);
          final parsed = jsonDecode(body);
          final stream = parsed['stream'] == true;

          if (stream) {
            req.response.statusCode = 200;
            req.response.headers.contentType = ContentType(
              'text',
              'event-stream',
              charset: 'utf-8',
            );
            req.response.headers.set('Cache-Control', 'no-cache');
            req.response.headers.set('Connection', 'keep-alive');

            void send(Map<String, dynamic> obj) {
              req.response.write('data: ${jsonEncode(obj)}\n\n');
            }

            send({
              'id': 'chunk-1',
              'object': 'chat.completion.chunk',
              'choices': [
                {
                  'index': 0,
                  'delta': {'content': 'Hel'},
                  'finish_reason': null,
                },
              ],
            });
            await req.response.flush();

            send({
              'id': 'chunk-2',
              'object': 'chat.completion.chunk',
              'choices': [
                {
                  'index': 0,
                  'delta': {'content': 'lo'},
                  'finish_reason': 'stop',
                },
              ],
            });
            await req.response.flush();

            req.response.write('data: [DONE]\n\n');
            await req.response.close();
            return;
          }

          // Non-stream not used in this test
          req.response.statusCode = 400;
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = OpenAI(baseUrl: baseUrl, apiKey: 'sk-test');

      final stream = svc.generateStream(
        AIRequest(
          model: 'gpt-4o-mini',
          messages: [
            AIMessage(
              role: 'user',
              content: [AIContent(type: AIContentType.text, text: 'Hi')],
            ),
          ],
          stream: true,
        ),
      );

      String result = '';
      await for (final resp in stream) {
        result += resp.text;
      }
      expect(result, 'Hello');
    });

    test('responses stream via SSE aggregates output_text/delta', () async {
      final server = await _startServer((req) async {
        if (req.method == 'POST' && req.uri.path == '/v1/responses') {
          final body = await _readBody(req);
          final parsed = jsonDecode(body);
          final stream = parsed['stream'] == true;

          if (stream) {
            req.response.statusCode = 200;
            req.response.headers.contentType = ContentType(
              'text',
              'event-stream',
              charset: 'utf-8',
            );

            void send(Map<String, dynamic> obj) {
              req.response.write('data: ${jsonEncode(obj)}\n\n');
            }

            send({'delta': 'Hel'});
            await req.response.flush();
            send({'delta': 'lo'});
            await req.response.flush();
            req.response.write('data: [DONE]\n\n');
            await req.response.close();
            return;
          }

          // Non-stream not used in this test
          req.response.statusCode = 400;
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = OpenAI(baseUrl: baseUrl, apiKey: 'sk-test');

      final stream = svc.generateStream(
        AIRequest(
          model: 'gpt-4o-mini',
          messages: [
            AIMessage(
              role: 'user',
              content: [AIContent(type: AIContentType.text, text: 'Hi')],
            ),
          ],
          extra: {'mode': 'responses'},
        ),
      );

      String result = '';
      await for (final resp in stream) {
        result += resp.text;
      }
      expect(result, 'Hello');
    });
  });

  group('AnthropicService', () {
    test('models returns List<AIModel>', () async {
      final server = await _startServer((req) async {
        if (req.method == 'GET' && req.uri.path == '/v1/models') {
          req.response.headers.contentType = ContentType.json;
          req.response.write(
            jsonEncode({
              'data': [
                {
                  'id': 'claude-3-5-sonnet-20241022',
                  'display_name': 'Claude Sonnet',
                },
                {'id': 'claude-3-haiku', 'display_name': 'Claude Haiku'},
              ],
            }),
          );
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = Anthropic(baseUrl: baseUrl, apiKey: 'sk-ant');

      final models = await svc.listModels();
      expect(models, isA<List<AIModel>>());
      expect(models.length, 2);
      expect(models.first.name, 'claude-3-5-sonnet-20241022');
    });

    test('messagesCreate non-stream returns full response', () async {
      final server = await _startServer((req) async {
        if (req.method == 'POST' && req.uri.path == '/v1/messages') {
          final body = await _readBody(req);
          final parsed = jsonDecode(body);
          final stream = parsed['stream'] == true;

          if (!stream) {
            req.response.headers.contentType = ContentType.json;
            req.response.write(
              jsonEncode({
                'id': 'msg_1',
                'type': 'message',
                'role': 'assistant',
                'model': parsed['model'] ?? 'claude-3-haiku',
                'stop_reason': 'end_turn',
                'stop_sequence': null,
                'content': [
                  {'type': 'text', 'text': 'Hello'},
                ],
                'usage': {'input_tokens': 1, 'output_tokens': 1},
              }),
            );
            await req.response.close();
            return;
          }

          // If stream was requested but this is the non-stream test
          req.response.statusCode = 400;
          await req.response.close();
        } else {
          req.response.statusCode = 404;
          await req.response.close();
        }
      });
      addTearDown(() => server.close(force: true));

      final baseUrl = 'http://${server.address.host}:${server.port}/v1';
      final svc = Anthropic(baseUrl: baseUrl, apiKey: 'sk-ant');

      final resp = await svc.generate(
        AIRequest(
          model: 'claude-3-haiku',
          messages: [
            AIMessage(
              role: 'user',
              content: [AIContent(type: AIContentType.text, text: 'Hi')],
            ),
          ],
          stream: false,
        ),
      );
      expect(resp, isA<AIResponse>());
      expect(resp.text, 'Hello');
    });

    test(
      'messagesCreate stream via SSE aggregates content_block_delta and stops on message_stop',
      () async {
        final server = await _startServer((req) async {
          if (req.method == 'POST' && req.uri.path == '/v1/messages') {
            final body = await _readBody(req);
            final parsed = jsonDecode(body);
            final stream = parsed['stream'] == true;

            if (stream) {
              req.response.statusCode = 200;
              req.response.headers.contentType = ContentType(
                'text',
                'event-stream',
                charset: 'utf-8',
              );
              req.response.headers.set('Cache-Control', 'no-cache');
              req.response.headers.set('Connection', 'keep-alive');

              void send(Map<String, dynamic> obj) {
                req.response.write('data: ${jsonEncode(obj)}\n\n');
              }

              send({
                'type': 'message_start',
                'message': {'id': 'msg_1'},
              });
              await req.response.flush();

              send({
                'type': 'content_block_delta',
                'index': 0,
                'delta': {'type': 'text_delta', 'text': 'Hel'},
              });
              await req.response.flush();

              send({
                'type': 'content_block_delta',
                'index': 0,
                'delta': {'type': 'text_delta', 'text': 'lo'},
              });
              await req.response.flush();

              send({
                'type': 'message_delta',
                'delta': {'stop_reason': 'end_turn'},
                'usage': {'input_tokens': 1, 'output_tokens': 1},
              });
              await req.response.flush();

              send({'type': 'message_stop'});
              await req.response.close();
              return;
            }

            // Non-stream not used in this test
            req.response.statusCode = 400;
            await req.response.close();
          } else {
            req.response.statusCode = 404;
            await req.response.close();
          }
        });
        addTearDown(() => server.close(force: true));

        final baseUrl = 'http://${server.address.host}:${server.port}/v1';
        final svc = Anthropic(baseUrl: baseUrl, apiKey: 'sk-ant');

        final stream = svc.generateStream(
          AIRequest(
            model: 'claude-3-haiku',
            messages: [
              AIMessage(
                role: 'user',
                content: [AIContent(type: AIContentType.text, text: 'Hi')],
              ),
            ],
            stream: true,
          ),
        );

        String result = '';
        await for (final resp in stream) {
          result += resp.text;
        }
        expect(result, 'Hello');
      },
    );
  });
}
