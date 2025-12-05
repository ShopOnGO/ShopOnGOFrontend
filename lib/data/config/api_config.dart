class ApiConfig {
  static const String _authBaseUrl = 'http://localhost:8081';
  static const String _productBaseUrl = 'http://localhost:8082';
  static const String _mediaBaseUrl = 'http://localhost:8084';
  static const String _searchBaseUrl = 'http://localhost:8085';

  static const String loginEndpoint = '$_authBaseUrl/auth/login';
  static const String registerEndpoint = '$_authBaseUrl/auth/register';
  static const String changePasswordEndpoint = '$_authBaseUrl/auth/change/password';

  static const String brandsEndpoint = '$_productBaseUrl/product-service/brands/';

  static const String graphqlUrl = '$_searchBaseUrl/search';

  static const String mediaBaseUrl = '$_mediaBaseUrl/media/';
}