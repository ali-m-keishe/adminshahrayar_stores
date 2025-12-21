import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../models/order_details.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class OrderRepository {
  static const String _orderSelect =
      '*, address:address_id (formatted_address, custom_label), cart:cart_id (user_id)';
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all orders
  Future<List<Order>> getAllOrders() async {
    try {
      print('Attempting to fetch orders from Supabase...');
      final List<dynamic> response =
          await _supabase.from('orders').select(_orderSelect);

      print('Supabase fetch all orders: $response');

      return response
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Supabase fetch error orders: $e');
      print('Falling back to mock data...');
      // Return mock data instead of throwing error
      await Future.delayed(const Duration(milliseconds: 300));
      return mockOrders;
    }
  }

  Stream<List<Order>> subscribeToActiveOrders() {
    return supabase
        .from('orders')
        .stream(primaryKey: ['id'])
        .inFilter('status', ['pending', 'on the way']) // 🔹 فلترة هنا
        .order('created_at', ascending: false)
        .map((rows) => rows.map((row) => Order.fromJson(row)).toList());
  }

  // Get order by ID
  Future<Order?> getOrderById(int id) async {
    try {
      print('Attempting to fetch order $id from Supabase...');
      final response = await _supabase
          .from('orders')
          .select(_orderSelect)
          .eq('id', id)
          .single();

      print('Order response: $response');
      return Order.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      print('Supabase error for order $id: $e');
      print('Falling back to mock data...');
      // Fallback to mock data if Supabase fails
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return mockOrders.firstWhere((order) => order.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get detailed order information including cart items
  Future<OrderDetails?> getOrderDetails(int orderId) async {
    print('🔍 Fetching order details for order ID: $orderId');

    try {
      // First, try to get the order with all relations
      print('📡 Attempting to fetch order with relations...');
      final response = await supabase.from('orders').select('''
          id,
          created_at,
          status,
          payment_token,
          address_id,
          cart_id,
          address:address_id (
            id,
            formatted_address,
            region:region_id (
              id,
              name,
              delivery_fee
            )
          ),
          cart:cart_id (
            cart_id,
            created_at,
            status,
            user_id,
            total_price,
            cart_items (
              id,
              cart_id,
              quantity,
              note,
              item_id,
              size_id,
              cart_item_addons,
              price,
              has_offer,
              created_at,
              item:items (*),
              size:item_sizes (*)
            )
          )
        ''').eq('id', orderId).single();

      print('✅ Order details response received');
      print('📦 Response keys: ${response.keys.toList()}');
      print('📦 Response cart: ${response['cart']}');

      // 🧠 تأكد إن الـ cart فعلاً Map مش List
      dynamic cartData = response['cart'];
      print('📦 Cart data type: ${cartData.runtimeType}');

      if (cartData == null) {
        print('❌ Cart data is null! Trying to fetch cart separately...');
        // Fallback: fetch cart separately
        final cartId = response['cart_id'] as int?;
        if (cartId != null) {
          print('🔍 Fetching cart separately for cart_id: $cartId');
          final cartResponse = await supabase.from('cart').select('''
                cart_id,
                created_at,
                status,
                user_id,
                total_price,
                cart_items (
                  id,
                  cart_id,
                  quantity,
                  note,
                  item_id,
                  size_id,
                  cart_item_addons,
                  price,
                  has_offer,
                  created_at,
                  item:items (*),
                  size:item_sizes (*)
                )
              ''').eq('cart_id', cartId).single();
          cartData = cartResponse;
          print('✅ Fetched cart separately: ${cartData != null}');
        } else {
          throw Exception('Cart ID is null and cart relation is null');
        }
      } else {
        // Handle if cart is a list
        if (cartData is List) {
          if (cartData.isEmpty) {
            throw Exception('Cart list is empty');
          }
          cartData = cartData.first;
          print('📦 Cart was a list, using first element');
        }
      }

      if (cartData == null) {
        throw Exception('Unable to fetch cart data');
      }

      print('✅ Cart data extracted successfully');

      // استخرج بيانات الشحن (رسوم التوصيل من المنطقة)
      double shippingFee = 0;
      final addressData = response['address'];
      if (addressData != null && addressData is Map) {
        final regionData = addressData['region'];
        if (regionData != null && regionData['delivery_fee'] != null) {
          shippingFee = (regionData['delivery_fee'] as num).toDouble();
        }
      }

      // Fetch user info (email and phone) from auth.users
      // This is CRITICAL - we MUST get the user's email and phone
      String? username;
      String? phone;
      String? email;

      try {
        final userId = cartData['user_id'] as String?;
        print('🔍 [ORDER DETAILS] Fetching user info for userId: $userId');

        if (userId != null && userId.toString().isNotEmpty) {
          // Method 1: Try using RPC function to query auth.users
          bool userInfoFound = false;

          try {
            print('📡 [ORDER DETAILS] Attempting RPC get_user_info...');
            final userResponse = await supabase.rpc('get_user_info', params: {
              'user_uuid': userId,
            });

            print(
                '📦 [ORDER DETAILS] User RPC response type: ${userResponse.runtimeType}');
            print('📦 [ORDER DETAILS] User RPC response: $userResponse');

            if (userResponse != null) {
              Map<String, dynamic>? userData;

              // Handle different response formats
              if (userResponse is Map) {
                userData = userResponse as Map<String, dynamic>;
              } else if (userResponse is List && userResponse.isNotEmpty) {
                userData = userResponse[0] as Map<String, dynamic>;
              } else if (userResponse is String) {
                // If it's a JSON string, parse it
                try {
                  userData = Map<String, dynamic>.from(
                      jsonDecode(userResponse) as Map);
                } catch (e) {
                  print('⚠️ [ORDER DETAILS] Failed to parse JSON string: $e');
                }
              }

              if (userData != null && userData.isNotEmpty) {
                // Capture phone/email
                phone = userData['phone'] as String?;
                email = userData['email'] as String?;
                // Use email as username, fallback to phone, then anon stub
                username = email;
                if (username == null || username.isEmpty) {
                  username = phone != null && phone.isNotEmpty
                      ? 'User $phone'
                      : 'User ${userId.substring(0, 8)}...';
                }
                print(
                    '✅ [ORDER DETAILS] Found user from RPC: email=$email, phone=$phone');
                userInfoFound = true;
              }
            }
          } catch (rpcError) {
            print('⚠️ [ORDER DETAILS] RPC get_user_info failed: $rpcError');
          }

          // Method 2: Fallback to get_all_users_basic if RPC failed
          if (!userInfoFound) {
            try {
              print(
                  '📡 [ORDER DETAILS] Falling back to get_all_users_basic...');
              final allUsers = await supabase.rpc('get_all_users_basic');
              if (allUsers != null && allUsers is List) {
                print(
                    '📋 [ORDER DETAILS] Fetched ${allUsers.length} users from get_all_users_basic');
                for (var user in allUsers) {
                  final map = user as Map<String, dynamic>;
                  final responseUserId = map['id']?.toString() ?? '';
                  final cartUserId = userId.toString();
                  if (responseUserId == cartUserId) {
                    phone = map['phone'] as String?;
                    email = map['email'] as String?;
                    username = map['user_name'] as String? ?? email;
                    if (username == null || username.isEmpty) {
                      username = phone != null && phone.isNotEmpty
                          ? 'User $phone'
                          : 'User ${userId.substring(0, 8)}...';
                    }
                    print(
                        '✅ [ORDER DETAILS] Found user from get_all_users_basic: email=$email, phone=$phone');
                    userInfoFound = true;
                    break;
                  }
                }
              }
            } catch (fallbackError) {
              print(
                  '⚠️ [ORDER DETAILS] get_all_users_basic also failed: $fallbackError');
            }
          }

          // Method 3: Direct query to auth schema (if RLS allows)
          if (!userInfoFound) {
            try {
              print('📡 [ORDER DETAILS] Attempting direct auth.users query...');
              // Note: This might not work due to RLS, but worth trying
              final directQuery = await supabase
                  .from('auth.users')
                  .select('email, phone')
                  .eq('id', userId)
                  .maybeSingle();

              if (directQuery != null) {
                email = directQuery['email'] as String?;
                phone = directQuery['phone'] as String?;
                username = email;
                print(
                    '✅ [ORDER DETAILS] Found user from direct query: email=$email, phone=$phone');
                userInfoFound = true;
              }
            } catch (directError) {
              print(
                  '⚠️ [ORDER DETAILS] Direct auth.users query failed (expected if RLS blocks): $directError');
            }
          }

          if (!userInfoFound) {
            print(
                '❌ [ORDER DETAILS] Could not fetch user info through any method');
          }
        } else {
          print('⚠️ [ORDER DETAILS] userId is null or empty');
        }
      } catch (e, stackTrace) {
        print('❌ [ORDER DETAILS] Error fetching user info: $e');
        print('Stack trace: $stackTrace');
        // Continue without user info if query fails, but log it
      }

      print(
          '📤 [ORDER DETAILS] Final values - username: $username, email: $email, phone: $phone');

      // Ensure we have the user_id from cart
      final cartUserId = cartData['user_id'] as String?;
      print('📤 [ORDER DETAILS] Cart user_id: $cartUserId');

      // 🔧 جهّز JSON متوافق مع OrderDetails.fromJson
      final jsonData = {
        'order': {
          'id': response['id'],
          'created_at': response['created_at'],
          'status': response['status'],
          'payment_token': response['payment_token'],
          'address_id': response['address_id'],
          'cart_id': cartData['cart_id'],
        },
        'cart': {
          'cart_id': cartData['cart_id'],
          'created_at': cartData['created_at'],
          'status': cartData['status'],
          'total_price': cartData['total_price'],
          'user_id': cartUserId ?? '', // Ensure user_id is always present
          'username': username ?? '', // Use empty string if null
          'phone': phone, // nullable - can be null
          'email': email, // nullable - can be null
        },
        'items': (cartData['cart_items'] as List? ?? []).map((item) {
          return {
            'cart_item': {
              'id': item['id'],
              'cart_id': item['cart_id'],
              'quantity': item['quantity'],
              'note': item['note'],
              'item_id': item['item_id'],
              'size_id': item['size_id'],
              'cart_item_addons': item['cart_item_addons'] ?? {},
              'price': item['price'],
              'has_offer': item['has_offer'],
              'created_at': item['created_at'],
            },
            'menu_item': item['item'],
            'size': item['size'],
            'addons': (item['cart_item_addons'] != null &&
                    item['cart_item_addons'] is List)
                ? item['cart_item_addons']
                    .map((a) => {
                          'id': a['id'] ?? 0,
                          'name': a['name'] ?? '',
                          'price': (a['price'] ?? 0).toDouble(),
                        })
                    .toList()
                : [],
          };
        }).toList(),
        'total_price': cartData['total_price'],
        'shipping_fee': shippingFee,
      };

      print('🔧 Building OrderDetails from JSON...');
      print('📋 JSON data keys: ${jsonData.keys.toList()}');
      print('📋 Cart keys: ${jsonData['cart']?.keys.toList()}');
      print('📋 Items count: ${(jsonData['items'] as List).length}');

      try {
        final orderDetails = OrderDetails.fromJson(jsonData);
        print('✅ Order details fetched and parsed successfully');
        return orderDetails;
      } catch (parseError, parseStack) {
        print('❌ Error parsing OrderDetails: $parseError');
        print('Parse stack: $parseStack');
        print('JSON data that failed: $jsonData');
        return null;
      }
    } catch (e, stack) {
      print('❌ Error fetching order details: $e');
      print('Error type: ${e.runtimeType}');
      print('Full stack trace:');
      print(stack);

      // Try a simpler query as fallback
      try {
        print('🔄 Attempting fallback: simple order query...');
        final simpleResponse = await supabase
            .from('orders')
            .select('*')
            .eq('id', orderId)
            .single();
        print('✅ Simple query succeeded, but cannot build full OrderDetails');
        print('Simple response: $simpleResponse');
      } catch (fallbackError) {
        print('❌ Fallback query also failed: $fallbackError');
      }

      return null;
    }
  }

  // Get orders by status
  Future<List<Order>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .select(_orderSelect)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockOrders.where((order) => order.status == status).toList();
    }
  }

  // Get pending orders
  Future<List<Order>> getPendingOrders() async {
    return await getOrdersByStatus('pending');
  }

  // Get preparing orders
  Future<List<Order>> getPreparingOrders() async {
    return await getOrdersByStatus('on the way');
  }

  // Get completed orders
  Future<List<Order>> getCompletedOrders() async {
    return await getOrdersByStatus('done');
  }

  // Get recent orders
  Future<List<Order>> getRecentOrders({int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final sortedOrders = List<Order>.from(mockOrders);
    sortedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedOrders.take(limit).toList();
  }

  // Search orders by order ID
  Future<List<Order>> searchOrders(String query) async {
    try {
      final response = await _supabase
          .from('orders')
          .select(_orderSelect)
          .ilike('id', '%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockOrders
          .where((order) => order.id.toString().contains(query))
          .toList();
    }
  }

  // Add new order
  Future<Order> addOrder(Order order) async {
    try {
      final response = await _supabase
          .from('orders')
          .insert(order.toJson())
          .select(_orderSelect)
          .single();

      return Order.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 800));
      throw Exception('Failed to add order: $e');
    }
  }

  // Update order
  Future<Order> updateOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In a real app, this would make an API call to update the order
    return order;
  }

  // Update order status
  Future<Order> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select(_orderSelect)
          .single();

      return Order.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      // Fallback behavior if Supabase fails
      await Future.delayed(const Duration(milliseconds: 500));
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      final updatedOrder = Order(
        id: order.id,
        cartId: order.cartId,
        status: status,
        paymentToken: order.paymentToken,
        addressId: order.addressId,
        createdAt: order.createdAt,
      );

      return updatedOrder;
    }
  }

  // Assign driver to order
  Future<Order> assignDriverToOrder(int orderId, String driverId) async {
    try {
      final response = await _supabase
          .from('orders')
          .update({'driver_id': driverId})
          .eq('id', orderId)
          .select(_orderSelect)
          .single();

      return Order.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 600));
      final order = await getOrderById(orderId);
      if (order == null) {
        throw Exception('Order not found');
      }

      return order;
    }
  }

  // Delete order
  Future<void> deleteOrder(int id) async {
    try {
      await _supabase.from('orders').delete().eq('id', id);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      throw Exception('Failed to delete order: $e');
    }
  }

  // Get orders in date range
  Future<List<Order>> getOrdersInDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockOrders
        .where((order) =>
            order.createdAt.isAfter(startDate) &&
            order.createdAt.isBefore(endDate))
        .toList();
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final totalOrders = mockOrders.length;
    final statusCounts = <String, int>{};
    final typeCounts = <String, int>{};

    double totalRevenue = 0;

    for (final order in mockOrders) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
      typeCounts['Order'] = (typeCounts['Order'] ?? 0) + 1;

      if (order.status == 'done') {
        totalRevenue += 0; // TODO: Calculate from cart items
      }
    }

    return {
      'totalOrders': totalOrders,
      'statusCounts': statusCounts,
      'typeCounts': typeCounts,
      'totalRevenue': totalRevenue,
      'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
    };
  }

  // Get orders requiring attention (pending and preparing)
  Future<List<Order>> getOrdersRequiringAttention() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockOrders
        .where((order) =>
            order.status == 'pending' || order.status == 'on the way')
        .toList();
  }

  Future<List<Order>> getPendingAndOnTheWayOrders() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('orders')
        .select(_orderSelect)
        .inFilter('status', ['pending', 'on the way']) // ✅ filters statuses
        .order('created_at', ascending: false);

    // Convert to List<Order> safely
    final List<Order> orders = (response as List<dynamic>)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();

    return orders;
  }

  /// 🔹 Get all pending and on-the-way orders (for initial load, not paginated)
  /// This is used by the dashboard viewmodel for initial stats
  Future<Map<String, dynamic>> getPendingAndOnTheWayOrdersWithCount() async {
    try {
      print('🔍 Fetching all pending and on-the-way orders with count');

      // Build count query - get all active orders
      dynamic countQuery;

      // Count query
      countQuery = _supabase
          .from('orders')
          .select('id')
          .inFilter('status', ['pending', 'on the way']);

      // Get total count
      final countResult = await countQuery;
      final totalCount = (countResult as List).length;

      print('✅ Total active orders count: $totalCount');

      return {
        'orders': <Order>[],
        'totalCount': totalCount,
      };
    } catch (e, stack) {
      print('❌ Error fetching active orders count: $e');
      print(stack);
      return {
        'orders': <Order>[],
        'totalCount': 0,
      };
    }
  }

  Future<List<Order>> getOnTheWayOrders() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('orders')
        .select(_orderSelect)
        .eq('status', 'on the way') // ✅ only "on the way" orders
        .order('created_at', ascending: false);

    final List<Order> orders = (response as List<dynamic>)
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();

    return orders;
  }

  /// 🔹 Fetch paginated all orders (no status filter)
  Future<Map<String, dynamic>> getPaginatedAllOrders({
    required int limit,
    required int offset,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔍 Fetching paginated ALL orders: limit=$limit, offset=$offset');
      if (startDate != null) {
        print('📅 Start date filter: ${startDate.toUtc().toIso8601String()}');
      }
      if (endDate != null) {
        print('📅 End date filter: ${endDate.toUtc().toIso8601String()}');
      }

      // Count query
      dynamic countQuery = _supabase.from('orders').select('id');
      if (startDate != null) {
        countQuery =
            countQuery.gte('created_at', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        countQuery =
            countQuery.lte('created_at', endDate.toUtc().toIso8601String());
      }
      final countResult = await countQuery;
      final totalCount = (countResult as List).length;
      print('📊 Total count with filters: $totalCount');

      // Items query with pagination (apply filters BEFORE order/range)
      dynamic itemsQuery = _supabase.from('orders').select(_orderSelect);
      if (startDate != null) {
        itemsQuery =
            itemsQuery.gte('created_at', startDate.toUtc().toIso8601String());
      }
      if (endDate != null) {
        itemsQuery =
            itemsQuery.lte('created_at', endDate.toUtc().toIso8601String());
      }
      itemsQuery = itemsQuery
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      final itemsResponse = await itemsQuery;

      final orders = (itemsResponse as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ Fetched ${orders.length} orders (total: $totalCount)');
      return {
        'orders': orders,
        'totalCount': totalCount,
      };
    } catch (e, stack) {
      print('❌ Error fetching paginated all orders: $e');
      print(stack);
      return {
        'orders': <Order>[],
        'totalCount': 0,
      };
    }
  }

  /// 🔹 Fetch paginated active orders (pending and on the way)
  Future<Map<String, dynamic>> getPaginatedActiveOrders({
    required int limit,
    required int offset,
  }) async {
    try {
      print(
          '🔍 Fetching paginated active orders: limit=$limit, offset=$offset');

      // Build queries for count and items
      dynamic countQuery;
      dynamic itemQuery;

      // Count query - get all active orders
      countQuery = _supabase
          .from('orders')
          .select('id')
          .inFilter('status', ['pending', 'on the way']);

      // Item query - get paginated active orders
      itemQuery = _supabase
          .from('orders')
          .select(_orderSelect)
          .inFilter('status', ['pending', 'on the way'])
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Get total count
      final countResult = await countQuery;
      final totalCount = (countResult as List).length;

      // Execute item query
      final itemsResponse = await itemQuery;

      print('🔍 Raw orders response: $itemsResponse');

      // Parse orders
      final orders = (itemsResponse as List).map((json) {
        print('🔍 Parsing order: ${json['id']}');
        return Order.fromJson(json as Map<String, dynamic>);
      }).toList();

      print('✅ Fetched ${orders.length} active orders (total: $totalCount)');
      for (var order in orders) {
        print('📋 Order #${order.id} - userId: ${order.userId}');
      }

      return {
        'orders': orders,
        'totalCount': totalCount,
      };
    } catch (e, stack) {
      print('❌ Error fetching paginated active orders: $e');
      print(stack);
      return {
        'orders': <Order>[],
        'totalCount': 0,
      };
    }
  }

  /// Helper method to get user info (email and phone) by user ID
  Future<Map<String, String?>> getUserInfo(String userId) async {
    try {
      if (userId.isEmpty) {
        print('⚠️ getUserInfo - userId is empty');
        return {'email': null, 'phone': null};
      }

      print('🔍 getUserInfo - Fetching user info for userId: $userId');

      final userResponse = await supabase.rpc('get_user_info', params: {
        'user_uuid': userId,
      });

      print('📦 getUserInfo - RPC response type: ${userResponse.runtimeType}');
      print('📦 getUserInfo - RPC response: $userResponse');

      if (userResponse != null) {
        Map<String, dynamic>? userData;

        if (userResponse is Map) {
          userData = userResponse as Map<String, dynamic>;
        } else if (userResponse is List && userResponse.isNotEmpty) {
          userData = userResponse[0] as Map<String, dynamic>;
        } else if (userResponse is String) {
          try {
            userData =
                Map<String, dynamic>.from(jsonDecode(userResponse) as Map);
          } catch (e) {
            print('⚠️ Failed to parse JSON string: $e');
          }
        }

        if (userData != null && userData.isNotEmpty) {
          final email = userData['email'] as String?;
          final phone = userData['phone'] as String?;
          print('✅ getUserInfo - Found email: $email, phone: $phone');
          return {
            'email': email,
            'phone': phone,
          };
        } else {
          print('⚠️ getUserInfo - userData is null or empty');
        }
      } else {
        print('⚠️ getUserInfo - userResponse is null');
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching user info for $userId: $e');
      print('Stack trace: $stackTrace');
    }
    return {'email': null, 'phone': null};
  }

  /// Helper method to get userId from cart_id (fallback if relation doesn't work)
  Future<String?> getUserIdFromCart(int cartId) async {
    try {
      print('🔍 getUserIdFromCart - Fetching userId for cartId: $cartId');
      final response = await _supabase
          .from('cart')
          .select('user_id')
          .eq('cart_id', cartId)
          .single();

      final userId = response['user_id'] as String?;
      print('✅ getUserIdFromCart - Found userId: $userId');
      return userId;
    } catch (e) {
      print('❌ Error fetching userId from cart: $e');
      return null;
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});
