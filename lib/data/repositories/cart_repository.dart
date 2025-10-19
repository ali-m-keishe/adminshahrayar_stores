import '../models/cart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get cart by user ID
  Future<Cart?> getCartByUserId(String userId) async {
    try {
      final response = await _supabase
          .from('cart')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Cart.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Create new cart
  Future<Cart> createCart(String userId) async {
    try {
      final response = await _supabase
          .from('cart')
          .insert({
            'user_id': userId,
            'status': 'active',
          })
          .select()
          .single();

      return Cart.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create cart: $e');
    }
  }

  // Update cart status
  Future<Cart> updateCartStatus(int cartId, String status) async {
    try {
      final response = await _supabase
          .from('cart')
          .update({'status': status})
          .eq('cart_id', cartId)
          .select()
          .single();

      return Cart.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update cart status: $e');
    }
  }

  // Get cart items
  Future<List<CartItem>> getCartItems(int cartId) async {
    try {
      final response = await _supabase.from('cart_items').select('''
            *,
            items(*),
            item_sizes(*)
          ''').eq('cart_id', cartId).order('created_at', ascending: false);

      return (response as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cart items: $e');
    }
  }

  // Add item to cart
  Future<CartItem> addItemToCart({
    required int cartId,
    required int itemId,
    required int quantity,
    required String note,
    int? sizeId,
    Map<String, dynamic>? addons,
  }) async {
    try {
      final response = await _supabase
          .from('cart_items')
          .insert({
            'cart_id': cartId,
            'item_id': itemId,
            'quantity': quantity,
            'note': note,
            'size_id': sizeId,
            'cart_item_addons': addons ?? {},
          })
          .select()
          .single();

      return CartItem.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Update cart item quantity
  Future<CartItem> updateCartItemQuantity(int cartItemId, int quantity) async {
    try {
      final response = await _supabase
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', cartItemId)
          .select()
          .single();

      return CartItem.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  // Remove item from cart
  Future<void> removeItemFromCart(int cartItemId) async {
    try {
      await _supabase.from('cart_items').delete().eq('id', cartItemId);
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear cart
  Future<void> clearCart(int cartId) async {
    try {
      await _supabase.from('cart_items').delete().eq('cart_id', cartId);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
