import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:multigateway/core/chat/models/conversation.dart';
import 'package:multigateway/core/chat/models/conversation_adapter.dart';
import 'package:multigateway/core/chat/storage/conversation_storage.dart';
import 'package:multigateway/core/llm/models/llm_provider_info.dart';
import 'package:multigateway/core/llm/models/llm_provider_info_adapter.dart';
import 'package:multigateway/core/mcp/models/mcp_adapter.dart';
import 'package:multigateway/core/mcp/models/mcp_info.dart';
import 'package:multigateway/core/profile/models/chat_profile.dart';
import 'package:multigateway/core/profile/models/chat_profile_adapter.dart';
import 'package:multigateway/core/profile/storage/chat_profile_storage.dart';
import 'package:uuid/uuid.dart';

/// Test TypeAdapter implementation for Hive storage optimization
void main() {
  group('TypeAdapter Storage Tests', () {
    late Directory tempDir;

    setUpAll(() async {
      // Create temporary directory for tests
      tempDir = Directory.systemTemp.createTempSync('hive_typeadapter_test');
      await Hive.initFlutter(tempDir.path);

      // Register all TypeAdapters
      _registerTypeAdapters();
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('Conversation TypeAdapter Tests', () {
      test('should serialize and deserialize Conversation correctly', () async {
        final conversation = Conversation(
          id: const Uuid().v4(),
          title: 'Test Conversation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: [
            {'role': 'user', 'content': 'Hello'},
            {'role': 'assistant', 'content': 'Hi there!'},
          ],
          tokenCount: 100,
          providerId: 'test_provider',
          modelId: 'test_model',
          profileId: 'test_profile',
        );

        final storage = ConversationStorage();
        await storage.ensureBoxReady();

        // Save and retrieve
        await storage.saveItem(conversation);
        final retrieved = storage.getItem(conversation.id);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(conversation.id));
        expect(retrieved.title, equals(conversation.title));
        expect(retrieved.messages.length, equals(2));
        expect(retrieved.messages[0]['role'], equals('user'));
        expect(retrieved.tokenCount, equals(100));
      });

      test('should handle large message lists efficiently', () async {
        final largeMessages = List.generate(
          1000,
          (index) => {
            'role': index % 2 == 0 ? 'user' : 'assistant',
            'content':
                'Message content $index with some longer text to test serialization performance',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );

        final conversation = Conversation(
          id: const Uuid().v4(),
          title: 'Large Conversation',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          messages: largeMessages,
          providerId: 'test_provider',
          modelId: 'test_model',
          profileId: 'test_profile',
        );

        final storage = ConversationStorage();
        await storage.ensureBoxReady();

        // Measure serialization time
        final stopwatch = Stopwatch()..start();
        await storage.saveItem(conversation);
        final saveTime = stopwatch.elapsedMilliseconds;

        stopwatch.reset();
        final retrieved = storage.getItem(conversation.id);
        final retrieveTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        expect(retrieved, isNotNull);
        expect(retrieved!.messages.length, equals(1000));

        // Performance should be reasonable (adjust thresholds as needed)
        debugPrint(
          'Save time: ${saveTime}ms, Retrieve time: ${retrieveTime}ms',
        );
        expect(saveTime, lessThan(1000)); // Should save within 1 second
        expect(retrieveTime, lessThan(100)); // Should retrieve within 100ms
      });
    });

    group('ChatProfile TypeAdapter Tests', () {
      test('should serialize and deserialize ChatProfile correctly', () async {
        final profile = ChatProfile(
          id: const Uuid().v4(),
          name: 'Test Profile',
          icon: '🤖',
          config: LlmChatConfig(
            systemPrompt: 'You are a helpful assistant',
            enableStream: true,
            temperature: 0.7,
            topP: 0.9,
            maxTokens: 4000,
            contextWindow: 8000,
            thinkingLevel: ThinkingLevel.medium,
          ),
          activeMcp: [
            ActiveMcp(id: 'mcp1', activeToolNames: ['tool1', 'tool2']),
            ActiveMcp(id: 'mcp2', activeToolNames: ['tool3']),
          ],
          activeModelTools: [
            ModelTool(
              modelId: 'model1',
              providerId: 'provider1',
              toolName: 'search',
            ),
          ],
        );

        final storage = ChatProfileStorage();
        await storage.ensureBoxReady();

        // Save and retrieve
        await storage.saveItem(profile);
        final retrieved = storage.getItem(profile.id);

        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(profile.id));
        expect(retrieved.name, equals(profile.name));
        expect(retrieved.icon, equals(profile.icon));
        expect(
          retrieved.config.systemPrompt,
          equals('You are a helpful assistant'),
        );
        expect(retrieved.config.temperature, equals(0.7));
        expect(retrieved.config.thinkingLevel, equals(ThinkingLevel.medium));
        expect(retrieved.activeMcp.length, equals(2));
        expect(retrieved.activeMcp[0].activeToolNames, contains('tool1'));
        expect(retrieved.activeModelTools.length, equals(1));
        expect(retrieved.activeModelTools[0].toolName, equals('search'));
      });
    });

    group('Integration Tests', () {
      test('should work with actual Hive box operations', () async {
        // Create test data
        final providerInfo = LlmProviderInfo(
          name: 'Integration Test Provider',
          type: ProviderType.anthropic,
          auth: Authorization(
            method: AuthMethod.bearerToken,
            key: 'Authorization',
            value: 'Bearer integration-test-token',
          ),
          config: Configuration(
            httpProxy: <String, dynamic>{},
            socksProxy: <String, dynamic>{},
            supportStream: true,
            headers: {'User-Agent': 'IntegrationTest/1.0'},
          ),
        );

        // Test through Hive box operations
        final box = await Hive.openBox<LlmProviderInfo>('integration_test');
        await box.put('test_provider', providerInfo);

        final retrieved = box.get('test_provider');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Integration Test Provider'));
        expect(retrieved.type, equals(ProviderType.anthropic));
        expect(retrieved.auth.method, equals(AuthMethod.bearerToken));
        expect(retrieved.config.supportStream, isTrue);

        await box.close();
      });

      test('should handle complex nested structures', () async {
        final mcpInfo = McpInfo(
          null, // Let it generate ID
          'Integration MCP Server',
          McpProtocol.stdio,
          null, // No URL for stdio
          null, // No headers for stdio
        );

        final box = await Hive.openBox<McpInfo>('mcp_integration_test');
        await box.put('test_mcp', mcpInfo);

        final retrieved = box.get('test_mcp');

        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Integration MCP Server'));
        expect(retrieved.protocol, equals(McpProtocol.stdio));
        expect(retrieved.url, isNull);
        expect(retrieved.headers, isNull);

        await box.close();
      });
    });

    group('Performance Comparison Tests', () {
      test('should demonstrate TypeAdapter performance benefits', () async {
        final profiles = List.generate(
          100,
          (index) => ChatProfile(
            id: const Uuid().v4(),
            name: 'Profile $index',
            config: LlmChatConfig(
              systemPrompt: 'System prompt $index',
              enableStream: true,
              temperature: 0.5 + (index * 0.01),
              maxTokens: 2000 + index * 10,
            ),
            activeMcp: [
              ActiveMcp(
                id: 'mcp$index',
                activeToolNames: ['tool1', 'tool2', 'tool3'],
              ),
            ],
          ),
        );

        final storage = ChatProfileStorage();
        await storage.ensureBoxReady();

        // Measure bulk save performance
        final stopwatch = Stopwatch()..start();

        for (final profile in profiles) {
          await storage.saveItem(profile);
        }

        final saveTime = stopwatch.elapsedMilliseconds;

        stopwatch.reset();

        // Measure bulk read performance
        final retrievedProfiles = <ChatProfile>[];
        for (final profile in profiles) {
          final retrieved = storage.getItem(profile.id);
          if (retrieved != null) {
            retrievedProfiles.add(retrieved);
          }
        }

        final readTime = stopwatch.elapsedMilliseconds;
        stopwatch.stop();

        expect(retrievedProfiles.length, equals(100));

        debugPrint('Bulk save 100 profiles: ${saveTime}ms');
        debugPrint('Bulk read 100 profiles: ${readTime}ms');
        debugPrint('Average save per item: ${saveTime / 100}ms');
        debugPrint('Average read per item: ${readTime / 100}ms');

        // Performance expectations (adjust based on actual performance)
        expect(
          saveTime,
          lessThan(5000),
        ); // Should save 100 items within 5 seconds
        expect(readTime, lessThan(500)); // Should read 100 items within 500ms
      });
    });
  });
}

/// Register all TypeAdapters for testing
void _registerTypeAdapters() {
  // Conversation adapters
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ConversationAdapter());
  }

  // Chat profile adapters
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ThinkingLevelAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(LlmChatConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(ActiveMcpAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ModelToolAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(ChatProfileAdapter());
  }

  // LLM provider adapters
  if (!Hive.isAdapterRegistered(7)) {
    Hive.registerAdapter(ProviderTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(8)) {
    Hive.registerAdapter(AuthMethodAdapter());
  }
  if (!Hive.isAdapterRegistered(9)) {
    Hive.registerAdapter(AuthorizationAdapter());
  }
  if (!Hive.isAdapterRegistered(10)) {
    Hive.registerAdapter(ConfigurationAdapter());
  }
  if (!Hive.isAdapterRegistered(11)) {
    Hive.registerAdapter(LlmProviderInfoAdapter());
  }

  // MCP adapters
  if (!Hive.isAdapterRegistered(12)) {
    Hive.registerAdapter(McpProtocolAdapter());
  }
  if (!Hive.isAdapterRegistered(13)) {
    Hive.registerAdapter(McpInfoAdapter());
  }
  if (!Hive.isAdapterRegistered(14)) {
    Hive.registerAdapter(StdioConfigAdapter());
  }
  if (!Hive.isAdapterRegistered(15)) {
    Hive.registerAdapter(McpToolsListAdapter());
  }
}
