import 'dart:convert';

import 'package:atividade04/service/item_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:http/http.dart' as http;

void main() {
  group('ItemService', () {
    // Teste verifica se o método fetchAndFilterItems retorna uma lista filtrada.
    test('fetchAndFilterItems retorna lista filtrada', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'name': 'Item A'},
            {'name': 'Item B'},
            {'name': 'Teste Item C'}
          ]),
          200,
        );
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      final result = await itemService.fetchAndFilterItems('Teste');
      expect(result, ['Teste Item C']);
    });

    // Teste verifica se fetchAndFilterItems retorna uma lista vazia para termo inexistente.
    test('fetchAndFilterItems retorna lista vazia para termo inexistente', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'name': 'Item A'},
            {'name': 'Item B'}
          ]),
          200,
        );
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      final result = await itemService.fetchAndFilterItems('Inexistente');
      expect(result, []);
    });

    // Teste simula um erro de rede e verifica se fetchAndFilterItems lida com isso.
    test('fetchAndFilterItems lida com erro de rede', () async {
      final client = MockClient((request) async {
        return http.Response('Network Error', 500);
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      expect(
        () async => await itemService.fetchAndFilterItems('Teste'),
        throwsException,
      );
    });

    // Teste simula uma resposta com itens nulos para verificar a robustez do método.
    test('fetchAndFilterItems ignora itens nulos ou inválidos', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'name': 'Item A'},
            null,
            {'name': 'Item B'},
            {'nome': 'Item D'}, // Campo incorreto
            {'name': 'Teste Item C'}
          ]),
          200,
        );
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      final result = await itemService.fetchAndFilterItems('Item');
      expect(result, ['Item A', 'Item B', 'Teste Item C']);
    });

    // Teste verifica se fetchAndFilterItems ignora distinções de maiúsculas/minúsculas.
    test('fetchAndFilterItems ignora maiúsculas e minúsculas', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'name': 'Item A'},
            {'name': 'item b'},
            {'name': 'Teste Item C'}
          ]),
          200,
        );
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      final result = await itemService.fetchAndFilterItems('ITEM');
      expect(result, ['Item A', 'item b', 'Teste Item C']);
    });

    // Teste verifica se fetchAndFilterItems lida corretamente com resposta vazia.
    test('fetchAndFilterItems lida com resposta vazia', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200);
      });

      final itemService = ItemService('https://fakeapi.com/items', client: client);

      final result = await itemService.fetchAndFilterItems('Teste');
      expect(result, []);
    });
  });
}
