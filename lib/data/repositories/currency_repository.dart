import '../models/currency.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CurrencyRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all currencies
  Future<List<Currency>> getAllCurrencies() async {
    try {
      final response = await _supabase
          .from('currencies')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Currency.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      print('Error fetching currencies: $e');
      throw Exception('Failed to fetch currencies: $e');
    }
  }

  // Get currency by ID
  Future<Currency?> getCurrencyById(int id) async {
    try {
      final response = await _supabase
          .from('currencies')
          .select()
          .eq('id', id)
          .single();

      return Currency.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error fetching currency: $e');
      return null;
    }
  }

  // Update currency (code, name and symbol)
  Future<Currency> updateCurrency({
    required int id,
    required String code,
    required String name,
    required String symbol,
  }) async {
    try {
      final response = await _supabase
          .from('currencies')
          .update({
            'code': code,
            'name': name,
            'symbol': symbol,
          })
          .eq('id', id)
          .select()
          .single();

      return Currency.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Error updating currency: $e');
      throw Exception('Failed to update currency: $e');
    }
  }
}

