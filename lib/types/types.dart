

import './account.dart';

enum LoginType{ 
  email, 
  phone
}

typedef AuthCallback = Future<String?> Function(Account account);
typedef ProviderAuthCallback = Future<String> Function();
