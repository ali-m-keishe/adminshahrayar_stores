import 'package:adminshahrayar/data/models/customer_review.dart';
import 'package:adminshahrayar/data/repositories/customer_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The state class is unchanged
class CustomersState {
  final AsyncValue<List<Customer>> allCustomers;
  CustomersState({this.allCustomers = const AsyncValue.loading()});
  CustomersState copyWith({AsyncValue<List<Customer>>? allCustomers}) {
    return CustomersState(allCustomers: allCustomers ?? this.allCustomers);
  }
}

class CustomersNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    //declare and initialize the repository as a local variable inside the build method.
    final customerRepository = ref.watch(customerRepositoryProvider);

    return customerRepository.getAllCustomers();
  }

  // // Future methods for adding/deleting would now look like this:
  // Future<void> addCustomer(Customer customer) async {
  //   // Get the repository
  //   final customerRepository = ref.read(customerRepositoryProvider);
  //   // Set the UI to a loading state while we perform the action
  //   state = const AsyncLoading();
  //   // Use AsyncValue.guard to handle potential errors
  //   state = await AsyncValue.guard(() async {
  //     await customerRepository.addCustomer(customer);
  //     // Re-fetch the list to show the new customer
  //     return customerRepository.getAllCustomers();
  //   });
  // }
}

// The providers are unchanged
final customersProvider =
    AsyncNotifierProvider<CustomersNotifier, List<Customer>>(() {
  return CustomersNotifier();
});


