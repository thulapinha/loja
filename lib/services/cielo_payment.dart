import 'package:cloud_functions/cloud_functions.dart';
import 'package:lojaronilson/models/credit_card.dart';
import 'package:lojaronilson/models/user.dart';

class CieloPayment {

  final CloudFunctions functions = CloudFunctions.instance;

  Future<void> authorize({CreditCard creditCard, num price,
    String orderId, User user}) async {

    final Map<String, dynamic> dataSale = {
      'merchantOrderId': orderId,
      'amount': (price * 100).toInt(),
      'softDescriptor': 'Loja GL',
      'installments': 1,
      'creditCard': creditCard.toJson(),
      'cpf': user.cpf,
      'paymentType': 'CreditCard',
    };

    final HttpsCallable callable = functions.getHttpsCallable(
        functionName: 'authorizeCreditCard'
    );
    final response = await callable.call(dataSale);
    print(response.data);
  }

}