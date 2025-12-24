class ApiConfig {
  static const String _authBaseUrl = 'http://localhost:8081';
  static const String _productBaseUrl = 'http://localhost:8082';
  static const String _favoritesBaseUrl = 'http://localhost:8083';
  static const String _mediaBaseUrl = 'http://localhost:8084';
  static const String _searchBaseUrl = 'http://localhost:8085';

  static const String wsChatUrl = 'ws://localhost:8081/ws/chat';

  static const String mediaUploadEndpoint =
      'http://localhost:80/media-service/uploads';

  static const String loginEndpoint = '$_authBaseUrl/auth/login';
  static const String registerEndpoint = '$_authBaseUrl/auth/register';
  static const String changePasswordEndpoint =
      '$_authBaseUrl/auth/change/password';

  static const String resetRequestEndpoint = '$_authBaseUrl/auth/reset';
  static const String resetVerifyEndpoint = '$_authBaseUrl/auth/reset/verify';
  static const String resetConfirmEndpoint =
      '$_authBaseUrl/auth/reset/password';
  static const String resetResendEndpoint = '$_authBaseUrl/auth/reset/resend';

  static const String cartEndpoint = '$_authBaseUrl/cart';
  static const String cartItemEndpoint = '$_authBaseUrl/cart/item';

  static const String brandsEndpoint =
      '$_productBaseUrl/product-service/brands/';
  static const String productsEndpoint =
      '$_productBaseUrl/product-service/products/';

  static const String favoritesEndpoint =
      '$_favoritesBaseUrl/favorites-service/';

  static const String graphqlUrl = '$_searchBaseUrl/search';
  static const String mediaBaseUrl = '$_mediaBaseUrl/media/';
}
