class Customer {
  final String id;
  final String name;
  final double totalSpent;
  final int orderCount;

  Customer({
    required this.id,
    required this.name,
    required this.totalSpent,
    required this.orderCount,
  });

  // Helper getter to create an avatar letter from the name
  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';

  // JSON serialization methods
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      totalSpent: (json['total_spent'] ?? 0).toDouble(),
      orderCount: json['order_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'total_spent': totalSpent,
      'order_count': orderCount,
    };
  }
}

class Review {
  final String customerName;
  final int rating; // Rating out of 5
  final String comment;
  final String date;

  Review({
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  // JSON serialization methods
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      customerName: json['customer_name'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'rating': rating,
      'comment': comment,
      'date': date,
    };
  }
}

// Mock Data for the UI
final List<Customer> mockTopCustomers = [
  Customer(id: 'c1', name: 'Jane Smith', totalSpent: 450.50, orderCount: 12),
  Customer(id: 'c2', name: 'Mary Johnson', totalSpent: 380.00, orderCount: 10),
  Customer(id: 'c3', name: 'John Doe', totalSpent: 250.75, orderCount: 8),
  Customer(id: 'c4', name: 'Peter Jones', totalSpent: 180.25, orderCount: 6),
];

final List<Review> mockRecentReviews = [
  Review(
    customerName: 'Peter Jones',
    rating: 5,
    comment: 'The Classic Burger was amazing! Best in town. Fast pickup too.',
    date: '2 days ago',
  ),
  Review(
    customerName: 'Mike T.',
    rating: 4,
    comment:
        'Delivery was quick and the food was still hot. The fries could have been a bit crispier though.',
    date: '3 days ago',
  ),
  Review(
    customerName: 'Guest User',
    rating: 2,
    comment:
        'My pizza was cold when it arrived and the order took over an hour.',
    date: '4 days ago',
  ),
];
